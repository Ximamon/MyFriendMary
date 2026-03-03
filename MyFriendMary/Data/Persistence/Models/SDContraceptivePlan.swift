import Foundation
import SwiftData

@Model
final class SDContraceptivePlan {
    @Attribute(.unique) var id: UUID
    var methodRaw: String
    var startDay: Date
    var endDay: Date?
    var ringDays: Int
    var breakDays: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        methodRaw: String = ContraceptiveMethodType.anilloVaginal.rawValue,
        startDay: Date,
        endDay: Date? = nil,
        ringDays: Int = 21,
        breakDays: Int = 7,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.methodRaw = methodRaw
        self.startDay = DateNormalizer.startOfDay(startDay)
        self.endDay = endDay.map { DateNormalizer.startOfDay($0) }
        self.ringDays = ringDays
        self.breakDays = breakDays
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
