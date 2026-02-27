import Foundation

protocol NotificationScheduler {
    func reschedule(using profile: UserProfile, summary: CycleSummary) async
}
