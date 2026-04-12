import SwiftUI

struct FingerTapView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var currentFinger = 0
    @State private var currentRound = 0
    @State private var tapped: Set<Int> = []
    @State private var isDone = false
    @State private var isRunning = false

    private let fingers = ["Thumb", "Index", "Middle", "Ring", "Pinky"]
    private let fingerIcons = ["hand.thumbsup.fill", "hand.point.up.fill", "hand.raised.fill", "hand.raised.fill", "hand.point.up.left.fill"]
    private let totalRounds = 3

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("CRAVING REDIRECT: FINGER TAP")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Craving redirected." : "Redirect your craving")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("Nicotine cravings live in your brain's reward center.\nThis exercise activates your motor cortex instead.\nTouch each finger to your thumb. Say the name as you tap.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.45))
                        .multilineTextAlignment(.center).lineSpacing(3)
                }
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 24)

            if isDone {
                VStack(spacing: 20) {
                    Image(systemName: "hand.point.up.braille.fill")
                        .font(.system(size: 56)).foregroundColor(.white.opacity(0.5))
                    Text("Finger tapping meditation activates the somatosensory cortex, pulling your attention away from nicotine craving circuits and into physical awareness.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                }
            } else if isRunning {
                VStack(spacing: 20) {
                    Text("Round \(currentRound + 1)/\(totalRounds)")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))

                    HStack(spacing: 12) {
                        ForEach(0..<fingers.count, id: \.self) { i in
                            Button {
                                if i == currentFinger {
                                    _ = withAnimation(.spring(response: 0.25)) { tapped.insert(i) }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { advanceFinger() }
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(tapped.contains(i) ? Color(red: 0.35, green: 0.75, blue: 0.45).opacity(0.5) :
                                                (i == currentFinger ? Color.white.opacity(0.25) : Color.white.opacity(0.08)))
                                        .frame(width: 52, height: 52)
                                        .overlay(
                                            Image(systemName: tapped.contains(i) ? "checkmark" : "circle.fill")
                                                .font(.system(size: tapped.contains(i) ? 18 : 8, weight: .bold))
                                                .foregroundColor(.white.opacity(tapped.contains(i) ? 1 : (i == currentFinger ? 0.8 : 0.3)))
                                        )
                                        .scaleEffect(i == currentFinger ? 1.1 : 1.0)
                                    Text(fingers[i])
                                        .font(.sansRR(10, weight: i == currentFinger ? .bold : .regular))
                                        .foregroundColor(i == currentFinger ? .white : .white.opacity(0.4))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)

                    Text("Tap: \(fingers[currentFinger])")
                        .font(.serif(24, weight: .bold)).foregroundColor(.white)
                }
            } else {
                Image(systemName: "hand.point.up.braille.fill")
                    .font(.system(size: 56)).foregroundColor(.white.opacity(0.4))
            }

            Spacer(minLength: 32)

            if isDone {
                Button(action: onComplete) {
                    Text("Craving redirected \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else if !isRunning {
                Button { withAnimation { isRunning = true } } label: {
                    Text("Begin")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.grounding) }
        .onDisappear { audio.stop() }
    }

    func advanceFinger() {
        if currentFinger < fingers.count - 1 {
            currentFinger += 1
        } else {
            if currentRound < totalRounds - 1 {
                currentRound += 1
                currentFinger = 0
                tapped.removeAll()
            } else {
                withAnimation { isDone = true }
                audio.stop()
            }
        }
    }
}
