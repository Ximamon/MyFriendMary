import SwiftUI

struct SymptomFormCard: View {
    @Binding var selectedSymptoms: Set<SymptomType>
    @Binding var note: String
    let onSave: () -> Void

    var body: some View {
        AppCard {
            SectionHeader(title: "Síntomas")

            ForEach(SymptomType.allCases, id: \.self) { symptom in
                Button {
                    toggle(symptom)
                } label: {
                    HStack {
                        Text(symptom.displayName)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Image(systemName: selectedSymptoms.contains(symptom) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedSymptoms.contains(symptom) ? AppColors.symptom : AppColors.textSecondary)
                    }
                }
                .buttonStyle(.plain)
            }

            TextField("Nota opcional", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            Button("Guardar síntomas", action: onSave)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.symptom)
        }
    }

    private func toggle(_ symptom: SymptomType) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
}
