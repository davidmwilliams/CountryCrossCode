import Foundation

struct GameSession {
    let targetIndex: Int
    var guessCount = 0
    let startTime = Date()
    var endTime: Date?

    mutating func recordGuess() {
        guessCount += 1
    }

    mutating func finish() {
        endTime = Date()
    }

    var duration: TimeInterval {
        guard let end = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return end.timeIntervalSince(startTime)
    }
}
