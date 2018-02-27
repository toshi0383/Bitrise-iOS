SKETCHTOOL ?= /Applications/Sketch.app/Contents/Resources/sketchtool/bin/sketchtool

test:
	xcodebuild test -project BitriseClient.xcodeproj -scheme BitriseClientTests -destination 'name=iPhone X'

clean:
	rm -rf Carthage/Build/iOS

bootstrap:
	carthage bootstrap --platform ios

export-assets:
	$(SKETCHTOOL) export artboards --scales=1x,2x,3x resources/assets.sketch
	$(SKETCHTOOL) export artboards --scales=1x,2x,3x resources/launch-screen.sketch
