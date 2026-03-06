import Foundation
import Combine

@MainActor
final class SummaryViewModel: ObservableObject {
    @Published private(set) var summary: CycleSummary = .empty(today: Date())
    @Published private(set) var ringStatus: RingStatusSnapshot = .empty(day: Date())
    @Published private(set) var orgasmMetrics: YearOrgasmMetrics = .empty(for: Calendar.current.component(.year, from: Date()))
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let predictUseCase: PredictCycleSummaryUseCase
    private let ringStatusUseCase: GetRingStatusUseCase
    private let yearOrgasmMetricsUseCase: GetYearOrgasmMetricsUseCase

    init(
        predictUseCase: PredictCycleSummaryUseCase,
        ringStatusUseCase: GetRingStatusUseCase,
        yearOrgasmMetricsUseCase: GetYearOrgasmMetricsUseCase
    ) {
        self.predictUseCase = predictUseCase
        self.ringStatusUseCase = ringStatusUseCase
        self.yearOrgasmMetricsUseCase = yearOrgasmMetricsUseCase
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            summary = try await predictUseCase.execute(today: Date())
            ringStatus = try await ringStatusUseCase.execute(day: Date())
            orgasmMetrics = try await yearOrgasmMetricsUseCase.execute(for: Date())
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo cargar el resumen."
        }
    }
}
