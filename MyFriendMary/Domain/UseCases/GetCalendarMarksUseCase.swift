import Foundation

protocol GetCalendarMarksUseCase {
    func execute(monthAnchor: Date) async throws -> [CalendarDayMark]
}

@MainActor
final class DefaultGetCalendarMarksUseCase: GetCalendarMarksUseCase {
    private let cycleRepository: CycleRepository
    private let symptomRepository: SymptomRepository
    private let sexEntryRepository: SexEntryRepository
    private let contraceptivePlanRepository: ContraceptivePlanRepository
    private let profileRepository: ProfileRepository
    private let predictionService: PredictionService
    private let ringScheduleService: RingScheduleService

    init(
        cycleRepository: CycleRepository,
        symptomRepository: SymptomRepository,
        sexEntryRepository: SexEntryRepository,
        contraceptivePlanRepository: ContraceptivePlanRepository,
        profileRepository: ProfileRepository,
        predictionService: PredictionService,
        ringScheduleService: RingScheduleService
    ) {
        self.cycleRepository = cycleRepository
        self.symptomRepository = symptomRepository
        self.sexEntryRepository = sexEntryRepository
        self.contraceptivePlanRepository = contraceptivePlanRepository
        self.profileRepository = profileRepository
        self.predictionService = predictionService
        self.ringScheduleService = ringScheduleService
    }

    func execute(monthAnchor: Date) async throws -> [CalendarDayMark] {
        let month = DateNormalizer.monthInterval(for: monthAnchor)
        let cycles = try await cycleRepository.fetchCycles()
        let symptoms = try await symptomRepository.entries(in: month)
        let sexEntries = try await sexEntryRepository.entries(in: month)
        let ringPlans = try await contraceptivePlanRepository.fetchPlans()
        let profile = try await profileRepository.getProfile()
        let summary = predictionService.predictSummary(today: monthAnchor, cycles: cycles, profile: profile)

        let symptomDays = Set(symptoms.map { DateNormalizer.startOfDay($0.date) })
        let sexDays = Set(sexEntries.map { DateNormalizer.startOfDay($0.date) })
        let fertileDays = hasActivePeriod(cycles: cycles) ? Set<Date>() : makeFertileDays(from: summary)
        let orgasmPeakDays = makeOrgasmPeakDays(from: sexEntries)
        let monthDays = makeMonthDays(in: month)

        return monthDays.map { day in
            let ringState = ringState(on: day, plans: ringPlans)

            return CalendarDayMark(
                day: day,
                hasPeriod: hasPeriod(on: day, cycles: cycles),
                isPredictedFertile: fertileDays.contains(day),
                hasSymptoms: symptomDays.contains(day),
                hasSexEntry: sexDays.contains(day),
                isOrgasmPeakDay: orgasmPeakDays.contains(day),
                hasRingUsage: ringState == .uso,
                hasRingBreak: ringState == .descanso
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

    private func hasActivePeriod(cycles: [Cycle]) -> Bool {
        cycles.contains { $0.endDate == nil }
    }

    private func makeOrgasmPeakDays(from entries: [SexEntry]) -> Set<Date> {
        let maxCount = entries.map(\.orgasmCount).max() ?? 0
        guard maxCount > 0 else { return [] }

        return Set(
            entries
                .filter { $0.orgasmCount == maxCount }
                .map { DateNormalizer.startOfDay($0.date) }
        )
    }

    private func ringState(on day: Date, plans: [ContraceptivePlan]) -> RingDayState {
        let normalizedDay = DateNormalizer.startOfDay(day)
        guard let plan = plans.last(where: { contains(day: normalizedDay, plan: $0) }) else {
            return .sinPlan
        }
        return ringScheduleService.state(on: normalizedDay, plan: plan)
    }

    private func contains(day: Date, plan: ContraceptivePlan) -> Bool {
        let start = DateNormalizer.startOfDay(plan.startDate)
        guard day >= start else { return false }
        if let endDate = plan.endDate {
            return day <= DateNormalizer.startOfDay(endDate)
        }
        return true
    }
}
