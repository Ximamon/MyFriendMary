import Foundation
import SwiftData

@Model
final class SDSexEntry {
    @Attribute(.unique) var id: UUID
    var day: Date
    var orgasmCountRaw: String
    var typesRaw: String
    var noteRaw: String?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        day: Date,
        orgasmCountRaw: String,
        typesRaw: String,
        noteRaw: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.day = DateNormalizer.startOfDay(day)
        self.orgasmCountRaw = orgasmCountRaw
        self.typesRaw = typesRaw
        self.noteRaw = noteRaw
        self.updatedAt = updatedAt
    }
}
