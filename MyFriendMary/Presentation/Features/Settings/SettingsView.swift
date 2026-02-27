import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showWipeConfirmation = false

    init(container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: SettingsViewModel(
                profileRepository: container.profileRepository,
                predictSummaryUseCase: container.predictCycleSummaryUseCase,
                scheduler: container.notificationScheduler,
                exportDataUseCase: container.exportDataUseCase,
                wipeAllUseCase: container.wipeAllUseCase
            )
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Defaults") {
                    Stepper(value: $viewModel.cycleLengthDefault, in: 20...45) {
                        Text("Longitud ciclo: \(viewModel.cycleLengthDefault) días")
                    }
                    Stepper(value: $viewModel.periodLengthDefault, in: 2...10) {
                        Text("Duración periodo: \(viewModel.periodLengthDefault) días")
                    }
                }

                Section("Privacidad") {
                    Toggle("Modo discreto", isOn: $viewModel.isDiscreteModeOn)
                    Toggle("Bloqueo biométrico", isOn: $viewModel.isBiometricLockOn)

                    if viewModel.isBiometricLockOn {
                        Picker("Ámbito", selection: $viewModel.biometricScope) {
                            ForEach(BiometricScope.allCases, id: \.self) { scope in
                                Text(scope.displayName).tag(scope)
                            }
                        }
                    }
                }

                Section("Notificaciones") {
                    Text("Recordatorios de regla prevista y ventana fértil (stub en esta fase).")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Section("Datos") {
                    Button("Guardar ajustes") {
                        Task { await viewModel.save() }
                    }

                    Button("Exportar datos (JSON)") {
                        Task { await viewModel.exportData() }
                    }

                    if let url = viewModel.exportURL {
                        ShareLink(item: url) {
                            Text("Compartir exportación")
                        }
                    }

                    Button(role: .destructive) {
                        showWipeConfirmation = true
                    } label: {
                        Text("Borrar todo")
                    }
                }

                if let statusMessage = viewModel.statusMessage {
                    Section {
                        Text(statusMessage)
                            .font(AppTypography.footnote)
                            .foregroundStyle(.green)
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(AppTypography.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .task {
                await viewModel.load()
            }
            .alert("¿Borrar todos los datos?", isPresented: $showWipeConfirmation) {
                Button("Cancelar", role: .cancel) {}
                Button("Borrar", role: .destructive) {
                    Task { await viewModel.wipeAll() }
                }
            } message: {
                Text("Esta acción eliminará periodo, síntomas, encuentros y ajustes.")
            }
        }
    }
}
