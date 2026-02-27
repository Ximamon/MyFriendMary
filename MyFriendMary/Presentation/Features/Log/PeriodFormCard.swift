import SwiftUI

struct PeriodFormCard: View {
    @Binding var selectedIntensity: PeriodIntensity?
    let onStart: () -> Void
    let onEnd: () -> Void

    var body: some View {
        AppCard {
            SectionHeader(title: "Periodo")

            Picker("Intensidad", selection: $selectedIntensity) {
                Text("Sin intensidad")
                    .tag(nil as PeriodIntensity?)
                ForEach(PeriodIntensity.allCases, id: \.self) { intensity in
                    Text(intensity.displayName).tag(intensity as PeriodIntensity?)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button("Hoy con regla", action: onStart)
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.period)

                Button("Finalizar periodo", action: onEnd)
                    .buttonStyle(.bordered)
            }
        }
    }
}
