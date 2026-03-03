import Foundation

protocol StartRingPlanUseCase {
    func execute(startDate: Date) async throws
}

@MainActor
final class DefaultStartRingPlanUseCase: StartRingPlanUseCase {
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

    func execute(startDate: Date) async throws {
        if try await repository.activePlan() != nil {
            throw ContraceptionDomainError.activePlanAlreadyExists
        }

        let normalizedStart = DateNormalizer.startOfDay(startDate)
        var plan = ContraceptivePlan.defaultRingPlan(startDate: normalizedStart)
        plan.createdAt = Date()
        plan.updatedAt = Date()

        try await repository.upsertPlan(plan)

        let profile = try await profileRepository.getProfile()
        await notificationScheduler.rescheduleRing(using: profile, activePlan: plan)
    }
}
