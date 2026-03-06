import Foundation

protocol ContraceptivePlanRepository {
    func fetchPlans() async throws -> [ContraceptivePlan]
    func activePlan() async throws -> ContraceptivePlan?
    func plan(containing day: Date) async throws -> ContraceptivePlan?
    func upsertPlan(_ plan: ContraceptivePlan) async throws
}
