import Foundation

struct NotificationTextFactory {
    func periodReminder(isDiscreteModeOn: Bool) -> (title: String, body: String) {
        if isDiscreteModeOn {
            return ("Recordatorio", "Tienes una actualización programada.")
        }
        return ("Regla estimada", "Tu próxima regla está cerca según tu historial.")
    }

    func fertileWindowReminder(isDiscreteModeOn: Bool) -> (title: String, body: String) {
        if isDiscreteModeOn {
            return ("Recordatorio", "Tienes una actualización programada.")
        }
        return ("Ventana fértil", "Hoy podría estar dentro de tu ventana fértil estimada.")
    }
}
