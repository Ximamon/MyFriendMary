import Foundation

enum SymptomType: String, CaseIterable, Codable {
    case colicos
    case cefalea
    case acne
    case distension
    case sensibilidadPecho = "sensibilidad_pecho"
    case cansancio
    case animoBajo = "animo_bajo"
    case antojos

    var displayName: String {
        switch self {
        case .colicos:
            return "Cólicos"
        case .cefalea:
            return "Cefalea"
        case .acne:
            return "Acné"
        case .distension:
            return "Distensión"
        case .sensibilidadPecho:
            return "Sensibilidad pecho"
        case .cansancio:
            return "Cansancio"
        case .animoBajo:
            return "Ánimo bajo"
        case .antojos:
            return "Antojos"
        }
    }
}
