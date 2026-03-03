import SwiftUI

struct SymptomFormCard: View {
    @Binding var isExpanded: Bool
    @Binding var selectedSymptoms: Set<SymptomType>
    @Binding var note: String
    let hasExistingEntry: Bool
    let onSave: () -> Void

    var body: some View {
        AppCard {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 12) {
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

                    noteEditor(
                        placeholder: "Nota opcional",
                        text: $note
                    )

                    Button(hasExistingEntry ? "Actualizar síntomas" : "Guardar síntomas", action: onSave)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.symptom)
                }
                .padding(.top, 8)
            }
            label: {
                SectionHeader(title: "Síntomas")
            }
        }
    }

    private func toggle(_ symptom: SymptomType) {
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }

    @ViewBuilder
    private func noteEditor(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))

            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }

            TextEditor(text: text)
                .font(AppTypography.body)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
        .frame(minHeight: 110)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        )
    }
}
