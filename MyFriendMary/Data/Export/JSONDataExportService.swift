import Foundation

@MainActor
final class JSONDataExportService: DataExportService {
    private struct ExportPayload: Codable {
        let generatedAt: Date
        let profile: UserProfile
        let cycles: [Cycle]
        let symptomEntries: [SymptomEntry]
        let sexEntries: [SexEntry]
    }

    private let profileRepository: ProfileRepository
    private let cycleRepository: CycleRepository
    private let symptomRepository: SymptomRepository
    private let sexEntryRepository: SexEntryRepository

    init(
        profileRepository: ProfileRepository,
        cycleRepository: CycleRepository,
        symptomRepository: SymptomRepository,
        sexEntryRepository: SexEntryRepository
    ) {
        self.profileRepository = profileRepository
        self.cycleRepository = cycleRepository
        self.symptomRepository = symptomRepository
        self.sexEntryRepository = sexEntryRepository
    }

    func exportJSON() async throws -> URL {
        let profile = try await profileRepository.getProfile()
        let cycles = try await cycleRepository.fetchCycles()

        let allDataInterval = DateInterval(
            start: Date(timeIntervalSince1970: 0),
            end: Date(timeIntervalSince1970: 4_102_444_800)
        )

        let symptoms = try await symptomRepository.entries(in: allDataInterval)
        let sexEntries = try await sexEntryRepository.entries(in: allDataInterval)

        let payload = ExportPayload(
            generatedAt: Date(),
            profile: profile,
            cycles: cycles,
            symptomEntries: symptoms,
            sexEntries: sexEntries
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(payload)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let filename = "myfriendmary-export-\(formatter.string(from: Date())).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        try data.write(to: url, options: .atomic)
        return url
    }
}
