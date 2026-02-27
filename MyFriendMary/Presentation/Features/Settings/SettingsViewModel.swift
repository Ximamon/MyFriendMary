import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var cycleLengthDefault: Int = 28
    @Published var periodLengthDefault: Int = 5
    @Published var isDiscreteModeOn: Bool = false
    @Published var isBiometricLockOn: Bool = false
    @Published var biometricScope: BiometricScope = .appCompleta

    @Published var exportURL: URL?
    @Published var statusMessage: String?
    @Published var errorMessage: String?
    @Published private(set) var isLoading = false

    private let profileRepository: ProfileRepository
    private let predictSummaryUseCase: PredictCycleSummaryUseCase
    private let scheduler: NotificationScheduler
    private let exportDataUseCase: ExportDataUseCase
    private let wipeAllUseCase: WipeAllUseCase

    init(
        profileRepository: ProfileRepository,
        predictSummaryUseCase: PredictCycleSummaryUseCase,
        scheduler: NotificationScheduler,
        exportDataUseCase: ExportDataUseCase,
        wipeAllUseCase: WipeAllUseCase
    ) {
        self.profileRepository = profileRepository
        self.predictSummaryUseCase = predictSummaryUseCase
        self.scheduler = scheduler
        self.exportDataUseCase = exportDataUseCase
        self.wipeAllUseCase = wipeAllUseCase
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let profile = try await profileRepository.getProfile()
            cycleLengthDefault = profile.cycleLengthDefault
            periodLengthDefault = profile.periodLengthDefault
            isDiscreteModeOn = profile.isDiscreteModeOn
            isBiometricLockOn = profile.isBiometricLockOn
            biometricScope = profile.biometricScope
            errorMessage = nil
        } catch {
            errorMessage = "No se pudieron cargar los ajustes."
        }
    }

    func save() async {
        do {
            let profile = UserProfile(
                cycleLengthDefault: cycleLengthDefault,
                periodLengthDefault: periodLengthDefault,
                isDiscreteModeOn: isDiscreteModeOn,
                isBiometricLockOn: isBiometricLockOn,
                biometricScope: biometricScope
            )
            try await profileRepository.saveProfile(profile)

            let summary = try await predictSummaryUseCase.execute(today: Date())
            await scheduler.reschedule(using: profile, summary: summary)

            statusMessage = "Ajustes guardados."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudieron guardar los ajustes."
        }
    }

    func exportData() async {
        do {
            exportURL = try await exportDataUseCase.execute()
            statusMessage = "Exportación lista."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo exportar la información."
        }
    }

    func wipeAll() async {
        do {
            try await wipeAllUseCase.execute()
            await load()
            exportURL = nil
            statusMessage = "Todos los datos se han borrado."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudieron borrar los datos."
        }
    }
}
