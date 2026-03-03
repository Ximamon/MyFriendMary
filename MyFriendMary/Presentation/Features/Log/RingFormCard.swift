import SwiftUI

struct RingFormCard: View {
    let snapshot: RingStatusSnapshot
    let onStart: () -> Void
    let onEnd: () -> Void

    var body: some View {
        AppCard {
            SectionHeader(title: "Anillo vaginal")

            HStack {
                Text("Estado")
                    .font(AppTypography.body)
                Spacer()
                StatusChip(
                    text: snapshot.state.displayName,
                    color: chipColor
                )
            }

            if let planStartDate = snapshot.planStartDate {
                Text("Inicio del plan: \(planStartDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }

            if let nextTransitionDate = snapshot.nextTransitionDate {
                Text("Próximo cambio: \(nextTransitionDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack {
                if snapshot.isPlanActive {
                    Button("Iniciar anillo", action: onStart)
                        .buttonStyle(.bordered)
                        .tint(AppColors.ringUsage.opacity(0.45))
                        .disabled(true)

                    Button("Finalizar anillo", action: onEnd)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.ringUsage)
                } else {
                    Button("Iniciar anillo", action: onStart)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.ringUsage)

                    Button("Finalizar anillo", action: onEnd)
                        .buttonStyle(.bordered)
                        .tint(AppColors.ringUsage.opacity(0.45))
                        .disabled(true)
                }
            }
        }
    }

    private var chipColor: Color {
        switch snapshot.state {
        case .uso:
            return AppColors.ringUsage
        case .descanso:
            return AppColors.ringBreak
        case .sinPlan:
            return .gray
        }
    }
}
