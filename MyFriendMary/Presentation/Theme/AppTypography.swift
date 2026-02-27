import SwiftUI

enum AppTypography {
    static let title = Font.system(.title2, design: .rounded).weight(.bold)
    static let section = Font.system(.headline, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .rounded)
    static let footnote = Font.system(.footnote, design: .rounded)
    static let number = Font.system(.title, design: .rounded).weight(.bold)
}
