import Foundation

enum SymptomMapper {
    static func toDomain(_ model: SDSymptomEntry) -> SymptomEntry {
        SymptomEntry(
            id: model.id,
            date: model.day,
            symptoms: decodeSymptoms(model.symptomsRaw),
            note: model.note
        )
    }

    static func apply(_ entry: SymptomEntry, to model: SDSymptomEntry) {
        model.day = DateNormalizer.startOfDay(entry.date)
        model.symptomsRaw = encodeSymptoms(entry.symptoms)
        model.note = entry.note
        model.updatedAt = Date()
    }

    static func encodeSymptoms(_ symptoms: [SymptomType]) -> String {
        let values = symptoms.map(\.rawValue)
        let data = try? JSONEncoder().encode(values)
        return String(data: data ?? Data("[]".utf8), encoding: .utf8) ?? "[]"
    }

    static func decodeSymptoms(_ raw: String) -> [SymptomType] {
        guard let data = raw.data(using: .utf8),
              let values = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return values.compactMap(SymptomType.init(rawValue:))
    }
}
