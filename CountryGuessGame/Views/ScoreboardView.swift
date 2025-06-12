import SwiftUI

struct ScoreboardView: View {
    @EnvironmentObject var scoreStore: ScoreStore

    var body: some View {
        List(scoreStore.scores) { score in
            HStack {
                Text(score.date, style: .date)
                Spacer()
                Text("\(score.guesses) guesses")
                Spacer()
                Text("\(Int(score.duration))s")
            }
        }
        .navigationTitle("Scoreboard")
    }
}
