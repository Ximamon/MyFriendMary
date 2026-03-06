import SwiftUI

struct SummaryView: View {
    @StateObject private var viewModel: SummaryViewModel

    init(container: AppContainer) {
        _viewModel = StateObject(
            wrappedValue: SummaryViewModel(
                predictUseCase: container.predictCycleSummaryUseCase,
                ringStatusUseCase: container.getRingStatusUseCase,
                yearOrgasmMetricsUseCase: container.getYearOrgasmMetricsUseCase
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                    SectionHeader(title: "Fase actual")

                    AppCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.summary.estimatedPhase.displayName)
                                    .font(AppTypography.title)
                                Text("Estimación basada en historial local")
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            Spacer()
                            StatusChip(text: phaseBadge, color: phaseColor)
                        }
                    }

                    SectionHeader(title: "Próxima regla")
                    AppCard {
                        Text(daysUntilPeriodText)
                            .font(AppTypography.number)
                        if let nextPeriodStart = viewModel.summary.nextPeriodStart {
                            Text("Inicio estimado: \(nextPeriodStart.formatted(date: .abbreviated, time: .omitted))")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    SectionHeader(title: "Ventana fértil")
                    AppCard {
                        if let fertileStart = viewModel.summary.fertileWindowStart,
                           let fertileEnd = viewModel.summary.fertileWindowEnd {
                            Text("\(fertileStart.formatted(date: .abbreviated, time: .omitted)) - \(fertileEnd.formatted(date: .abbreviated, time: .omitted))")
                                .font(AppTypography.section)
                            if let ovulationDate = viewModel.summary.ovulationDate {
                                Text("Ovulación estimada: \(ovulationDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                            if viewModel.ringStatus.isPlanActive {
                                Text("Estimación fértil general; puede ser menos representativa con anticoncepción hormonal.")
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        } else {
                            Text(
                                viewModel.summary.estimatedPhase == .menstruacion
                                ? "No se muestra durante regla activa."
                                : "Sin historial suficiente"
                            )
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }

                    SectionHeader(title: "Métricas del año")
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Orgasmos acumulados: \(viewModel.orgasmMetrics.totalOrgasmsYTD)")
                                .font(AppTypography.section)

                            if let bestDay = viewModel.orgasmMetrics.bestDayOfYear {
                                Text(
                                    "Mejor día: \(bestDay.formatted(date: .abbreviated, time: .omitted)) (\(viewModel.orgasmMetrics.bestDayOrgasmCount))"
                                )
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.textSecondary)
                            } else {
                                Text("Mejor día: sin datos")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }

                    if viewModel.ringStatus.isPlanActive {
                        SectionHeader(title: "Anticoncepción")
                        AppCard {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(viewModel.ringStatus.method?.displayName ?? "Anillo vaginal")
                                        .font(AppTypography.section)
                                    Text("Estado: \(viewModel.ringStatus.state.displayName)")
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppColors.textSecondary)
                                    if let nextTransition = viewModel.ringStatus.nextTransitionDate {
                                        Text("Próximo cambio: \(nextTransition.formatted(date: .abbreviated, time: .omitted))")
                                            .font(AppTypography.footnote)
                                            .foregroundStyle(AppColors.textSecondary)
                                    }
                                }
                                Spacer()
                                StatusChip(
                                    text: viewModel.ringStatus.state == .uso ? "Uso" : "Descanso",
                                    color: viewModel.ringStatus.state == .uso ? AppColors.ringUsage : AppColors.ringBreak
                                )
                            }
                        }
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
            .navigationTitle("Resumen")
            .task {
                await viewModel.refresh()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private var daysUntilPeriodText: String {
        guard let days = viewModel.summary.daysUntilNextPeriod else {
            return "Sin estimación"
        }
        if days == 0 {
            return "Hoy"
        }
        if days == 1 {
            return "1 día"
        }
        return "\(days) días"
    }

    private var phaseBadge: String {
        switch viewModel.summary.estimatedPhase {
        case .menstruacion:
            return "Menstruación"
        case .fertil:
            return "Fértil"
        case .folicular:
            return "Folicular"
        case .lutea:
            return "Lútea"
        case .desconocida:
            return "Sin datos"
        }
    }

    private var phaseColor: Color {
        switch viewModel.summary.estimatedPhase {
        case .menstruacion:
            return AppColors.period
        case .fertil:
            return AppColors.fertile
        case .folicular:
            return AppColors.accent
        case .lutea:
            return AppColors.encounter
        case .desconocida:
            return .gray
        }
    }
}
