import Foundation

protocol EndPeriodUseCase {
    func execute(date: Date) async throws
}

@MainActor
final class DefaultEndPeriodUseCase: EndPeriodUseCase {
    private let cycleRepository: CycleRepository
    private let healthKitSyncService: HealthKitSyncService

    init(cycleRepository: CycleRepository, healthKitSyncService: HealthKitSyncService) {
        self.cycleRepository = cycleRepository
        self.healthKitSyncService = healthKitSyncService
    }

    func execute(date: Date) async throws {
        let day = DateNormalizer.startOfDay(date)
        try await cycleRepository.closeOpenCycle(on: day)

        if let closedCycle = try await cycleRepository.fetchCycles().last(where: { $0.endDate != nil }) {
            await healthKitSyncService.syncMenstrualFlow(for: closedCycle)
        }
    }
}
