import Foundation
import SwiftData

struct SwiftDataStack {
    let container: ModelContainer

    init(inMemory: Bool = false) throws {
        let schema = Schema([
            SDUserProfile.self,
            SDCycle.self,
            SDPeriodEntry.self,
            SDSymptomEntry.self,
            SDSexEntry.self,
            SDContraceptivePlan.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        container = try ModelContainer(for: schema, configurations: [configuration])
    }
}
