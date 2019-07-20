Bitrise-iOS SwiftUI
---

work in progress

## Development

Xcode11beta4

## Build

### Carthage

```console
carthage checkout
open Carthage/Checkouts/RxSwift/Rx.xcworkspace and manually build frameworks
open Carthage/Checkouts/APIKit/APIKit.xcworkspace and manually build framework
copy them under Carthage/Build/iOS/
```

### API_TOKEN

Put this as `Config/xcconfig/user.xcconfig`.

```user.xcconfig
API_TOKEN=your-bitrise-api-token-xxxxxxxxxxxxxxxx
```

### XcodeGen

```console
xcodegen
```

## License

MIT
