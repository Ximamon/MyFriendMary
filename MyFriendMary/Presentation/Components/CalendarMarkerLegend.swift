import SwiftUI

struct CalendarMarkerLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Leyenda")
            HStack(spacing: 12) {
                legendItem(color: AppColors.period, title: "Periodo")
                legendItem(color: AppColors.fertile, title: "Fértil")
            }
            HStack(spacing: 12) {
                legendItem(color: AppColors.symptom, title: "Síntomas")
                legendItem(color: AppColors.encounter, title: "Encuentro")
            }
            HStack(spacing: 12) {
                legendItem(color: AppColors.ringUsage, title: "Anillo (uso)")
                legendItem(color: AppColors.ringBreak, title: "Anillo (descanso)")
            }
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                    Text("Pico orgasmos")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
