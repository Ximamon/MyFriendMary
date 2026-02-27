import Foundation

protocol BiometricAuthService {
    func authenticate(reason: String) async -> Bool
}
