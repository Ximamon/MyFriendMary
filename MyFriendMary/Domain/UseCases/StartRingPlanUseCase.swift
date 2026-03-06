import Foundation

protocol StartRingPlanUseCase {
    func execute(nextRemovalDate: Date) async throws
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

    func execute(nextRemovalDate: Date) async throws {
        if try await repository.activePlan() != nil {
            throw ContraceptionDomainError.activePlanAlreadyExists
        }

        let normalizedRemoval = DateNormalizer.startOfDay(nextRemovalDate)
        let ringDays = 21
        let normalizedStart = DateNormalizer.addingDays(-ringDays, to: normalizedRemoval)
        guard normalizedStart <= normalizedRemoval else {
            throw ContraceptionDomainError.invalidNextRemovalDate
        }

        var plan = ContraceptivePlan.defaultRingPlan(startDate: normalizedStart)
        plan.createdAt = Date()
        plan.updatedAt = Date()

        try await repository.upsertPlan(plan)

        let profile = try await profileRepository.getProfile()
        await notificationScheduler.rescheduleRing(using: profile, activePlan: plan)
    }
}
