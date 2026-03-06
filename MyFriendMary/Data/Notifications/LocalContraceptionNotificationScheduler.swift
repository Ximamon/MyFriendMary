import Foundation

struct LocalContraceptionNotificationScheduler: ContraceptionNotificationScheduler {
    func rescheduleRing(using profile: UserProfile, activePlan: ContraceptivePlan?) async {
        _ = profile
        _ = activePlan
        // TODO: Programar recordatorios de inserción/retiro del anillo.
    }
}
