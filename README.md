Bitrise Client
---

# How to Build
## App Configuration

Set correct value in `configs/secret.xcconfig`.
This is ignored by git. (listed in .gitignore)

#### Required

- `BITRISE_APP_SLUG`
- `BITRISE_API_TOKEN`

#### Optional

- `BITRISE_WORKFLOW_IDS` ... whitespace separated

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
