import SwiftUI

struct PeriodFormCard: View {
    @Binding var selectedIntensity: PeriodIntensity?
    let isPeriodActive: Bool
    let onStart: () -> Void
    let onEnd: () -> Void

    var body: some View {
        AppCard {
            SectionHeader(title: "Periodo")

            Menu {
                Button("Sin sangrado") {
                    selectedIntensity = nil
                }

                ForEach(PeriodIntensity.allCases, id: \.self) { intensity in
                    Button(intensity.displayName) {
                        selectedIntensity = intensity
                    }
                }
            } label: {
                HStack {
                    Text("Sangrado")
                        .font(AppTypography.body)
                    Spacer()
                    Text(selectedIntensity?.displayName ?? "Sin sangrado")
                        .font(AppTypography.body.weight(.semibold))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )
            }

            HStack {
                if isPeriodActive {
                    Button("Iniciar periodo", action: onStart)
                        .buttonStyle(.bordered)
                        .tint(AppColors.period.opacity(0.45))
                        .disabled(true)

                    Button("Finalizar periodo", action: onEnd)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.period)
                        .disabled(false)
                } else {
                    Button("Iniciar periodo", action: onStart)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.period)
                        .disabled(false)

                    Button("Finalizar periodo", action: onEnd)
                        .buttonStyle(.bordered)
                        .tint(AppColors.period.opacity(0.45))
                        .disabled(true)
                }
            }
        }
    }
}
