import SwiftUI

struct MainTabView: View {
    @ObservedObject var container: AppContainer
    @Environment(\.scenePhase) private var scenePhase

    @State private var shouldRequireUnlock = false
    @State private var isUnlocked = false

    var body: some View {
        Group {
            if shouldRequireUnlock && !isUnlocked {
                BiometricGateView {
                    let didUnlock = await container.biometricAuthService.authenticate(reason: "Desbloquear MyFriendMary")
                    if didUnlock {
                        isUnlocked = true
                    }
                    return didUnlock
                }
            } else {
                TabView {
                    SummaryView(container: container)
                        .tabItem {
                            Label("Resumen", systemImage: "heart.text.square")
                        }

                    CalendarView(container: container)
                        .tabItem {
                            Label("Calendario", systemImage: "calendar")
                        }

                    LogView(container: container)
                        .tabItem {
                            Label("Registrar", systemImage: "plus.circle")
                        }

                    SettingsView(container: container)
                        .tabItem {
                            Label("Ajustes", systemImage: "gearshape")
                        }
                }
                .tint(AppColors.accent)
            }
        }
        .background(AppColors.background)
        .task {
            await loadLockState()
            await container.healthKitSyncService.requestPermissionsIfNeeded()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                Task {
                    await loadLockState()
                }
            }
            if newValue == .background {
                isUnlocked = false
            }
        }
    }

    private func loadLockState() async {
        do {
            let profile = try await container.profileRepository.getProfile()
            shouldRequireUnlock = profile.isBiometricLockOn && profile.biometricScope == .appCompleta
            if !shouldRequireUnlock {
                isUnlocked = true
            }
        } catch {
            shouldRequireUnlock = false
            isUnlocked = true
        }
    }
}
