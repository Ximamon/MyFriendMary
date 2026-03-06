import Foundation

protocol GetRingStatusUseCase {
    func execute(day: Date) async throws -> RingStatusSnapshot
}

@MainActor
final class DefaultGetRingStatusUseCase: GetRingStatusUseCase {
    private let repository: ContraceptivePlanRepository
    private let scheduleService: RingScheduleService

    init(
        repository: ContraceptivePlanRepository,
        scheduleService: RingScheduleService
    ) {
        self.repository = repository
        self.scheduleService = scheduleService
    }

    func execute(day: Date) async throws -> RingStatusSnapshot {
        let normalizedDay = DateNormalizer.startOfDay(day)
        guard let plan = try await repository.plan(containing: normalizedDay) else {
            return .empty(day: normalizedDay)
        }

        let state = scheduleService.state(on: normalizedDay, plan: plan)
        let nextTransition = scheduleService.nextTransition(on: normalizedDay, plan: plan)

        return RingStatusSnapshot(
            day: normalizedDay,
            isPlanActive: plan.endDate == nil,
            state: state,
            planStartDate: plan.startDate,
            planEndDate: plan.endDate,
            nextTransitionDate: nextTransition,
            method: plan.method
        )
    }
}
