import Foundation

struct Cycle: Identifiable, Codable, Equatable {
    var id: UUID
    var startDate: Date
    var endDate: Date?

    var lengthDays: Int? {
        guard let endDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return days + 1
    }
}
