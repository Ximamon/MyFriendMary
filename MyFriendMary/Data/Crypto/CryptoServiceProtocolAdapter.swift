import Foundation

protocol CryptoService {
    func encryptString(_ plaintext: String?) throws -> String?
    func decryptString(_ ciphertext: String?) throws -> String?
    func encryptInt(_ value: Int) throws -> String
    func decryptInt(_ value: String) throws -> Int
    func encryptSexTypes(_ value: Set<SexType>) throws -> String
    func decryptSexTypes(_ value: String) throws -> Set<SexType>
}

enum CryptoServiceError: Error {
    case invalidPayload
}
