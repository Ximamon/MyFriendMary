import Foundation

protocol RegisterRingRemovalUseCase {
    func execute(removalDate: Date) async throws
}

@MainActor
final class DefaultRegisterRingRemovalUseCase: RegisterRingRemovalUseCase {
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

    func execute(removalDate: Date) async throws {
        guard var activePlan = try await repository.activePlan() else {
            throw ContraceptionDomainError.noActivePlan
        }

        let normalizedRemoval = DateNormalizer.startOfDay(removalDate)
        let newStart = DateNormalizer.addingDays(-activePlan.ringDays, to: normalizedRemoval)
        guard newStart <= normalizedRemoval else {
            throw ContraceptionDomainError.invalidNextRemovalDate
        }

        activePlan.startDate = newStart
        activePlan.updatedAt = Date()
        try await repository.upsertPlan(activePlan)

        let profile = try await profileRepository.getProfile()
        await notificationScheduler.rescheduleRing(using: profile, activePlan: activePlan)
    }
}
