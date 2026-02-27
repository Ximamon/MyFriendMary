import Foundation

protocol PredictCycleSummaryUseCase {
    func execute(today: Date) async throws -> CycleSummary
}

@MainActor
final class DefaultPredictCycleSummaryUseCase: PredictCycleSummaryUseCase {
    private let profileRepository: ProfileRepository
    private let cycleRepository: CycleRepository
    private let predictionService: PredictionService

    init(
        profileRepository: ProfileRepository,
        cycleRepository: CycleRepository,
        predictionService: PredictionService
    ) {
        self.profileRepository = profileRepository
        self.cycleRepository = cycleRepository
        self.predictionService = predictionService
    }

    func execute(today: Date) async throws -> CycleSummary {
        let profile = try await profileRepository.getProfile()
        let cycles = try await cycleRepository.fetchCycles()
        return predictionService.predictSummary(today: today, cycles: cycles, profile: profile)
    }
}
