import SwiftUI

struct HomeView: View {
    @EnvironmentObject var scoreStore: ScoreStore

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                NavigationLink("Play",        destination: GameView())
                    .font(.title2)
                NavigationLink("Scoreboard", destination: ScoreboardView())
                    .font(.title2)
                NavigationLink("About",       destination: AboutView())
                    .font(.title2)
            }
            .navigationTitle("Country Guess Game")
        }
    }
}

