import Foundation

enum PeriodEntryMapper {
    static func toDomain(_ model: SDPeriodEntry) -> PeriodEntry {
        PeriodEntry(
            id: model.id,
            date: DateNormalizer.startOfDay(model.day),
            intensity: model.intensityRaw.flatMap { PeriodIntensity(rawValue: $0) }
        )
    }

    static func apply(_ entry: PeriodEntry, to model: SDPeriodEntry) {
        model.day = DateNormalizer.startOfDay(entry.date)
        model.intensityRaw = entry.intensity?.rawValue
        model.updatedAt = Date()
    }
}
