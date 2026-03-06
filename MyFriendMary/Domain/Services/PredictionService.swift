import Foundation

protocol PredictionService {
    func predictSummary(today: Date, cycles: [Cycle], profile: UserProfile) -> CycleSummary
}

struct DefaultPredictionService: PredictionService {
    private let windowSize = 6

    func predictSummary(today: Date, cycles: [Cycle], profile: UserProfile) -> CycleSummary {
        let normalizedToday = DateNormalizer.startOfDay(today)
        let sortedCycles = cycles.sorted { $0.startDate < $1.startDate }
        let closedCycles = sortedCycles.filter { $0.endDate != nil }

        let avgCycleLength = averageCycleLength(closedCycles: closedCycles, fallback: profile.cycleLengthDefault)
        let avgPeriodLength = averagePeriodLength(closedCycles: closedCycles, fallback: profile.periodLengthDefault)
        let hasActivePeriod = sortedCycles.contains { $0.endDate == nil }

        let lastStart = sortedCycles.last?.startDate
        let nextPeriodStart = lastStart.map { DateNormalizer.addingDays(avgCycleLength, to: $0) }
            ?? DateNormalizer.addingDays(profile.cycleLengthDefault, to: normalizedToday)

        let ovulationDate: Date? = hasActivePeriod ? nil : DateNormalizer.addingDays(-14, to: nextPeriodStart)
        let fertileWindowStart: Date? = ovulationDate.map { DateNormalizer.addingDays(-5, to: $0) }
        let fertileWindowEnd: Date? = ovulationDate.map { DateNormalizer.addingDays(1, to: $0) }

        let daysUntilNext = max(0, DateNormalizer.daysBetween(normalizedToday, nextPeriodStart))
        let estimatedPhase = resolvePhase(
            today: normalizedToday,
            cycles: sortedCycles,
            fertileWindowStart: fertileWindowStart,
            fertileWindowEnd: fertileWindowEnd,
            avgCycleLength: avgCycleLength,
            avgPeriodLength: avgPeriodLength,
            nextPeriodStart: nextPeriodStart
        )

        return CycleSummary(
            today: normalizedToday,
            estimatedPhase: estimatedPhase,
            daysUntilNextPeriod: daysUntilNext,
            nextPeriodStart: nextPeriodStart,
            fertileWindowStart: fertileWindowStart,
            fertileWindowEnd: fertileWindowEnd,
            ovulationDate: ovulationDate
        )
    }

    private func averageCycleLength(closedCycles: [Cycle], fallback: Int) -> Int {
        guard closedCycles.count >= 2 else { return fallback }

        let lengths = zip(closedCycles, closedCycles.dropFirst()).compactMap { first, second -> Int? in
            let diff = DateNormalizer.daysBetween(first.startDate, second.startDate)
            return diff > 0 ? diff : nil
        }
        let window = Array(lengths.suffix(windowSize))
        guard !window.isEmpty else { return fallback }

        let total = window.reduce(0, +)
        return max(1, Int((Double(total) / Double(window.count)).rounded()))
    }

    private func averagePeriodLength(closedCycles: [Cycle], fallback: Int) -> Int {
        let durations = closedCycles.compactMap { cycle -> Int? in
            guard let endDate = cycle.endDate else { return nil }
            return DateNormalizer.daysBetween(cycle.startDate, endDate) + 1
        }
        let window = Array(durations.suffix(windowSize))
        guard !window.isEmpty else { return fallback }

        let total = window.reduce(0, +)
        return max(1, Int((Double(total) / Double(window.count)).rounded()))
    }

    private func resolvePhase(
        today: Date,
        cycles: [Cycle],
        fertileWindowStart: Date?,
        fertileWindowEnd: Date?,
        avgCycleLength: Int,
        avgPeriodLength: Int,
        nextPeriodStart: Date
    ) -> AppPhase {
        let inRealPeriod = cycles.contains { cycle in
            let cycleStart = DateNormalizer.startOfDay(cycle.startDate)
            let cycleEnd = DateNormalizer.startOfDay(cycle.endDate ?? today)
            return today >= cycleStart && today <= cycleEnd
        }
        if inRealPeriod {
            return .menstruacion
        }

        let estimatedCurrentPeriodStart = DateNormalizer.addingDays(-avgCycleLength, to: nextPeriodStart)
        let estimatedCurrentPeriodEnd = DateNormalizer.addingDays(avgPeriodLength - 1, to: estimatedCurrentPeriodStart)
        if today >= estimatedCurrentPeriodStart && today <= estimatedCurrentPeriodEnd {
            return .menstruacion
        }

        if let fertileWindowStart,
           let fertileWindowEnd,
           today >= fertileWindowStart && today <= fertileWindowEnd {
            return .fertil
        }
        if let fertileWindowStart, today < fertileWindowStart {
            return .folicular
        }
        return .lutea
    }
}
