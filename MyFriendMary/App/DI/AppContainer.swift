import Foundation
import Combine
import SwiftData

@MainActor
final class AppContainer: ObservableObject {
    let modelContainer: ModelContainer

    let profileRepository: ProfileRepository
    let cycleRepository: CycleRepository
    let symptomRepository: SymptomRepository
    let sexEntryRepository: SexEntryRepository

    let predictionService: PredictionService
    let notificationScheduler: NotificationScheduler
    let healthKitSyncService: HealthKitSyncService
    let biometricAuthService: BiometricAuthService
    let dataExportService: DataExportService

    let logPeriodUseCase: LogPeriodUseCase
    let endPeriodUseCase: EndPeriodUseCase
    let logSymptomsUseCase: LogSymptomsUseCase
    let logSexEntryUseCase: LogSexEntryUseCase
    let predictCycleSummaryUseCase: PredictCycleSummaryUseCase
    let getCalendarMarksUseCase: GetCalendarMarksUseCase
    let exportDataUseCase: ExportDataUseCase
    let wipeAllUseCase: WipeAllUseCase

    init(inMemory: Bool = false) {
        let stack: SwiftDataStack
        do {
            stack = try SwiftDataStack(inMemory: inMemory)
        } catch {
            fatalError("No se pudo inicializar SwiftData: \(error)")
        }

        let modelContainer = stack.container
        let context = modelContainer.mainContext

        let keychainStore = KeychainStore()
        let cryptoService = AESCryptoService(keychainStore: keychainStore)

        let profileRepository = SwiftDataProfileRepository(context: context)
        let cycleRepository = SwiftDataCycleRepository(context: context)
        let symptomRepository = SwiftDataSymptomRepository(context: context)
        let sexEntryRepository = SwiftDataSexEntryRepository(context: context, cryptoService: cryptoService)

        let predictionService = DefaultPredictionService()
        let notificationScheduler = LocalNotificationScheduler()
        let healthKitSyncService = HealthKitSyncAdapter(client: DefaultHealthKitClient())
        let biometricAuthService = LocalBiometricAuthService()
        let exportService = JSONDataExportService(
            profileRepository: profileRepository,
            cycleRepository: cycleRepository,
            symptomRepository: symptomRepository,
            sexEntryRepository: sexEntryRepository
        )

        let wipeStore = WipeAllRepository(context: context)

        self.modelContainer = modelContainer

        self.profileRepository = profileRepository
        self.cycleRepository = cycleRepository
        self.symptomRepository = symptomRepository
        self.sexEntryRepository = sexEntryRepository

        self.predictionService = predictionService
        self.notificationScheduler = notificationScheduler
        self.healthKitSyncService = healthKitSyncService
        self.biometricAuthService = biometricAuthService
        self.dataExportService = exportService

        self.logPeriodUseCase = DefaultLogPeriodUseCase(
            cycleRepository: cycleRepository,
            healthKitSyncService: healthKitSyncService
        )
        self.endPeriodUseCase = DefaultEndPeriodUseCase(
            cycleRepository: cycleRepository,
            healthKitSyncService: healthKitSyncService
        )
        self.logSymptomsUseCase = DefaultLogSymptomsUseCase(repository: symptomRepository)
        self.logSexEntryUseCase = DefaultLogSexEntryUseCase(repository: sexEntryRepository)
        self.predictCycleSummaryUseCase = DefaultPredictCycleSummaryUseCase(
            profileRepository: profileRepository,
            cycleRepository: cycleRepository,
            predictionService: predictionService
        )
        self.getCalendarMarksUseCase = DefaultGetCalendarMarksUseCase(
            cycleRepository: cycleRepository,
            symptomRepository: symptomRepository,
            sexEntryRepository: sexEntryRepository,
            profileRepository: profileRepository,
            predictionService: predictionService
        )
        self.exportDataUseCase = DefaultExportDataUseCase(exportService: exportService)
        self.wipeAllUseCase = DefaultWipeAllUseCase(dataStore: wipeStore)
    }

    static var preview: AppContainer {
        AppContainer(inMemory: true)
    }
}
