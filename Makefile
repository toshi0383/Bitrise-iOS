clean:
	rm -rf Carthage/Build/iOS

bootstrap:
	carthage bootstrap --platform ios --no-use-binaries

export-assets:
	/Applications/Sketch.app/Contents/Resources/sketchtool/bin/sketchtool export artboards --scales=1x,2x,3x resources/assets.sketch
