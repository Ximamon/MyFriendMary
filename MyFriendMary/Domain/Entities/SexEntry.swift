import Foundation

struct SexEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var orgasmCount: Int
    var types: Set<SexType>
    var note: String?
}
