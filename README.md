Bitrise Client
---

# Features
- [x] Trigger Builds for a specific app
- [x] Apps List `GET /me/apps` (update on enterForeground)
- [x] Builds List `GET /apps/${APP-SLUG}` `GET /apps/${APP-SLUG}/builds`
  + [x] Show builds without paging
  + [x] Abort Button `POST /apps/${APP-SLUG}/builds/${BUILD-SLUG}/abort`
- [x] Show last app page on launch
- [x] [Trigger] keyboard awareness
- [x] [Trigger] Add/Delete workflowIDs
- [x] Install Encrypted Realm
- [x] [Trigger] Cache workflowIDs, API token and last gitObject using Realm
- [x] Trigger Build for each app
- [ ] [SettingsView] bitrise personal access token
- [ ] [Builds] WireFrame to SettingsView if no personal access token is set
- [ ] [Trigger] Improve trigger launcher button UX (size)
- [ ] 2.0 RELEASE 🚀
- [ ] [Builds] Show build's username and commit message
- [ ] [Builds] Poll interval 8sec for "new builds available"
  + [ ] Tap message to show new builds
  + [ ] PullToRefresh to fetch new builds
- [ ] [Builds] Poll interval for status of each in-progress/on-hold builds
- [ ] [Builds] Drop down menu at navigationBar to switch apps
- [ ] [Builds] Local push notification for specified build
- [ ] Build Logs `GET /apps/${APP-SLUG}/builds/${BUILD-SLUG}/log`
- [ ] [Builds] Pagination
- [ ] [Apps] Pagination
- [ ] 3.0 RELEASE 🚀

# How to Build
## App Configuration

Set correct value in `configs/secret.xcconfig`.
This is ignored by git. (listed in .gitignore)

#### Required
- `BITRISE_PERSONAL_ACCESS_TOKEN`

SeeAlso: http://devcenter.bitrise.io/api/v0.1/#authentication

#### Required for BuildTrigger view to appear

Currently BuildTriggerViewController supports single app.

- `TRIGGER_BUILD_API_TOKENS`
- `TRIGGER_BUILD_WORKFLOW_IDS`

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
