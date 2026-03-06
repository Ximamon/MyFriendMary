import Foundation

protocol ContraceptionNotificationScheduler {
    func rescheduleRing(using profile: UserProfile, activePlan: ContraceptivePlan?) async
}
