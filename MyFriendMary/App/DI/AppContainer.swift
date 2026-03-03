import Foundation
import Combine
import SwiftData

enum AppTab: Hashable {
    case summary
    case calendar
    case log
    case settings
}

@MainActor
final class AppContainer: ObservableObject {
    @Published var selectedTab: AppTab = .summary
    @Published var requestedLogDate: Date?

    let modelContainer: ModelContainer

    let profileRepository: ProfileRepository
    let cycleRepository: CycleRepository
    let symptomRepository: SymptomRepository
    let sexEntryRepository: SexEntryRepository
    let contraceptivePlanRepository: ContraceptivePlanRepository

    let predictionService: PredictionService
    let ringScheduleService: RingScheduleService
    let notificationScheduler: NotificationScheduler
    let contraceptionNotificationScheduler: ContraceptionNotificationScheduler
    let healthKitSyncService: HealthKitSyncService
    let biometricAuthService: BiometricAuthService
    let dataExportService: DataExportService

    let logPeriodUseCase: LogPeriodUseCase
    let endPeriodUseCase: EndPeriodUseCase
    let logSymptomsUseCase: LogSymptomsUseCase
    let logSexEntryUseCase: LogSexEntryUseCase
    let startRingPlanUseCase: StartRingPlanUseCase
    let endRingPlanUseCase: EndRingPlanUseCase
    let getRingStatusUseCase: GetRingStatusUseCase
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
        let contraceptivePlanRepository = SwiftDataContraceptivePlanRepository(context: context)

        let predictionService = DefaultPredictionService()
        let ringScheduleService = DefaultRingScheduleService()
        let notificationScheduler = LocalNotificationScheduler()
        let contraceptionNotificationScheduler = LocalContraceptionNotificationScheduler()
        let healthKitSyncService = HealthKitSyncAdapter(client: DefaultHealthKitClient())
        let biometricAuthService = LocalBiometricAuthService()
        let exportService = JSONDataExportService(
            profileRepository: profileRepository,
            cycleRepository: cycleRepository,
            symptomRepository: symptomRepository,
            sexEntryRepository: sexEntryRepository,
            contraceptivePlanRepository: contraceptivePlanRepository
        )

        let wipeStore = WipeAllRepository(context: context)

        self.modelContainer = modelContainer

        self.profileRepository = profileRepository
        self.cycleRepository = cycleRepository
        self.symptomRepository = symptomRepository
        self.sexEntryRepository = sexEntryRepository
        self.contraceptivePlanRepository = contraceptivePlanRepository

        self.predictionService = predictionService
        self.ringScheduleService = ringScheduleService
        self.notificationScheduler = notificationScheduler
        self.contraceptionNotificationScheduler = contraceptionNotificationScheduler
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
        self.startRingPlanUseCase = DefaultStartRingPlanUseCase(
            repository: contraceptivePlanRepository,
            profileRepository: profileRepository,
            notificationScheduler: contraceptionNotificationScheduler
        )
        self.endRingPlanUseCase = DefaultEndRingPlanUseCase(
            repository: contraceptivePlanRepository,
            profileRepository: profileRepository,
            notificationScheduler: contraceptionNotificationScheduler
        )
        self.getRingStatusUseCase = DefaultGetRingStatusUseCase(
            repository: contraceptivePlanRepository,
            scheduleService: ringScheduleService
        )
        self.predictCycleSummaryUseCase = DefaultPredictCycleSummaryUseCase(
            profileRepository: profileRepository,
            cycleRepository: cycleRepository,
            predictionService: predictionService
        )
        self.getCalendarMarksUseCase = DefaultGetCalendarMarksUseCase(
            cycleRepository: cycleRepository,
            symptomRepository: symptomRepository,
            sexEntryRepository: sexEntryRepository,
            contraceptivePlanRepository: contraceptivePlanRepository,
            profileRepository: profileRepository,
            predictionService: predictionService,
            ringScheduleService: ringScheduleService
        )
        self.exportDataUseCase = DefaultExportDataUseCase(exportService: exportService)
        self.wipeAllUseCase = DefaultWipeAllUseCase(dataStore: wipeStore)
    }

    static var preview: AppContainer {
        AppContainer(inMemory: true)
    }

    func openLog(for day: Date) {
        requestedLogDate = DateNormalizer.startOfDay(day)
        selectedTab = .log
    }

    func consumeRequestedLogDate() {
        requestedLogDate = nil
    }
}
