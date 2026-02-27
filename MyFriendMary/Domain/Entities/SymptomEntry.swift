import Foundation

struct SymptomEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var symptoms: [SymptomType]
    var note: String?
}
