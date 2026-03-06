import Foundation

protocol PeriodEntryRepository {
    func upsertEntry(_ entry: PeriodEntry) async throws
    func entry(for day: Date) async throws -> PeriodEntry?
    func entries(in interval: DateInterval) async throws -> [PeriodEntry]
}
