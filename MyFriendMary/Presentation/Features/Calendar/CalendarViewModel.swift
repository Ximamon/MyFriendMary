import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var displayMonth: Date = Date()
    @Published private(set) var marks: [CalendarDayMark] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let useCase: GetCalendarMarksUseCase

    init(useCase: GetCalendarMarksUseCase) {
        self.useCase = useCase
    }

    func loadMarks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            marks = try await useCase.execute(monthAnchor: displayMonth)
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo cargar el calendario."
        }
    }

    func goToPreviousMonth() async {
        displayMonth = Calendar.current.date(byAdding: .month, value: -1, to: displayMonth) ?? displayMonth
        await loadMarks()
    }

    func goToNextMonth() async {
        displayMonth = Calendar.current.date(byAdding: .month, value: 1, to: displayMonth) ?? displayMonth
        await loadMarks()
    }
}
