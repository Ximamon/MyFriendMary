import Foundation

enum SexType: String, CaseIterable, Codable {
    case vaginalCon = "vaginal_con"
    case vaginalSin = "vaginal_sin"
    case oral = "oral"
    case analCon = "anal_con"
    case analSin = "anal_sin"
    case masturbacion = "masturbacion"
    case juguetes = "juguetes"

    var displayName: String {
        switch self {
        case .vaginalCon:
            return "Vaginal con"
        case .vaginalSin:
            return "Vaginal sin"
        case .oral:
            return "Oral"
        case .analCon:
            return "Anal con"
        case .analSin:
            return "Anal sin"
        case .masturbacion:
            return "Masturbación"
        case .juguetes:
            return "Juguetes"
        }
    }
}
