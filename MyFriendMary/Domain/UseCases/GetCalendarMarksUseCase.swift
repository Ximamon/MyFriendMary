import Foundation

protocol GetCalendarMarksUseCase {
    func execute(monthAnchor: Date) async throws -> [CalendarDayMark]
}

@MainActor
final class DefaultGetCalendarMarksUseCase: GetCalendarMarksUseCase {
    private let cycleRepository: CycleRepository
    private let symptomRepository: SymptomRepository
    private let sexEntryRepository: SexEntryRepository
    private let profileRepository: ProfileRepository
    private let predictionService: PredictionService

    init(
        cycleRepository: CycleRepository,
        symptomRepository: SymptomRepository,
        sexEntryRepository: SexEntryRepository,
        profileRepository: ProfileRepository,
        predictionService: PredictionService
    ) {
        self.cycleRepository = cycleRepository
        self.symptomRepository = symptomRepository
        self.sexEntryRepository = sexEntryRepository
        self.profileRepository = profileRepository
        self.predictionService = predictionService
    }

    func execute(monthAnchor: Date) async throws -> [CalendarDayMark] {
        let month = DateNormalizer.monthInterval(for: monthAnchor)
        let cycles = try await cycleRepository.fetchCycles()
        let symptoms = try await symptomRepository.entries(in: month)
        let sexEntries = try await sexEntryRepository.entries(in: month)
        let profile = try await profileRepository.getProfile()
        let summary = predictionService.predictSummary(today: monthAnchor, cycles: cycles, profile: profile)

        let symptomDays = Set(symptoms.map { DateNormalizer.startOfDay($0.date) })
        let sexDays = Set(sexEntries.map { DateNormalizer.startOfDay($0.date) })
        let fertileDays = makeFertileDays(from: summary)
        let monthDays = makeMonthDays(in: month)

        return monthDays.map { day in
            CalendarDayMark(
                day: day,
                hasPeriod: hasPeriod(on: day, cycles: cycles),
                isPredictedFertile: fertileDays.contains(day),
                hasSymptoms: symptomDays.contains(day),
                hasSexEntry: sexDays.contains(day)
            )
        }
    }

    private func makeFertileDays(from summary: CycleSummary) -> Set<Date> {
        guard let start = summary.fertileWindowStart,
              let end = summary.fertileWindowEnd else {
            return []
        }
        let dayCount = max(0, DateNormalizer.daysBetween(start, end))
        return Set((0...dayCount).map { DateNormalizer.addingDays($0, to: start) })
    }

    private func makeMonthDays(in interval: DateInterval) -> [Date] {
        let start = DateNormalizer.startOfDay(interval.start)
        let numberOfDays = max(0, DateNormalizer.daysBetween(start, interval.end))
        return (0..<numberOfDays).map { DateNormalizer.addingDays($0, to: start) }
    }

    private func hasPeriod(on day: Date, cycles: [Cycle]) -> Bool {
        let today = DateNormalizer.startOfDay(Date())
        return cycles.contains { cycle in
            let cycleStart = DateNormalizer.startOfDay(cycle.startDate)
            let cycleEnd = DateNormalizer.startOfDay(cycle.endDate ?? today)
            return day >= cycleStart && day <= cycleEnd
        }
    }
}
