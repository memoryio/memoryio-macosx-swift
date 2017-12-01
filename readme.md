# memoryio

Available in the [mac app store](https://itunes.apple.com/us/app/memoryio/id694665051?ls=1&mt=12) and check out [https://www.memory.io](memory.io) for more details.

# build
`carthage bootstrap` Then `open memoryio.xcodeproj`

# background
This is the 2.0 version of the [original memoryio](https://github.com/memoryio/memoryio-macosx). It is a complete rewrite intended to simplify the code base through:
* Removing objective c delegates patterns and exensions via a comlete swift rewrite
* Remove complicated build systems (cocoapods) and dependencies overall
* Remove interface builder (implement the [nibless](https://lapcatsoftware.com/articles/working-without-a-nib-part-11.html) or [minimal](https://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html) concepts)
