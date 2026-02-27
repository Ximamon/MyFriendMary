import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel: CalendarViewModel

    init(container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: CalendarViewModel(useCase: container.getCalendarMarksUseCase)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                    AppCard {
                        HStack {
                            Button {
                                Task { await viewModel.goToPreviousMonth() }
                            } label: {
                                Image(systemName: "chevron.left")
                            }

                            Spacer()

                            Text(viewModel.displayMonth.formatted(.dateTime.month(.wide).year()))
                                .font(AppTypography.section)

                            Spacer()

                            Button {
                                Task { await viewModel.goToNextMonth() }
                            } label: {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .buttonStyle(.borderless)

                        MonthGridView(month: viewModel.displayMonth, marks: viewModel.marks)
                    }

                    AppCard {
                        CalendarMarkerLegend()
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(AppTypography.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Calendario")
            .task {
                await viewModel.loadMarks()
            }
            .refreshable {
                await viewModel.loadMarks()
            }
        }
    }
}
