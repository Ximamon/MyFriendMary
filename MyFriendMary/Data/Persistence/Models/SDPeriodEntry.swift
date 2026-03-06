import Foundation
import SwiftData

@Model
final class SDPeriodEntry {
    @Attribute(.unique) var id: UUID
    var day: Date
    var intensityRaw: String?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        day: Date,
        intensityRaw: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.day = DateNormalizer.startOfDay(day)
        self.intensityRaw = intensityRaw
        self.updatedAt = updatedAt
    }
}
