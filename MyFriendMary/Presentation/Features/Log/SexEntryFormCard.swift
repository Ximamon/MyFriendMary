import SwiftUI

struct SexEntryFormCard: View {
    @Binding var orgasmCount: Int
    @Binding var selectedTypes: Set<SexType>
    @Binding var note: String
    let onSave: () -> Void

    var body: some View {
        AppCard {
            SectionHeader(title: "Encuentro")

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

            TextField("Nota privada", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            Button("Guardar encuentro", action: onSave)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.encounter)
        }
    }

    private func toggle(_ type: SexType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
    }
}
