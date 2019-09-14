SKETCHTOOL ?= /Applications/Sketch.app/Contents/MacOS/sketchtool
JQ ?= /usr/local/bin/jq
GO ?= /usr/local/bin/go
APPICONSET_DIR ?= BitriseClient/Assets.xcassets/AppIcon.appiconset
APPICON_SKETCH ?= resources/app-icon.sketch
SKETCHMATE ?= scripts/sketchmate

test:
	xcodebuild test -project BitriseClient.xcodeproj -scheme BitriseClientTests -destination 'name=iPhone X'

clean:
	rm -rf Carthage/Build/iOS

bootstrap:
	carthage bootstrap --platform ios

app-icon:
	rm $(APPICONSET_DIR)/*.png || :

	#$(SKETCHTOOL) export artboards --scales=1x,2x,3x resources/launch-screen.sketch
	$(SKETCHTOOL) list artboards $(APPICON_SKETCH) \
		| $(GO) run $(SKETCHMATE)/* \
		| $(JQ) . > $(APPICONSET_DIR)/Contents.json

	$(SKETCHTOOL) export artboards $(APPICON_SKETCH) --output=$(APPICONSET_DIR)
	$(SKETCHTOOL) export artboards $(APPICON_SKETCH) --output=$(APPICONSET_DIR) --item=Icon
	rm $(APPICONSET_DIR)/"iOS App Icon Template.png" || :
