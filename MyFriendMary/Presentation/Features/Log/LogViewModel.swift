import Foundation
import Combine

@MainActor
final class LogViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var periodIntensity: PeriodIntensity? = nil
    @Published var isPeriodActive: Bool = false

    @Published var selectedSymptoms: Set<SymptomType> = []
    @Published var symptomNote: String = ""

    @Published var orgasmCount: Int = 0
    @Published var selectedSexTypes: Set<SexType> = []
    @Published var sexNote: String = ""

    @Published var statusMessage: String?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let logPeriodUseCase: LogPeriodUseCase
    private let endPeriodUseCase: EndPeriodUseCase
    private let logSymptomsUseCase: LogSymptomsUseCase
    private let logSexEntryUseCase: LogSexEntryUseCase
    private let cycleRepository: CycleRepository
    private let symptomRepository: SymptomRepository
    private let sexEntryRepository: SexEntryRepository

    init(
        logPeriodUseCase: LogPeriodUseCase,
        endPeriodUseCase: EndPeriodUseCase,
        logSymptomsUseCase: LogSymptomsUseCase,
        logSexEntryUseCase: LogSexEntryUseCase,
        cycleRepository: CycleRepository,
        symptomRepository: SymptomRepository,
        sexEntryRepository: SexEntryRepository
    ) {
        self.logPeriodUseCase = logPeriodUseCase
        self.endPeriodUseCase = endPeriodUseCase
        self.logSymptomsUseCase = logSymptomsUseCase
        self.logSexEntryUseCase = logSexEntryUseCase
        self.cycleRepository = cycleRepository
        self.symptomRepository = symptomRepository
        self.sexEntryRepository = sexEntryRepository
    }

    func loadEntriesForSelectedDate() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let day = DateNormalizer.startOfDay(selectedDate)

            if let symptomEntry = try await symptomRepository.entry(for: day) {
                selectedSymptoms = Set(symptomEntry.symptoms)
                symptomNote = symptomEntry.note ?? ""
            } else {
                selectedSymptoms = []
                symptomNote = ""
            }

            if let sexEntry = try await sexEntryRepository.entry(for: day) {
                orgasmCount = sexEntry.orgasmCount
                selectedSexTypes = sexEntry.types
                sexNote = sexEntry.note ?? ""
            } else {
                orgasmCount = 0
                selectedSexTypes = []
                sexNote = ""
            }

            try await refreshPeriodState()

            errorMessage = nil
        } catch {
            errorMessage = "No se pudieron cargar los registros del día."
        }
    }

    func logPeriodStart() async {
        do {
            try await logPeriodUseCase.execute(date: selectedDate, intensity: periodIntensity)
            try await refreshPeriodState()
            statusMessage = "Periodo registrado."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo registrar el periodo."
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
            statusMessage = "Encuentro guardado."
            errorMessage = nil
        } catch {
            errorMessage = "No se pudo guardar el encuentro."
        }
    }

    private func refreshPeriodState() async throws {
        isPeriodActive = try await cycleRepository.getOpenCycle() != nil
    }
}
