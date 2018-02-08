Bitrise Client
---

# 環境設定
### configs/secret.xcconfig

下記それぞれ適切に設定してください。

- `BITRISE_APP_SLUG`
- `BITRISE_API_TOKEN`

他にも必要なビルド設定があればこちらに設定できます。

### XcodeGen
XcodeGenの最新をインストールしてください。
```
mint install yonaskolb/XcodeGen
```

以下のコマンドでxcodeprojが生成されます。
```
xcodegen
```
