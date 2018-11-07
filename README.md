Bitrise iOS Client app 🚀
---
![screen-shots.png](https://github.com/toshi0383/assets/raw/master/Bitrise-iOS/screen-shots.png)

[![Build Status](https://app.bitrise.io/app/f74e0c84d3865a2f/status.svg?token=m5WvEi3nznlg64vry5qyRA&branch=master)](https://app.bitrise.io/app/f74e0c84d3865a2f)
[![codecov](https://codecov.io/gh/toshi0383/Bitrise-iOS/branch/master/graph/badge.svg)](https://codecov.io/gh/toshi0383/Bitrise-iOS)
[![patreon](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://www.patreon.com/bePatron?u=13627375)

# Features
- ✅ App List `GET /me/apps`
    + Shows last visited app page on launch
- ✅ Build List
  + Show builds
  + Abort
  + Rebuild
- ✅ Trigger
  + Add/Delete workflowIDs
  + Cache workflowIDs, API token and last gitObject using Realm
  + Trigger Build for each app
- ✅ bitrise.yml
  + download / upload
  + Syntax Highlight

# Building Project

## Setup Carthage
Install the latest version of Carthage.
```console
brew install carthage
```

Run following to build dependency frameworks.
```console
carthage bootstrap --platform iOS
```

## Generate xcodeproj

Install the latest version of [XcodeGen](https://github.com/yonaskolb/XcodeGen).

Then generate xcodeproj.
```console
xcodegen
```

Open the xcodeproj, build and run.

## Set `DEVELOPMENT_TEAM` in `configs/user.xcconfig`
So you don't have to modify it from Xcode everytime after you run `xcodegen`.

# Required Credentials
You need credentials below to use full feature of this app.

All tokens are securely stored in encrypted Realm database. Corresponding encryption key is stored in your keychain. [It's the way Realm recommends.](https://realm.io/docs/swift/latest/#encryption)

## Bitrise Personal Access Token
Required to access Bitrise v0.1 API. Generate one in the setting page.

![Personal Access Token](https://github.com/toshi0383/assets/raw/master/Bitrise-iOS/personal-access-token.png)

SeeAlso: http://devcenter.bitrise.io/api/v0.1/#authentication

## Build Trigger Token
This is different for each app. Get one from dashboard.

![Build Trigger Token](https://github.com/toshi0383/assets/raw/master/Bitrise-iOS/build-trigger-token.png)

SeeAlso: http://devcenter.bitrise.io/api/build-trigger

# Donate
If you think it's a useful tool, consider donation to maintain project.

[![patreon](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://www.patreon.com/bePatron?u=13627375)

# License
MIT
