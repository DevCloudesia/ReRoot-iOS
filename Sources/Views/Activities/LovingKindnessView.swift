import SwiftUI

struct LovingKindnessView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var step = 0
    @State private var appear = false
    @State private var isDone = false
    @State private var timerTask: Task<Void, Never>?
    @State private var glowScale: CGFloat = 1.0

    private let phases: [(target: String, phrases: [String])] = [
        ("Yourself", [
            "May I forgive myself for smoking.",
            "May I heal from what nicotine did to my body.",
            "May I stay smoke-free today.",
        ]),
        ("Someone you love", [
            "May they be safe and healthy.",
            "May they know they are loved.",
        ]),
        ("Everyone, everywhere", [
            "May all beings be free from suffering.",
            "May all beings find peace.",
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("SELF-COMPASSION FOR QUITTERS")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Kindness sent." : "Recovery self-compassion")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("Step \(step + 1) of \(phases.count)")
                        .font(.sansRR(11)).foregroundColor(.white.opacity(0.35))
                }
            }

            Spacer(minLength: 20)

            if isDone {
                VStack(spacing: 20) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 64)).foregroundColor(.white.opacity(0.5))
                    Text("You just sent kindness to yourself, someone you love, a stranger, and the whole world.\nResearch shows this rewires your brain toward compassion and reduces stress hormones.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                }
            } else {
                let phase = phases[step]
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color.white.opacity(0.15), Color.clear],
                                center: .center, startRadius: 10, endRadius: 80
                            ))
                            .frame(width: 160, height: 160)
                            .scaleEffect(glowScale)

                        VStack(spacing: 4) {
                            Text("Send to:")
                                .font(.sansRR(11)).foregroundColor(.white.opacity(0.4))
                            Text(phase.target)
                                .font(.serif(22, weight: .bold)).foregroundColor(.white)
                        }
                    }

                    VStack(spacing: 12) {
                        ForEach(Array(phase.phrases.enumerated()), id: \.offset) { i, phrase in
                            Text(phrase)
                                .font(.sansRR(16)).foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .opacity(appear ? 1 : 0)
                                .animation(.easeOut(duration: 0.6).delay(Double(i) * 0.4), value: appear)
                        }
                    }
                    .padding(.horizontal, 28)

                    HStack(spacing: 8) {
                        ForEach(0..<phases.count, id: \.self) { i in
                            Circle()
                                .fill(i <= step ? Color.white.opacity(0.6) : Color.white.opacity(0.15))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("I deserve this compassion \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else {
                Button {
                    if step < phases.count - 1 {
                        withAnimation { appear = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            step += 1
                            withAnimation { appear = true }
                        }
                    } else {
                        withAnimation { isDone = true }; audio.stop()
                    }
                } label: {
                    Text(step < phases.count - 1 ? "Next \u{2192}" : "Complete")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear {
            audio.play(.breathing)
            withAnimation { appear = true }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) { glowScale = 1.15 }
        }
        .onDisappear { audio.stop() }
    }
}
