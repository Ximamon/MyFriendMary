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
            return "Vaginal con protección"
        case .vaginalSin:
            return "Vaginal sin protección"
        case .oral:
            return "Sexo oral"
        case .analCon:
            return "Anal con protección"
        case .analSin:
            return "Anal sin protección"
        case .masturbacion:
            return "Masturbación"
        case .juguetes:
            return "Juguetes íntimos"
        }
    }
}
