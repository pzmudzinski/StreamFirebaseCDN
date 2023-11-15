# StreamFirebaseCDN

This package lets you use Firebase Storage as custom CDN in [Stream Chat's attachments](https://getstream.io/chat/docs/ios-swift/file_uploads/?language=swift&q=attachment).

## Installation

### Swift Package Manager

You can add `StreamFirebaseCDN` to your project via Swift Package Manager by adding the following dependency to your Package.swift:

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
    import StreamFirebaseCDN

    static let chatClient: ChatClient = {
        var config = ChatClientConfig(apiKeyString: "something")
         config.customCDNClient = StreamFirebaseCDN()
        return ChatClient(config: config)
    }()

```

## Configuration

### Directory

By default CDN client will use default bucket and `attachments` directory for upload. You can configure it using `Configuration` and/or passing different instance of `FirebaseStorage` into constructor.

```swift
let customConfig = StreamFirebaseCDN.Configuration(folderName: "customFolder")
let customCDN = StreamFirebaseCDN(configuration: customConfig)
```

### Changing default path for stored files

This will store files under `{channelId}/{fileName}` directory:

```swift
       let cdnClient = StreamFirebaseCDN(metadataFactory: { attachment in
            return nil
        }, idFactory: { attachment in
            if let localFileURL = attachment.uploadingState?.localFileURL {
                let cid = attachment.id.cid.rawValue
                return "\(cid)/\(localFileURL.lastPathComponent)"
            } else {
                return attachment.id.rawValue
            }
        })
```

### Custom metadata

Each storage reference can have some metadata attached:

```swift
       let cdnClient = StreamFirebaseCDN(metadataFactory: { attachment in
            let metadata = StorageMetadata()
            metadata.customMetadata = [
                "cid": attachment.id.cid.rawValue,
                "messageId": attachment.id.messageId,
                "index": String(describing: attachment.id.index),
                "type": attachment.type.rawValue
            ]

            return metadata
        })
```

## License

StreamFirebaseCDN is available under the MIT license. See the LICENSE file for more info.
