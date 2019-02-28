import Foundation
import Realm
import RealmSwift
import Security

extension Realm {

    static func getRealm() -> Realm {
        do {
            let fileURL = Configuration.defaultConfiguration.fileURL?
                .deletingLastPathComponent()
                .appendingPathComponent("bitrise-ios.realm")

            let key = getKey() as Data
            // print("fileURL: \(fileURL!), key: \(key.hexEncodedString(options: .upperCase))")
            let config = Configuration(fileURL: fileURL, encryptionKey: key)

            do {
                return try Realm(configuration: config)

            } catch {
                print("Failed to open realm with error: \(error)")

                #if !DEBUG
                // Only delete realm file in production.
                // I often make mistake writing migration block, and don't want to lose my data.
                let fm = FileManager.default
                if let fileURL = fileURL, fm.fileExists(atPath: fileURL.path) {
                    try fm.removeItem(at: fileURL)
                }
                #endif

                return try Realm(configuration: config)
            }

        } catch {
            fatalError("\(error)")
        }
    }

    private static func getKey() -> NSData {
        // Identifier for our keychain entry - should be unique for your application
        let keychainIdentifier = "jp.toshi0383.Bitrise-iOS.RealmEncKey"
        let keychainIdentifierData = keychainIdentifier.data(using: .utf8, allowLossyConversion: false)!

        // First check in the keychain for an existing key
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]

        // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
        // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }

        // No pre-existing key from this application, so generate a new one
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")

        // Store the key in the keychain
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keyData
        ]

        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")

        return keyData
    }
}
