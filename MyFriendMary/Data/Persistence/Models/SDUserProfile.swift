import Foundation
import SwiftData

@Model
final class SDUserProfile {
    static let singletonID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

    @Attribute(.unique) var id: UUID
    var cycleLengthDefault: Int
    var periodLengthDefault: Int
    var isDiscreteModeOn: Bool
    var isBiometricLockOn: Bool
    var biometricScopeRaw: String

    init(
        id: UUID = SDUserProfile.singletonID,
        cycleLengthDefault: Int = 28,
        periodLengthDefault: Int = 5,
        isDiscreteModeOn: Bool = false,
        isBiometricLockOn: Bool = false,
        biometricScopeRaw: String = BiometricScope.appCompleta.rawValue
    ) {
        self.id = id
        self.cycleLengthDefault = cycleLengthDefault
        self.periodLengthDefault = periodLengthDefault
        self.isDiscreteModeOn = isDiscreteModeOn
        self.isBiometricLockOn = isBiometricLockOn
        self.biometricScopeRaw = biometricScopeRaw
    }
}
