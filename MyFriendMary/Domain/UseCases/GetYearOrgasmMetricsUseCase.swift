import Foundation

protocol GetYearOrgasmMetricsUseCase {
    func execute(for day: Date) async throws -> YearOrgasmMetrics
}

@MainActor
final class DefaultGetYearOrgasmMetricsUseCase: GetYearOrgasmMetricsUseCase {
    private let repository: SexEntryRepository
    private let calendar: Calendar

    init(repository: SexEntryRepository, calendar: Calendar = .current) {
        self.repository = repository
        self.calendar = calendar
    }

    func execute(for day: Date) async throws -> YearOrgasmMetrics {
        let normalizedDay = DateNormalizer.startOfDay(day)
        let year = calendar.component(.year, from: normalizedDay)

        guard let yearInterval = calendar.dateInterval(of: .year, for: normalizedDay) else {
            return .empty(for: year)
        }

        let start = DateNormalizer.startOfDay(yearInterval.start)
        let end = min(yearInterval.end, normalizedDay.addingTimeInterval(24 * 60 * 60))
        let interval = DateInterval(start: start, end: end)

        let entries = try await repository.entries(in: interval)
        let totalOrgasms = entries.reduce(0) { $0 + max(0, $1.orgasmCount) }

        let peakEntries = entries
            .filter { $0.orgasmCount > 0 }
            .sorted { lhs, rhs in
                if lhs.orgasmCount != rhs.orgasmCount {
                    return lhs.orgasmCount > rhs.orgasmCount
                }
                return lhs.date > rhs.date
            }

        return YearOrgasmMetrics(
            year: year,
            totalOrgasmsYTD: totalOrgasms,
            bestDayOfYear: peakEntries.first?.date,
            bestDayOrgasmCount: peakEntries.first?.orgasmCount ?? 0
        )
    }
}
