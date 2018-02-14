Bitrise Client
---

# Features
- [x] Trigger Builds for a specific app
- [x] Apps List `GET /me/apps` (update on enterForeground)
- [x] Builds List `GET /apps/${APP-SLUG}` `GET /apps/${APP-SLUG}/builds`
  + [x] Show builds without paging
  + [x] Abort Button `POST /apps/${APP-SLUG}/builds/${BUILD-SLUG}/abort`
- [x] Show last app page on launch
- [ ] [Trigger] improve UI
- [ ] SettingsView to set personal access token from screen
- [ ] BETA RELEASE 🚀
- [ ] [Trigger] Add/Delete workflowIDs and cache them
- [ ] [Apps][Builds] Poll interval 8sec for "new builds available message" for new builds
  + [ ] Tap message to show new builds
  + [ ] PullToRefresh to fetch new builds
- [ ] Trigger Build for each app
- [ ] [Builds] local push notification for specified build
- [ ] Build Logs `GET /apps/${APP-SLUG}/builds/${BUILD-SLUG}/log`
- [ ] [Apps][Builds] Pagination

# How to Build
## App Configuration

Set correct value in `configs/secret.xcconfig`.
This is ignored by git. (listed in .gitignore)

#### Required
- `BITRISE_PERSONAL_ACCESS_TOKEN`

SeeAlso: http://devcenter.bitrise.io/api/v0.1/#authentication

#### Required for BuildTrigger view to appear

Currently BuildTriggerViewController supports single app.

- `TRIGGER_BUILD_APP_SLUG`
- `TRIGGER_BUILD_API_TOKEN`
- `TRIGGER_BUILD_WORKFLOW_IDS` ... whitespace separated

SeeAlso: http://devcenter.bitrise.io/api/build-trigger

## Setup Carthage
Install the latest version of Carthage.
```
brew install carthage
```

Run following to build dependency frameworks.
```
carthage bootstrap --platform iOS --no-use-binaries
```

## Generate xcodeproj

Please install the latest XcodeGen on your own.
```
mint install yonaskolb/XcodeGen
```

Generate xcodeproj by running command below.
```
xcodegen
```

# License
MIT
