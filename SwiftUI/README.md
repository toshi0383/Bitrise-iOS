Bitrise-iOS SwiftUI
---

work in progress

## Platforms

- iOS13+
- macOS10.15+

## Development

Xcode11beta4

## Build

Following steps are required to build project.

### Carthage

```console
carthage checkout
```

We directly import source code of APIKit via XcodeGen.

### XcodeGen

```console
xcodegen
```

### API_TOKEN

Put this as `Config/xcconfig/user.xcconfig`.

```user.xcconfig
API_TOKEN=your-bitrise-api-token-xxxxxxxxxxxxxxxx
```

## License

MIT
