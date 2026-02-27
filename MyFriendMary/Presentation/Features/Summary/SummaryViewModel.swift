import Foundation
import Combine

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published private(set) var summary: CycleSummary = .empty(today: Date())
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let predictUseCase: PredictCycleSummaryUseCase

    init(predictUseCase: PredictCycleSummaryUseCase) {
        self.predictUseCase = predictUseCase
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            summary = try await predictUseCase.execute(today: Date())
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo cargar el resumen."
        }
    }
}
