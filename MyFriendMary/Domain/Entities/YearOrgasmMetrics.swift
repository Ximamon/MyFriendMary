import Foundation

struct YearOrgasmMetrics: Codable, Equatable {
    var year: Int
    var totalOrgasmsYTD: Int
    var bestDayOfYear: Date?
    var bestDayOrgasmCount: Int

    static func empty(for year: Int) -> YearOrgasmMetrics {
        YearOrgasmMetrics(
            year: year,
            totalOrgasmsYTD: 0,
            bestDayOfYear: nil,
            bestDayOrgasmCount: 0
        )
    }
}
