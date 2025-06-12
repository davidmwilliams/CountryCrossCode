import Foundation

struct Score: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let guesses: Int
    let duration: TimeInterval
}
