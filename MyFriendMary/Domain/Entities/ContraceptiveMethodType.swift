import Foundation

enum ContraceptiveMethodType: String, Codable, CaseIterable {
    case anilloVaginal

    var displayName: String {
        switch self {
        case .anilloVaginal:
            return "Anillo vaginal"
        }
    }
}
