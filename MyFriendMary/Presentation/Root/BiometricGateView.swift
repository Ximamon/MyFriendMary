import SwiftUI

struct BiometricGateView: View {
    let onUnlock: () async -> Bool

    @State private var isAuthenticating = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(AppColors.accent)

            Text("Contenido protegido")
                .font(AppTypography.title)

            Text("Autentícate para continuar.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)

            Button {
                Task {
                    await unlock()
                }
            } label: {
                if isAuthenticating {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("Desbloquear")
                        .font(AppTypography.section)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)

            if let errorMessage {
                Text(errorMessage)
                    .font(AppTypography.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding()
    }

    private func unlock() async {
        isAuthenticating = true
        defer { isAuthenticating = false }

        let didUnlock = await onUnlock()
        if !didUnlock {
            errorMessage = "No se pudo validar la autenticación."
        }
    }
}
