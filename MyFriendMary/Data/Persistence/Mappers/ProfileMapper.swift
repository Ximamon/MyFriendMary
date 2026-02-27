import Foundation

enum ProfileMapper {
    static func toDomain(_ model: SDUserProfile) -> UserProfile {
        UserProfile(
            cycleLengthDefault: model.cycleLengthDefault,
            periodLengthDefault: model.periodLengthDefault,
            isDiscreteModeOn: model.isDiscreteModeOn,
            isBiometricLockOn: model.isBiometricLockOn,
            biometricScope: BiometricScope(rawValue: model.biometricScopeRaw) ?? .appCompleta
        )
    }

    static func apply(_ profile: UserProfile, to model: SDUserProfile) {
        model.cycleLengthDefault = profile.cycleLengthDefault
        model.periodLengthDefault = profile.periodLengthDefault
        model.isDiscreteModeOn = profile.isDiscreteModeOn
        model.isBiometricLockOn = profile.isBiometricLockOn
        model.biometricScopeRaw = profile.biometricScope.rawValue
    }
}
