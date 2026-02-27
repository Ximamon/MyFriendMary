import Foundation

protocol CycleRepository {
    func fetchCycles() async throws -> [Cycle]
    func upsertCycle(_ cycle: Cycle) async throws
    func getOpenCycle() async throws -> Cycle?
    func closeOpenCycle(on date: Date) async throws
}
