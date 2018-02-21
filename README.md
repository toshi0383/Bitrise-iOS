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
- [x] Improve credential management (Store it in realm)
- [x] [TutorialView] bitrise personal access token
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

# Getting Started

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

Now you can build and run.

## Set credentials from app
You need to set credentials below to use full feature of this app.

### Bitrise Personal Access Token
Required to access Bitrise v0.1 API.

SeeAlso: http://devcenter.bitrise.io/api/v0.1/#authentication

### API Token for Build Trigger API
This is different for each app.

SeeAlso: http://devcenter.bitrise.io/api/build-trigger

# Pro tip: use `configs/user.xcconfig` for convenience.

You can define workflowIDs preset for each apps by using `TRIGGER_BUILD_WORKFLOW_IDS`. This way your team members do not have to manually add workflowIDs.
The format is in JSON. Use AppSlug as a key and set whitespace separated string as workflowIDs.

e.g.
```
TRIGGER_BUILD_WORKFLOW_IDS={ "fdc3abbc325071dd": "beta danger release test" }
```

Put `TRIGGER_BUILD_WORKFLOW_IDS` in `configs/user.xcconfig` and the app will read and store it in database at initial launch.

`user.xcconfig` is ignored by git. (listed in .gitignore)

# License
MIT
