import Foundation

enum SexEntryMapper {
    static func toDomain(_ model: SDSexEntry, cryptoService: CryptoService) throws -> SexEntry {
        SexEntry(
            id: model.id,
            date: model.day,
            orgasmCount: try cryptoService.decryptInt(model.orgasmCountRaw),
            types: try cryptoService.decryptSexTypes(model.typesRaw),
            note: try cryptoService.decryptString(model.noteRaw)
        )
    }

    static func apply(_ entry: SexEntry, to model: SDSexEntry, cryptoService: CryptoService) throws {
        model.day = DateNormalizer.startOfDay(entry.date)
        model.orgasmCountRaw = try cryptoService.encryptInt(entry.orgasmCount)
        model.typesRaw = try cryptoService.encryptSexTypes(entry.types)
        model.noteRaw = try cryptoService.encryptString(entry.note)
        model.updatedAt = Date()
    }
}
