Bitrise Client
---

# Features
- [x] Trigger Builds for a specific app
- [ ] Apps List `GET /me/apps` (update on enterForeground)
- [ ] Builds List `GET /apps/${APP-SLUG}` `GET /apps/${APP-SLUG}/builds`
  + [ ] Show 30 builds without paging
  + [ ] Abort Button `GET /apps/${APP-SLUG}/builds/${BUILD-SLUG}/abort`
  + [ ] Poll interval 8sec for "new builds available message" for new builds (needs a framework like RxDataSources)
      - [ ] Tap message to show new builds
      - [ ] PullToRefresh to fetch new builds
  + [ ] Pagination
- [ ] Trigger Build for each app
  + [ ] Cache workflowIDs (needs a framework like RxDataSources)
- [ ] Build Logs `GET /apps/${APP-SLUG}/builds/${BUILD-SLUG}/log`

# How to Build
## App Configuration

Set correct value in `configs/secret.xcconfig`.
This is ignored by git. (listed in .gitignore)

#### Required

- `BITRISE_APP_SLUG`
- `BITRISE_API_TOKEN`

#### Optional

- `BITRISE_WORKFLOW_IDS` ... whitespace separated

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
