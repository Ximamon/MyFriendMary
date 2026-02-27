import Foundation

protocol SymptomRepository {
    func upsertEntry(_ entry: SymptomEntry) async throws
    func entry(for day: Date) async throws -> SymptomEntry?
    func entries(in interval: DateInterval) async throws -> [SymptomEntry]
}
