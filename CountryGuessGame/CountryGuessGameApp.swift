import SwiftUI

@main
struct CountryGuessGameApp: App {
    @StateObject private var scoreStore = ScoreStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
              .environmentObject(scoreStore)
        }
    }
}
