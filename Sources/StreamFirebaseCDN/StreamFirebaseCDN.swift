import Foundation
import StreamChat
import FirebaseStorage
import os

public class StreamFirebaseCDN: CDNClient {
    public static var maxAttachmentSize: Int64 = 20 * 1024 * 1024
    
    public struct Configuration {
        let folderName: String
        
        public static let defaultConfiguration: Configuration = .init(folderName: "attachments")
        
        public init(folderName: String) {
            self.folderName = folderName
        }
    }
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "StreamFirebaseCDN")
    private let storage: Storage
    private let configuration: Configuration
    private let metadataFactory: ((AnyChatMessageAttachment) -> StorageMetadata?)?
    private let idFactory: ((AnyChatMessageAttachment) -> String)?
    
    public init(storage: Storage = .storage(), configuration: Configuration = .defaultConfiguration, metadataFactory: ((AnyChatMessageAttachment) -> StorageMetadata?)? = nil, idFactory: ((AnyChatMessageAttachment) -> String)? = nil) {
        self.storage = storage
        self.configuration = configuration
        self.metadataFactory = metadataFactory
        self.idFactory = idFactory
    }

    public func uploadAttachment(_ attachment: AnyChatMessageAttachment, progress: ((Double) -> Void)?, completion: @escaping (Result<URL, Error>) -> Void) {
        logger.trace("upload attachment started")
        let storageChildId = idFactory?(attachment) ?? attachment.id.rawValue
        logger.trace("child id generated \(storageChildId)")
        
        let storageRef = storage.reference(withPath: configuration.folderName).child(storageChildId)
        let metadata: StorageMetadata? = metadataFactory?(attachment)
        
        var storageUploadTask: StorageUploadTask?
        
        if let localFileURL = attachment.uploadingState?.localFileURL {
            logger.trace("found local file URL \(localFileURL.absoluteString)")
            storageUploadTask = storageRef.putFile(from: localFileURL, metadata: metadata) { [weak self] metadata, error in
                if let error {
                    self?.logger.warning("failed to upload \(error)")
                    completion(.failure(error))
                    return
                }
                self?.logger.trace("upload succesful, generating download url")

                storageRef.downloadURL { [weak self] url, error in
                    if let error = error {
                        self?.logger.warning("failed to generate download url \(error)")
                        completion(.failure(error))
                    } else if let url = url {
                        self?.logger.notice("url generated")
                        completion(.success(url))
                    }
                }
            }
        }
        

        storageUploadTask?.observe(.progress) { [weak self] snapshot in
            self?.logger.trace("upload progress \(snapshot.progress?.fractionCompleted ?? 0)")
            progress?(snapshot.progress?.fractionCompleted ?? 0)
        }
    }
    
}

