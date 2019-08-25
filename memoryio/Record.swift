//
//  Record.swift
//  memoryio
//
//  Created by Jacob Rosenthal on 12/8/17.
//  Copyright © 2017 augmentous. All rights reserved.
//

import Foundation
import AVFoundation
import AppKit

class Record: NSObject, AVCaptureFileOutputRecordingDelegate
{
    var storedHandler : ((Error?) -> Void)?
    let videoFileOutput = AVCaptureMovieFileOutput()

    var _captureSession: AVCaptureSession!
    var captureSession: AVCaptureSession {
        if _captureSession == nil {
            _captureSession = AVCaptureSession()
            let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaType.video)  }
            let captureDeviceInput = try? AVCaptureDeviceInput(device: devices.first!)
            _captureSession.addInput(captureDeviceInput!)
            _captureSession.addOutput(videoFileOutput)

            _captureSession.sessionPreset = AVCaptureSession.Preset.high
        }
        return _captureSession
    }
    
    //https://stackoverflow.com/questions/32286320/grab-frames-from-video-using-swift
    func generateThumbnail(url : URL, fromTime:Double) -> NSImage {
        let asset :AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore = CMTime.zero;
        let time        : CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 600)
        let img        : CGImage = try! assetImgGenerate.copyCGImage(at: time, actualTime: nil)
        let image: NSImage = NSImage(cgImage: img, size: NSZeroSize)
        return image
    }

    func makeDateURL(path: String, ext: String, date: Date) -> URL
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss.SSS"
        let nowstr = dateFormatter.string(from: date)
        let pathAndFilename = "\(path)\(nowstr)"
        
        return URL(fileURLWithPath: pathAndFilename, isDirectory: true).appendingPathExtension(ext)
    }

    func captureMp4Asynchronously(path: String, withLength: Double, completionHandler:@escaping (Error?, URL) -> Void) -> Bool {
        if captureSession.isRunning{
            return false
        }

        captureSession.startRunning()

        let fileName = "AVRecorder_\(ProcessInfo.processInfo.globallyUniqueString).mov"
        let tempUrl = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        captureVideoAsynchronously(url: tempUrl!, withLength: withLength) {
            (error) in

            //cant seem to run this from within handler scope so dispatch it
            DispatchQueue.main.async {
                self.captureSession.stopRunning()
            }

            let urlAsset = AVURLAsset(url: tempUrl!, options: nil)
            
            let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) // AVAssetExportPresetHighestQuality)
            
            let date = Date()
            let url = self.makeDateURL(path: path, ext: "mp4", date:date)

            exportSession!.outputURL = url
            exportSession!.outputFileType = AVFileType.mp4
            exportSession!.shouldOptimizeForNetworkUse = true
            exportSession!.exportAsynchronously { () -> Void in
                
                try? FileManager.default.removeItem(at: tempUrl!)
                completionHandler(exportSession?.error, url)
            }
        }
        return true
    }

    func captureVideoAsynchronously(url: URL, withLength: Double, completionHandler: @escaping (Error?) -> Void) {
        storedHandler = completionHandler
        let maxDuration = CMTime(seconds: withLength, preferredTimescale: 1)
        videoFileOutput.maxRecordedDuration = maxDuration
        videoFileOutput.startRecording(to: url, recordingDelegate: self)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        storedHandler!(error)
        storedHandler = nil
    }

}
