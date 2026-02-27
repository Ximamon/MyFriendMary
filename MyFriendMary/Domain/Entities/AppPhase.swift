import Foundation

enum AppPhase: String, Codable {
    case menstruacion
    case folicular
    case fertil
    case lutea
    case desconocida

    var displayName: String {
        switch self {
        case .menstruacion:
            return "Menstruación"
        case .folicular:
            return "Folicular"
        case .fertil:
            return "Fértil"
        case .lutea:
            return "Lútea"
        case .desconocida:
            return "Desconocida"
        }
    }
}
