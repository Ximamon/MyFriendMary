import Foundation

protocol DataExportService {
    func exportJSON() async throws -> URL
}
