import SwiftUI

struct SexEntryFormCard: View {
    @Binding var isExpanded: Bool
    @Binding var orgasmCount: Int
    @Binding var selectedTypes: Set<SexType>
    @Binding var note: String
    let hasExistingEntry: Bool
    let onSave: () -> Void

    var body: some View {
        AppCard {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading, spacing: 12) {
                    Stepper(value: $orgasmCount, in: 0...20) {
                        HStack {
                            Text("Orgasmos")
                            Spacer()
                            Text("\(orgasmCount)")
                                .font(AppTypography.section)
                        }
                    }

                    ForEach(SexType.allCases, id: \.self) { type in
                        Button {
                            toggle(type)
                        } label: {
                            HStack {
                                Text(type.displayName)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Image(systemName: selectedTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedTypes.contains(type) ? AppColors.encounter : AppColors.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    noteEditor(
                        placeholder: "Nota privada",
                        text: $note
                    )

                    Button(hasExistingEntry ? "Actualizar encuentro" : "Guardar encuentro", action: onSave)
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.encounter)
                }
                .padding(.top, 8)
            } label: {
                SectionHeader(title: "Encuentro")
            }
        }
    }

    private func toggle(_ type: SexType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
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
