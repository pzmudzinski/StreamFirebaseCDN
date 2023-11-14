import Foundation
import StreamChat
import FirebaseStorage

public class StreamFirebaseCDN: CDNClient {
    public static var maxAttachmentSize: Int64 { 20 * 1024 * 1024 }
    
    public struct Configuration {
        let folderName: String
        
        public static let defaultConfiguration: Configuration = .init(folderName: "attachments")
        
        public init(folderName: String) {
            self.folderName = folderName
        }
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
        let storageRef = storage.reference(withPath: configuration.folderName).child(attachment.id.rawValue)
        let metadata: StorageMetadata? =  metadataFactory?(attachment)
        
        var storageUploadTask: StorageUploadTask?
        
        if let localFileURL = attachment.uploadingState?.localFileURL {
            storageUploadTask = storageRef.putFile(from: localFileURL, metadata: metadata) { metadata, error in
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
        }
        


        storageUploadTask?.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
            progress?(percentComplete)
        }
    }
    
}

