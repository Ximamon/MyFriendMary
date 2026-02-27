import Foundation
import SwiftData

@Model
final class SDSymptomEntry {
    @Attribute(.unique) var id: UUID
    var day: Date
    var symptomsRaw: String
    var note: String?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        day: Date,
        symptomsRaw: String,
        note: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.day = DateNormalizer.startOfDay(day)
        self.symptomsRaw = symptomsRaw
        self.note = note
        self.updatedAt = updatedAt
    }
}
