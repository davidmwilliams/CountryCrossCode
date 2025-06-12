import Foundation
import Combine

class ScoreStore: ObservableObject {
    @Published var scores: [Score] = []
    private let saveKey = "scores"

    init() {
        load()
    }

    func add(_ score: Score) {
        scores.append(score)
        save()
    }

    private func load() {
        guard
          let data = UserDefaults.standard.data(forKey: saveKey),
          let decoded = try? JSONDecoder().decode([Score].self, from: data)
        else { return }
        scores = decoded
    }

    private func save() {
        guard let encoded = try? JSONEncoder().encode(scores) else { return }
        UserDefaults.standard.set(encoded, forKey: saveKey)
    }
}
