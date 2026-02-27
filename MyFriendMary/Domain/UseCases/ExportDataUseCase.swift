import Foundation

protocol ExportDataUseCase {
    func execute() async throws -> URL
}

@MainActor
final class DefaultExportDataUseCase: ExportDataUseCase {
    private let exportService: DataExportService

    init(exportService: DataExportService) {
        self.exportService = exportService
    }

    func execute() async throws -> URL {
        try await exportService.exportJSON()
    }
}
