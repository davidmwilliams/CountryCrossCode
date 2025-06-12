import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var bgPlayer: AVAudioPlayer?
    private var fxPlayer: AVAudioPlayer?

    enum Effect: String {
        case correct
        case wrong
        case hint
    }

    /// Looping background music (volume adjustable)
    func playBackgroundMusic(file: String = "background") {
        guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else { return }
        do {
            bgPlayer = try AVAudioPlayer(contentsOf: url)
            bgPlayer?.numberOfLoops = -1
            bgPlayer?.volume = 0.5
            bgPlayer?.play()
        } catch {
            print("🎵 bg music error:", error)
        }
    }

    func stopBackgroundMusic() {
        bgPlayer?.stop()
    }

    /// One-off sound effects
    func playEffect(_ effect: Effect) {
        guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav") else { return }
        DispatchQueue.main.async {
            do {
                self.fxPlayer = try AVAudioPlayer(contentsOf: url)
                self.fxPlayer?.volume = 1.0
                self.fxPlayer?.play()
            } catch {
                print("🔊 fx error:", error)
            }
        }
    }
}

