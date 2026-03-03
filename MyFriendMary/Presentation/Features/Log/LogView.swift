import SwiftUI

struct LogView: View {
    @ObservedObject private var container: AppContainer
    @StateObject private var viewModel: LogViewModel
    @State private var isSymptomsExpanded = false
    @State private var isSexExpanded = false

    init(container: AppContainer) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: LogViewModel(
                logPeriodUseCase: container.logPeriodUseCase,
                endPeriodUseCase: container.endPeriodUseCase,
                logSymptomsUseCase: container.logSymptomsUseCase,
                logSexEntryUseCase: container.logSexEntryUseCase,
                startRingPlanUseCase: container.startRingPlanUseCase,
                endRingPlanUseCase: container.endRingPlanUseCase,
                getRingStatusUseCase: container.getRingStatusUseCase,
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

                    RingFormCard(
                        snapshot: viewModel.ringStatus,
                        onStart: {
                            Task { await viewModel.startRingPlan() }
                        },
                        onEnd: {
                            Task { await viewModel.endRingPlan() }
                        }
                    )

                    SymptomFormCard(
                        isExpanded: $isSymptomsExpanded,
                        selectedSymptoms: $viewModel.selectedSymptoms,
                        note: $viewModel.symptomNote,
                        hasExistingEntry: viewModel.hasExistingSymptomEntry,
                        onSave: {
                            Task { await viewModel.saveSymptoms() }
                        }
                    )

                    SexEntryFormCard(
                        isExpanded: $isSexExpanded,
                        orgasmCount: $viewModel.orgasmCount,
                        selectedTypes: $viewModel.selectedSexTypes,
                        note: $viewModel.sexNote,
                        hasExistingEntry: viewModel.hasExistingSexEntry,
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
            .onChange(of: container.requestedLogDate) { _, newValue in
                guard let day = newValue else { return }

                viewModel.selectedDate = day
                Task {
                    await viewModel.loadEntriesForSelectedDate()
                    isSymptomsExpanded = viewModel.hasExistingSymptomEntry
                    isSexExpanded = viewModel.hasExistingSexEntry
                    container.consumeRequestedLogDate()
                }
            }
        }
    }
}
