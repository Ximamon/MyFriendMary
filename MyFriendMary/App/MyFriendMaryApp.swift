import SwiftUI
import SwiftData

@main
struct MyFriendMaryApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            MainTabView(container: container)
        }
        .modelContainer(container.modelContainer)
    }
}
