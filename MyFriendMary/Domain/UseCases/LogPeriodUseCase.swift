import Foundation

protocol LogPeriodUseCase {
    func execute(date: Date, intensity: PeriodIntensity?) async throws
}

@MainActor
final class DefaultLogPeriodUseCase: LogPeriodUseCase {
    private let cycleRepository: CycleRepository
    private let healthKitSyncService: HealthKitSyncService

    init(cycleRepository: CycleRepository, healthKitSyncService: HealthKitSyncService) {
        self.cycleRepository = cycleRepository
        self.healthKitSyncService = healthKitSyncService
    }

    func execute(date: Date, intensity: PeriodIntensity?) async throws {
        _ = intensity
        let day = DateNormalizer.startOfDay(date)

        if var openCycle = try await cycleRepository.getOpenCycle() {
            if day < openCycle.startDate {
                openCycle.startDate = day
                try await cycleRepository.upsertCycle(openCycle)
                await healthKitSyncService.syncMenstrualFlow(for: openCycle)
            }
            return
        }

        let newCycle = Cycle(id: UUID(), startDate: day, endDate: nil)
        try await cycleRepository.upsertCycle(newCycle)
        await healthKitSyncService.syncMenstrualFlow(for: newCycle)
    }
}
