import Foundation

struct UserProfile: Codable, Equatable {
    var cycleLengthDefault: Int
    var periodLengthDefault: Int
    var isDiscreteModeOn: Bool
    var isBiometricLockOn: Bool
    var biometricScope: BiometricScope

    static let `default` = UserProfile(
        cycleLengthDefault: 28,
        periodLengthDefault: 5,
        isDiscreteModeOn: false,
        isBiometricLockOn: false,
        biometricScope: .appCompleta
    )
}

enum BiometricScope: String, Codable, CaseIterable {
    case appCompleta
    case seccionEncuentro

    var displayName: String {
        switch self {
        case .appCompleta:
            return "App completa"
        case .seccionEncuentro:
            return "Solo Encuentro"
        }
    }
}
