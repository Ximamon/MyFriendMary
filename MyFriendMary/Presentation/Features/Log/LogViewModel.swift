import Foundation
import Combine

@MainActor
final class LogViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var periodIntensity: PeriodIntensity? = nil
    @Published var isPeriodActive: Bool = false
    @Published var ringStatus: RingStatusSnapshot = .empty(day: Date())

    @Published var selectedSymptoms: Set<SymptomType> = []
    @Published var symptomNote: String = ""
    @Published var hasExistingSymptomEntry: Bool = false

    @Published var orgasmCount: Int = 0
    @Published var selectedSexTypes: Set<SexType> = []
    @Published var sexNote: String = ""
    @Published var hasExistingSexEntry: Bool = false

    @Published var statusMessage: String?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let logPeriodUseCase: LogPeriodUseCase
    private let endPeriodUseCase: EndPeriodUseCase
    private let savePeriodIntensityUseCase: SavePeriodIntensityUseCase
    private let logSymptomsUseCase: LogSymptomsUseCase
    private let logSexEntryUseCase: LogSexEntryUseCase
    private let startRingPlanUseCase: StartRingPlanUseCase
    private let registerRingRemovalUseCase: RegisterRingRemovalUseCase
    private let endRingPlanUseCase: EndRingPlanUseCase
    private let getRingStatusUseCase: GetRingStatusUseCase
    private let cycleRepository: CycleRepository
    private let periodEntryRepository: PeriodEntryRepository
    private let symptomRepository: SymptomRepository
    private let sexEntryRepository: SexEntryRepository

    init(
        logPeriodUseCase: LogPeriodUseCase,
        endPeriodUseCase: EndPeriodUseCase,
        savePeriodIntensityUseCase: SavePeriodIntensityUseCase,
        logSymptomsUseCase: LogSymptomsUseCase,
        logSexEntryUseCase: LogSexEntryUseCase,
        startRingPlanUseCase: StartRingPlanUseCase,
        registerRingRemovalUseCase: RegisterRingRemovalUseCase,
        endRingPlanUseCase: EndRingPlanUseCase,
        getRingStatusUseCase: GetRingStatusUseCase,
        cycleRepository: CycleRepository,
        periodEntryRepository: PeriodEntryRepository,
        symptomRepository: SymptomRepository,
        sexEntryRepository: SexEntryRepository
    ) {
        self.logPeriodUseCase = logPeriodUseCase
        self.endPeriodUseCase = endPeriodUseCase
        self.savePeriodIntensityUseCase = savePeriodIntensityUseCase
        self.logSymptomsUseCase = logSymptomsUseCase
        self.logSexEntryUseCase = logSexEntryUseCase
        self.startRingPlanUseCase = startRingPlanUseCase
        self.registerRingRemovalUseCase = registerRingRemovalUseCase
        self.endRingPlanUseCase = endRingPlanUseCase
        self.getRingStatusUseCase = getRingStatusUseCase
        self.cycleRepository = cycleRepository
        self.periodEntryRepository = periodEntryRepository
        self.symptomRepository = symptomRepository
        self.sexEntryRepository = sexEntryRepository
    }

    func loadEntriesForSelectedDate() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let day = DateNormalizer.startOfDay(selectedDate)

            let periodEntry = try await periodEntryRepository.entry(for: day)
            periodIntensity = periodEntry?.intensity

            if let symptomEntry = try await symptomRepository.entry(for: day) {
                selectedSymptoms = Set(symptomEntry.symptoms)
                symptomNote = symptomEntry.note ?? ""
                hasExistingSymptomEntry = true
            } else {
                selectedSymptoms = []
                symptomNote = ""
                hasExistingSymptomEntry = false
            }

            if let sexEntry = try await sexEntryRepository.entry(for: day) {
                orgasmCount = sexEntry.orgasmCount
                selectedSexTypes = sexEntry.types
                sexNote = sexEntry.note ?? ""
                hasExistingSexEntry = true
            } else {
                orgasmCount = 0
                selectedSexTypes = []
                sexNote = ""
                hasExistingSexEntry = false
            }

            try await refreshPeriodState()
            try await refreshRingStatus(for: day)

            errorMessage = nil
        } catch {
            errorMessage = "No se pudieron cargar los registros del día."
        }
    }

    func logPeriodStart(realStartDate: Date?) async {
        do {
            try await logPeriodUseCase.execute(
                date: selectedDate,
                realStartDate: realStartDate,
                intensity: periodIntensity
            )
            try await refreshPeriodState()
            statusMessage = "Periodo registrado."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo registrar el periodo."
        }
    }

    func savePeriodIntensity(_ intensity: PeriodIntensity?) async {
        do {
            periodIntensity = intensity
            try await savePeriodIntensityUseCase.execute(date: selectedDate, intensity: intensity)
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo guardar el sangrado del día."
        }
    }

    func logPeriodEnd() async {
        do {
            try await endPeriodUseCase.execute(date: selectedDate)
            try await refreshPeriodState()
            statusMessage = "Fin de periodo registrado."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo cerrar el periodo."
        }
    }

    func saveSymptoms() async {
        do {
            try await logSymptomsUseCase.execute(
                date: selectedDate,
                symptoms: Array(selectedSymptoms).sorted { $0.rawValue < $1.rawValue },
                note: symptomNote
            )
            hasExistingSymptomEntry = true
            statusMessage = "Síntomas guardados."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudieron guardar los síntomas."
        }
    }

    func saveSexEntry() async {
        do {
            try await logSexEntryUseCase.execute(
                date: selectedDate,
                orgasmCount: orgasmCount,
                types: selectedSexTypes,
                note: sexNote
            )
            hasExistingSexEntry = true
            statusMessage = "Encuentro guardado."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo guardar el encuentro."
        }
    }

    func startRingPlan(nextRemovalDate: Date) async {
        do {
            try await startRingPlanUseCase.execute(nextRemovalDate: nextRemovalDate)
            try await refreshRingStatus(for: selectedDate)
            statusMessage = "Plan de anillo iniciado."
            errorMessage = nil
        } catch {
            errorMessage = readableError(error)
        }
    }

    func registerRingRemoval(removalDate: Date) async {
        do {
            try await registerRingRemovalUseCase.execute(removalDate: removalDate)
            try await refreshRingStatus(for: selectedDate)
            statusMessage = "Retirada de anillo registrada."
            errorMessage = nil
        } catch {
            errorMessage = readableError(error)
        }
    }

    func endRingPlan() async {
        do {
            try await endRingPlanUseCase.execute(endDate: selectedDate)
            try await refreshRingStatus(for: selectedDate)
            statusMessage = "Seguimiento de anillo detenido."
            errorMessage = nil
        } catch {
            errorMessage = readableError(error)
        }
    }

    private func refreshPeriodState() async throws {
        isPeriodActive = try await cycleRepository.getOpenCycle() != nil
    }

    private func refreshRingStatus(for day: Date) async throws {
        ringStatus = try await getRingStatusUseCase.execute(day: day)
    }

    private func readableError(_ error: Error) -> String {
        if let localized = (error as? LocalizedError)?.errorDescription {
            return localized
        }
        return "No se pudo actualizar el plan de anillo."
    }
}
