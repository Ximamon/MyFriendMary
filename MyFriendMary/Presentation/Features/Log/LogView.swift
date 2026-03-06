import SwiftUI

struct LogView: View {
    @ObservedObject private var container: AppContainer
    @StateObject private var viewModel: LogViewModel
    @State private var isSymptomsExpanded = false
    @State private var isSexExpanded = false
    @State private var isPeriodStartSheetPresented = false
    @State private var periodRealStartDate = Date()
    @State private var isRingStartSheetPresented = false
    @State private var ringNextRemovalDate = Date()
    @State private var isRingRemovalSheetPresented = false
    @State private var ringRemovalDate = Date()

    init(container: AppContainer) {
        self.container = container
        _viewModel = StateObject(
            wrappedValue: LogViewModel(
                logPeriodUseCase: container.logPeriodUseCase,
                endPeriodUseCase: container.endPeriodUseCase,
                savePeriodIntensityUseCase: container.savePeriodIntensityUseCase,
                logSymptomsUseCase: container.logSymptomsUseCase,
                logSexEntryUseCase: container.logSexEntryUseCase,
                startRingPlanUseCase: container.startRingPlanUseCase,
                registerRingRemovalUseCase: container.registerRingRemovalUseCase,
                endRingPlanUseCase: container.endRingPlanUseCase,
                getRingStatusUseCase: container.getRingStatusUseCase,
                cycleRepository: container.cycleRepository,
                periodEntryRepository: container.periodEntryRepository,
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
                        onIntensitySelected: { intensity in
                            Task { await viewModel.savePeriodIntensity(intensity) }
                        },
                        onStart: {
                            periodRealStartDate = DateNormalizer.startOfDay(viewModel.selectedDate)
                            isPeriodStartSheetPresented = true
                        },
                        onEnd: {
                            Task { await viewModel.logPeriodEnd() }
                        }
                    )

                    RingFormCard(
                        snapshot: viewModel.ringStatus,
                        onStart: {
                            ringNextRemovalDate = DateNormalizer.addingDays(
                                21,
                                to: DateNormalizer.startOfDay(viewModel.selectedDate)
                            )
                            isRingStartSheetPresented = true
                        },
                        onRegisterRemoval: {
                            ringRemovalDate = DateNormalizer.startOfDay(viewModel.selectedDate)
                            isRingRemovalSheetPresented = true
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
            .sheet(isPresented: $isPeriodStartSheetPresented) {
                NavigationStack {
                    Form {
                        Section("Inicio real de la regla") {
                            DatePicker(
                                "Fecha",
                                selection: $periodRealStartDate,
                                in: ...DateNormalizer.startOfDay(viewModel.selectedDate),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }
                    }
                    .navigationTitle("Iniciar periodo")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                isPeriodStartSheetPresented = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                isPeriodStartSheetPresented = false
                                Task {
                                    await viewModel.logPeriodStart(realStartDate: periodRealStartDate)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isRingStartSheetPresented) {
                NavigationStack {
                    Form {
                        Section("¿Cuándo toca retirar el anillo?") {
                            DatePicker(
                                "Próxima retirada",
                                selection: $ringNextRemovalDate,
                                in: DateNormalizer.startOfDay(viewModel.selectedDate)...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }
                    }
                    .navigationTitle("Iniciar anillo")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                isRingStartSheetPresented = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                isRingStartSheetPresented = false
                                Task {
                                    await viewModel.startRingPlan(nextRemovalDate: ringNextRemovalDate)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isRingRemovalSheetPresented) {
                NavigationStack {
                    Form {
                        Section("Registrar retirada de anillo") {
                            DatePicker(
                                "Fecha de retirada",
                                selection: $ringRemovalDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }
                    }
                    .navigationTitle("Retirada")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancelar") {
                                isRingRemovalSheetPresented = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Guardar") {
                                isRingRemovalSheetPresented = false
                                Task {
                                    await viewModel.registerRingRemoval(removalDate: ringRemovalDate)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
