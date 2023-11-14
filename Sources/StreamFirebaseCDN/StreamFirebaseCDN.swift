import Foundation
import StreamChat
import FirebaseStorage

public class StreamFirebaseCDN: CDNClient {
    public static var maxAttachmentSize: Int64 { 300 }
    
    public struct Configuration {
        let folderName: String
        
        public static let defaultConfiguration: Configuration = .init(folderName: "attachments")
    }
    
    private let storage: Storage
    private let configuration: Configuration
    private let metadataFactory: ((AnyChatMessageAttachment) -> StorageMetadata?)?
    
    public init(storage: Storage = .storage(), configuration: Configuration = .defaultConfiguration, metadataFactory: ((AnyChatMessageAttachment) -> StorageMetadata?)? = nil) {
        self.storage = storage
        self.configuration = configuration
        self.metadataFactory = metadataFactory
    }

    public func uploadAttachment(_ attachment: AnyChatMessageAttachment, progress: ((Double) -> Void)?, completion: @escaping (Result<URL, Error>) -> Void) {
        let payload = attachment.payload
        let storageRef = storage.reference(withPath: configuration.folderName).child(attachment.id.rawValue)
        let uploadTask = storageRef.putData(payload, metadata: nil) { metadata, error in
            if let error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }

        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
            progress?(percentComplete)
        }
    }
    
}

