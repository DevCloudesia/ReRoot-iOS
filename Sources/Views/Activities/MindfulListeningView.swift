import SwiftUI

struct MindfulListeningView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var elapsed = 0
    @State private var sounds: [String] = []
    @State private var currentSound = ""
    @State private var isDone = false
    @State private var isListening = false
    @State private var timerTask: Task<Void, Never>?
    @State private var ringPulse: CGFloat = 1.0

    private let duration = 60

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("CRAVING INTERRUPT: LISTEN")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Craving interrupted." : "Break the craving loop")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                if !isDone && !isListening {
                    Text("Cravings hijack your attention. This exercise takes it back.\nClose your eyes. Focus on sounds around you.\nWhen you notice one, open your eyes and log it.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.45))
                        .multilineTextAlignment(.center).lineSpacing(3)
                }
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 20)

            if isDone {
                VStack(spacing: 16) {
                    Text("You identified \(sounds.count) sounds:")
                        .font(.sansRR(14)).foregroundColor(.white.opacity(0.6))
                    VStack(spacing: 6) {
                        ForEach(Array(sounds.enumerated()), id: \.offset) { _, s in
                            HStack(spacing: 8) {
                                Image(systemName: "ear.fill").font(.system(size: 11)).foregroundColor(.white.opacity(0.4))
                                Text(s).font(.sansRR(13)).foregroundColor(.white.opacity(0.7))
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    Text("You just redirected your brain's attention away from nicotine craving circuits. Sensory focus is one of the fastest ways to break a craving loop.")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                }
            } else if isListening {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 3)
                            .frame(width: 120, height: 120)
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .scaleEffect(ringPulse)
                        Image(systemName: "ear.fill")
                            .font(.system(size: 32)).foregroundColor(.white.opacity(0.5))
                    }

                    Text("\(duration - elapsed)s remaining")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.35)).monospacedDigit()

                    HStack(spacing: 10) {
                        TextField("", text: $currentSound, prompt: Text("I hear...").foregroundColor(.white.opacity(0.3)))
                            .font(.sansRR(14)).foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))

                        Button {
                            let s = currentSound.trimmingCharacters(in: .whitespaces)
                            guard !s.isEmpty else { return }
                            withAnimation { sounds.append(s) }
                            currentSound = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28)).foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 22)

                    if !sounds.isEmpty {
                        Text("\(sounds.count) sounds logged")
                            .font(.sansRR(11)).foregroundColor(.white.opacity(0.35))
                    }
                }
            } else {
                Image(systemName: "ear.fill")
                    .font(.system(size: 48)).foregroundColor(.white.opacity(0.4))
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("Craving interrupted \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else if !isListening {
                Button { startListening() } label: {
                    Text("Begin listening")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else if sounds.count >= 3 {
                Button { withAnimation { isDone = true }; timerTask?.cancel(); audio.stop() } label: {
                    Text("I've heard enough")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.4))
                }
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.grounding) }
        .onDisappear { timerTask?.cancel(); audio.stop() }
    }

    func startListening() {
        isListening = true
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) { ringPulse = 1.2 }
        timerTask = Task {
            while elapsed < duration && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { elapsed += 1 }
            }
            await MainActor.run { withAnimation { isDone = true }; audio.stop() }
        }
    }
}
