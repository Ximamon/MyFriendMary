import Foundation
import UserNotifications

final class LocalNotificationScheduler: NotificationScheduler {
    private let notificationCenter: UNUserNotificationCenter
    private let textFactory: NotificationTextFactory

    init(
        notificationCenter: UNUserNotificationCenter = .current(),
        textFactory: NotificationTextFactory = NotificationTextFactory()
    ) {
        self.notificationCenter = notificationCenter
        self.textFactory = textFactory
    }

    func reschedule(using profile: UserProfile, summary: CycleSummary) async {
        _ = textFactory
        _ = profile
        _ = summary
        // TODO: Implementar programación real de notificaciones (Paso 5).
    }

    func cancelAll() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
