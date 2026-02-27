import Foundation

enum PeriodIntensity: String, CaseIterable, Codable {
    case leve
    case media
    case abundante

    var displayName: String {
        rawValue.capitalized
    }
}
