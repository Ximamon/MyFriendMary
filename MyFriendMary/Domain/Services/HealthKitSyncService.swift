import Foundation

protocol HealthKitSyncService {
    func requestPermissionsIfNeeded() async
    func syncMenstrualFlow(for cycle: Cycle) async
}
