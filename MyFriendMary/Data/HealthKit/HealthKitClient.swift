import Foundation

protocol HealthKitClient {
    func requestPermissionsIfNeeded() async throws
    func writeMenstrualFlow(for cycle: Cycle) async throws
}

final class DefaultHealthKitClient: HealthKitClient {
    func requestPermissionsIfNeeded() async throws {
        // TODO: Implementar permisos reales de HealthKit en Paso 8.
    }

    func writeMenstrualFlow(for cycle: Cycle) async throws {
        _ = cycle
        // TODO: Escribir menstrualFlow en HealthKit en Paso 8.
    }
}
