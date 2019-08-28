//
//  Photo.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/7/17.
//  Copyright © 2017 augmentous. All rights reserved.
//

import Foundation
import AVFoundation
import ImageIO

class Photo: NSObject
{
    let stillImageOutput = AVCaptureStillImageOutput()

    var _captureSession: AVCaptureSession!
    var captureSession: AVCaptureSession {
        if _captureSession == nil {
            _captureSession = AVCaptureSession()
            let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaType.video)  }
            let captureDeviceInput = try? AVCaptureDeviceInput(device: devices.first!)
            _captureSession.addInput(captureDeviceInput!)
            
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecType.jpeg]
            _captureSession.addOutput(stillImageOutput)
            
            _captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        return _captureSession
    }

    func makeDateURL(path: String, ext: String, date: Date) -> URL
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss.SSS"
        let nowstr = dateFormatter.string(from: date)
        let pathAndFilename = "\(path)\(nowstr)"
        
        return URL(fileURLWithPath: pathAndFilename, isDirectory: true).appendingPathExtension(ext)
    }
    
    func addExifDates(data: Data, date:Date) -> Data{
        
        //this works but seems overkill
        let cgImgSource: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil)!
        let uti: CFString = CGImageSourceGetType(cgImgSource)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: data)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!
        
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(cgImgSource, 0, nil)! as NSDictionary
        let mutable: NSMutableDictionary = imageProperties.mutableCopy() as! NSMutableDictionary

        let EXIFDictionary: NSMutableDictionary = (mutable[kCGImagePropertyExifDictionary as String] as? NSMutableDictionary)!

        //doesnt seem to be anything in the original..
//        print("before modification \(EXIFDictionary)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        EXIFDictionary.setValue(dateFormatter.string(from: date), forKey: kCGImagePropertyExifDateTimeDigitized as String)
        EXIFDictionary.setValue(dateFormatter.string(from: date), forKey: kCGImagePropertyExifDateTimeOriginal as String)
//        print("after modification \(EXIFDictionary)")

        mutable[kCGImagePropertyExifDictionary as String] = EXIFDictionary
        CGImageDestinationAddImageFromSource(destination, cgImgSource, 0, (mutable as CFDictionary))
        CGImageDestinationFinalize(destination)
        return dataWithEXIF as Data
    }
    
    func captureStillImageAsynchronously(path: String, warmupDelay: Double, completionHandler: @escaping (Error?, URL?) -> Void) {
        
        captureSession.startRunning()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + warmupDelay) {
            let connection = self.stillImageOutput.connection(with: AVMediaType.video)
            self.stillImageOutput.captureStillImageAsynchronously(from: connection! ) {
                (buffer, error) -> Void in

                //cant seem to run this from within handler scope so dispatch it
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                }

                if (error != nil){
                    return completionHandler(error, nil)
                }

                let date = Date()
                let rawImageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!)
                let imageData = self.addExifDates(data:rawImageData!, date:date)
                var error2: NSError?

                let url = self.makeDateURL(path: path, ext: "jpg", date:date)

                do{
                    try FileManager.default.createDirectory(at:NSURL.fileURL(withPath: path), withIntermediateDirectories:true, attributes: nil);
                    try imageData.write(to: url )
                }catch {
                    error2 = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not write image data"])
                }
                return completionHandler(error2, url)
            }
        }
    }
}
