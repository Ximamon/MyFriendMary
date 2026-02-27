import Foundation

protocol SexEntryRepository {
    func upsertEntry(_ entry: SexEntry) async throws
    func entry(for day: Date) async throws -> SexEntry?
    func entries(in interval: DateInterval) async throws -> [SexEntry]
}
