import Foundation

protocol EndRingPlanUseCase {
    func execute(endDate: Date) async throws
}

@MainActor
final class DefaultEndRingPlanUseCase: EndRingPlanUseCase {
    private let repository: ContraceptivePlanRepository
    private let profileRepository: ProfileRepository
    private let notificationScheduler: ContraceptionNotificationScheduler

    init(
        repository: ContraceptivePlanRepository,
        profileRepository: ProfileRepository,
        notificationScheduler: ContraceptionNotificationScheduler
    ) {
        self.repository = repository
        self.profileRepository = profileRepository
        self.notificationScheduler = notificationScheduler
    }

    func execute(endDate: Date) async throws {
        guard var activePlan = try await repository.activePlan() else {
            throw ContraceptionDomainError.noActivePlan
        }

        let normalizedEnd = DateNormalizer.startOfDay(endDate)
        if normalizedEnd < DateNormalizer.startOfDay(activePlan.startDate) {
            throw ContraceptionDomainError.endDateBeforeStart
        }

        activePlan.endDate = normalizedEnd
        activePlan.updatedAt = Date()
        try await repository.upsertPlan(activePlan)

        let profile = try await profileRepository.getProfile()
        await notificationScheduler.rescheduleRing(using: profile, activePlan: nil)
    }
}
