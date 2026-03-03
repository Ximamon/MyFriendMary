import Foundation

enum RingDayState: String, Codable, Equatable {
    case sinPlan
    case uso
    case descanso

    var displayName: String {
        switch self {
        case .sinPlan:
            return "Sin plan"
        case .uso:
            return "Uso"
        case .descanso:
            return "Descanso"
        }
    }
}
