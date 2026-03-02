import SwiftUI

struct LogView: View {
    @StateObject private var viewModel: LogViewModel
    @State private var isSymptomsExpanded = false
    @State private var isSexExpanded = false

    init(container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: LogViewModel(
                logPeriodUseCase: container.logPeriodUseCase,
                endPeriodUseCase: container.endPeriodUseCase,
                logSymptomsUseCase: container.logSymptomsUseCase,
                logSexEntryUseCase: container.logSexEntryUseCase,
                cycleRepository: container.cycleRepository,
                symptomRepository: container.symptomRepository,
                sexEntryRepository: container.sexEntryRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                    AppCard {
                        SectionHeader(title: "Día")
                        DatePicker(
                            "Fecha",
                            selection: $viewModel.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }

                    PeriodFormCard(
                        selectedIntensity: $viewModel.periodIntensity,
                        isPeriodActive: viewModel.isPeriodActive,
                        onStart: {
                            Task { await viewModel.logPeriodStart() }
                        },
                        onEnd: {
                            Task { await viewModel.logPeriodEnd() }
                        }
                    )

                    SymptomFormCard(
                        isExpanded: $isSymptomsExpanded,
                        selectedSymptoms: $viewModel.selectedSymptoms,
                        note: $viewModel.symptomNote,
                        onSave: {
                            Task { await viewModel.saveSymptoms() }
                        }
                    )

                    SexEntryFormCard(
                        isExpanded: $isSexExpanded,
                        orgasmCount: $viewModel.orgasmCount,
                        selectedTypes: $viewModel.selectedSexTypes,
                        note: $viewModel.sexNote,
                        onSave: {
                            Task { await viewModel.saveSexEntry() }
                        }
                    )

                    if let statusMessage = viewModel.statusMessage {
                        Text(statusMessage)
                            .font(AppTypography.footnote)
                            .foregroundStyle(.green)
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
            .navigationTitle("Registrar")
            .task {
                await viewModel.loadEntriesForSelectedDate()
            }
            .onChange(of: viewModel.selectedDate) { _, _ in
                Task { await viewModel.loadEntriesForSelectedDate() }
            }
        }
    }
}
