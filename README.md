# StreamFirebaseCDN

This package lets you use Firebase Storage as custom CDN in [Stream Chat's attachments](https://getstream.io/chat/docs/ios-swift/file_uploads/?language=swift&q=attachment).

## Installation

### Swift Package Manager

You can add `StreamFirebaseCDN`` to your project via Swift Package Manager by adding the following dependency to your Package.swift:

```swift
dependencies: [
    .package(
      url: "https://github.com/pzmudzinski/StreamFirebaseCDN.git",
      .upToNextMajor(from: "1.0.0")
    )
]
```

## Usage

```swift
    static let chatClient: ChatClient = {
        var config = ChatClientConfig(apiKeyString: "something")
         config.customCDNClient = StreamFirebaseCDN()
        return ChatClient(config: config)
    }()

```

## Configuration

By default CDN client will use default bucket and `attachments` directory for upload. You can configure it using `Configuration` and/or passing different instance of `FirebaseStorage` into constructor.

```swift
let customConfig = StreamFirebaseCDN.Configuration(folderName: "customFolder")
let customCDN = StreamFirebaseCDN(configuration: customConfig)
```

## License

StreamFirebaseCDN is available under the MIT license. See the LICENSE file for more info.
