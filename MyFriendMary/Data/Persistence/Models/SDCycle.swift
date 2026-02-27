import Foundation
import SwiftData

@Model
final class SDCycle {
    @Attribute(.unique) var id: UUID
    var startDay: Date
    var endDay: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        startDay: Date,
        endDay: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.startDay = DateNormalizer.startOfDay(startDay)
        self.endDay = endDay.map { DateNormalizer.startOfDay($0) }
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
