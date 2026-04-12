import AVFoundation
import SwiftUI

@MainActor
class AmbientAudioManager: ObservableObject {
    static let shared = AmbientAudioManager()

    @Published var isPlaying = false

    enum Soundscape: String {
        case breathing, urgeSurfing, bodyScan, grounding, creative, chat
    }

    func play(_ soundscape: Soundscape) {}
    func stop() {}
}
