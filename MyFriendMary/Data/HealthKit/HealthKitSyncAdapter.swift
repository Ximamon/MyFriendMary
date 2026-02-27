import Foundation

final class HealthKitSyncAdapter: HealthKitSyncService {
    private let client: HealthKitClient

    init(client: HealthKitClient) {
        self.client = client
    }

    func requestPermissionsIfNeeded() async {
        do {
            try await client.requestPermissionsIfNeeded()
        } catch {
            // No bloquear app local-first si falla HealthKit.
        }
    }

    func syncMenstrualFlow(for cycle: Cycle) async {
        do {
            try await client.writeMenstrualFlow(for: cycle)
        } catch {
            // No bloquear app local-first si falla HealthKit.
        }
    }
}
