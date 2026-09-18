import SwiftUI

@main
struct GlassDemoApp: App {
    var body: some Scene {
        WindowGroup {
            GlassDemoView()
                .preferredColorScheme(.light)
        }
    }
}
