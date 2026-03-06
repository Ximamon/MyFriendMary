import Foundation

protocol LogPeriodUseCase {
    func execute(date: Date, realStartDate: Date?, intensity: PeriodIntensity?) async throws
}

@MainActor
final class DefaultLogPeriodUseCase: LogPeriodUseCase {
    private let cycleRepository: CycleRepository
    private let healthKitSyncService: HealthKitSyncService

    init(cycleRepository: CycleRepository, healthKitSyncService: HealthKitSyncService) {
        self.cycleRepository = cycleRepository
        self.healthKitSyncService = healthKitSyncService
    }

    func execute(date: Date, realStartDate: Date?, intensity: PeriodIntensity?) async throws {
        _ = intensity
        let day = DateNormalizer.startOfDay(date)
        let effectiveStart = DateNormalizer.startOfDay(realStartDate ?? day)
        let startDay = min(effectiveStart, day)

        if var openCycle = try await cycleRepository.getOpenCycle() {
            if startDay < openCycle.startDate {
                openCycle.startDate = startDay
                try await cycleRepository.upsertCycle(openCycle)
                await healthKitSyncService.syncMenstrualFlow(for: openCycle)
            }
            return
        }

        let newCycle = Cycle(id: UUID(), startDate: startDay, endDate: nil)
        try await cycleRepository.upsertCycle(newCycle)
        await healthKitSyncService.syncMenstrualFlow(for: newCycle)
    }
}
