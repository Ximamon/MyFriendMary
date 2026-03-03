import Foundation

enum ContraceptionDomainError: LocalizedError, Equatable {
    case activePlanAlreadyExists
    case noActivePlan
    case endDateBeforeStart

    var errorDescription: String? {
        switch self {
        case .activePlanAlreadyExists:
            return "Ya existe un plan de anillo activo."
        case .noActivePlan:
            return "No hay un plan de anillo activo."
        case .endDateBeforeStart:
            return "La fecha de fin no puede ser anterior al inicio del plan."
        }
    }
}
