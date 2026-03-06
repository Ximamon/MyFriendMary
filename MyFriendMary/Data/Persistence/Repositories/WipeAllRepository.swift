import Foundation
import SwiftData

@MainActor
final class WipeAllRepository: WipeAllDataStore {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func wipeAll() async throws {
        try deleteAll(SDSexEntry.self)
        try deleteAll(SDSymptomEntry.self)
        try deleteAll(SDPeriodEntry.self)
        try deleteAll(SDContraceptivePlan.self)
        try deleteAll(SDCycle.self)
        try deleteAll(SDUserProfile.self)

        context.insert(SDUserProfile())
        try save()
    }

    private func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let objects = try context.fetch(descriptor)
        for object in objects {
            context.delete(object)
        }
    }

    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
