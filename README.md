Bitrise iOS Client app 🚀
---
![screen-shots.png](https://github.com/toshi0383/assets/raw/master/Bitrise-iOS/screen-shots.png)

[![Build Status](https://www.bitrise.io/app/a438cf48a72e2a1e/status.svg?token=63jRo8jI-419K26Bo3OrQw&branch=master)](https://www.bitrise.io/app/a438cf48a72e2a1e)
[![codecov](https://codecov.io/gh/toshi0383/Bitrise-iOS/branch/master/graph/badge.svg)](https://codecov.io/gh/toshi0383/Bitrise-iOS)

# Features
- ✅ Apps List `GET /me/apps`
- ✅ Builds List `GET /apps/${APP-SLUG}` `GET /apps/${APP-SLUG}/builds`
  + ✅ Show builds without paging
  + ✅ Abort `POST /apps/${APP-SLUG}/builds/${BUILD-SLUG}/abort`
- ✅ Show last visited app page on launch
- ✅ [Trigger] Add/Delete workflowIDs
- ✅ [Trigger] Cache workflowIDs, API token and last gitObject using Realm
- ✅ [Settings] Store credentials in Encrypted Realm
- ✅ [Trigger] Trigger Build for each app
- ✅ [TutorialView] bitrise personal access token
- ✅ 2.0 beta RELEASE (open-sourced!) 🚀

# TODOs
- ✅ Feel free to propose anything. 👍
- [ ] [Builds] Show build's username and commit message
- [ ] [Builds] Poll interval 8sec for "new builds available"
  + [ ] Tap message to show new builds
  + [ ] PullToRefresh to fetch new builds
- [ ] [Builds] Poll interval for status of each in-progress/on-hold builds
- [ ] 2.0 RELEASE 🚀
- [ ] [Settings] Display OSS Licenses
- [ ] Submit to App Store? 🍎
- [ ] [Builds] Brush up UI (make it more "Bitrise")
- [ ] [Builds] Drop down menu at navigationBar to switch apps
- [ ] [Builds] Local push notification for specified build
- [ ] Build Logs `GET /apps/${APP-SLUG}/builds/${BUILD-SLUG}/log`
- [ ] [Builds] Pagination
- [ ] [Apps] Pagination
- [ ] 3.0 RELEASE 🚀

Feel free to contrbute👌 I'm going to move these TODOs to GitHub issues.

# Getting Started

## Setup Carthage
Install the latest version of Carthage.
```
brew install carthage
```

Run following to build dependency frameworks.
```
carthage bootstrap --platform iOS
```

## Generate xcodeproj

Please install the latest version of [XcodeGen](https://github.com/yonaskolb/XcodeGen) on your own.
```
mint install yonaskolb/XcodeGen
```

Generate xcodeproj by running command below.
```
mint run xcodegen
```

Now you can open the xcodeproj, build it, and run.👌

## Set credentials in app
You need to set credentials below to use full feature of this app.

All tokens are securely stored in encrypted database using Realm. Encrypted key is stored in your keychain. Don't worry, it's safe.😉

https://realm.io/docs/swift/latest/#encryption

### Bitrise Personal Access Token
Required to access Bitrise v0.1 API.

SeeAlso: http://devcenter.bitrise.io/api/v0.1/#authentication

### API Token for Build Trigger API
This is different for each app.

SeeAlso: http://devcenter.bitrise.io/api/build-trigger

# Pro tip: use `configs/user.xcconfig` for convenience.

You can define workflowIDs preset for each apps by using `TRIGGER_BUILD_WORKFLOW_IDS`. This way you don't have to manually add workflowIDs.

The format is in JSON. Use AppSlug as a key and set **whitespace separated string** as workflowIDs.

e.g.
```
TRIGGER_BUILD_WORKFLOW_IDS={ "fdc3abbc325071dd": "beta danger release test" }
```

Put this in `configs/user.xcconfig`, so the app can read and store parsed values in database at initial launch. Make sure you clean install for this config to take effect.

`user.xcconfig` is ignored by git. (listed in `.gitignore`)

# License
MIT
