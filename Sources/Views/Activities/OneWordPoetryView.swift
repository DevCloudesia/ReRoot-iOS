import SwiftUI

struct OneWordPoetryView: View {
    let onComplete: (String) -> Void

    @StateObject private var audio = AmbientAudioManager.shared

    @State private var themeIndex: Int = 0
    @State private var userLine = ""
    @State private var isSubmitted = false
    @State private var appear = false
    @State private var didInit = false

    private let themes = [
        ("Freedom", "What does freedom feel like in your lungs?"),
        ("Breath", "Describe one breath that matters."),
        ("Silence", "What lives in the silence between cravings?"),
        ("Roots", "What are you growing toward?"),
        ("Water", "Where does the stream take you?"),
        ("Light", "What does the light touch first?"),
        ("Tomorrow", "What does tomorrow smell like?"),
        ("Wings", "If you could fly away from one thing..."),
        ("Rain", "What washes clean when it rains?"),
        ("Hands", "What are your hands reaching for?"),
        ("Strength", "Where do you find it when you think it is gone?"),
        ("Home", "Describe a place where you feel safe."),
        ("Fire", "What burns inside you that is not a craving?"),
        ("Ocean", "What does the deepest part of you sound like?"),
        ("Morning", "What is the first thing you notice when you wake up?"),
        ("Color", "If today were a color, what would it be and why?"),
        ("Mountain", "What are you climbing toward?"),
        ("Stars", "What do you see when you look up?"),
        ("Forgiveness", "What would you say to your past self?"),
        ("Joy", "Describe a small, ordinary moment of happiness."),
    ]

    private var currentTheme: (String, String) {
        themes[themeIndex % themes.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            VStack(spacing: 6) {
                Text("ONE-LINE POETRY")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text("Write one line.")
                    .font(.serif(30, weight: .bold)).foregroundColor(.white)
            }

            Spacer(minLength: 32)

            if isSubmitted {
                VStack(spacing: 24) {
                    Text("\u{201C}")
                        .font(.serif(72, weight: .heavy)).foregroundColor(.white.opacity(0.15))
                        .frame(height: 32)
                    Text(userLine)
                        .font(.serif(24, weight: .semibold)).foregroundColor(.white)
                        .multilineTextAlignment(.center).lineSpacing(6).padding(.horizontal, 32)
                    Text("you")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.35)).italic()
                }
                .opacity(appear ? 1 : 0)
                .animation(.easeOut(duration: 1), value: appear)
                .onAppear { withAnimation { appear = true } }
            } else {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text("Theme: \(currentTheme.0)")
                            .font(.serif(20, weight: .bold)).foregroundColor(.white.opacity(0.7))
                        Text(currentTheme.1)
                            .font(.sansRR(13)).foregroundColor(.white.opacity(0.4))
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeIndex = (themeIndex + 1) % themes.count
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 12, weight: .bold))
                            Text("New theme")
                                .font(.sansRR(12, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }

                    TextField("", text: $userLine, prompt: Text("Write your line...").foregroundColor(.white.opacity(0.3)), axis: .vertical)
                        .font(.serif(20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(20)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                        .padding(.horizontal, 22)
                }
            }

            Spacer(minLength: 32)

            if isSubmitted {
                Button {
                    audio.stop()
                    onComplete("One-line poem on \"\(currentTheme.0)\": \(userLine)")
                } label: {
                    Text("Beautiful \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else {
                Button {
                    guard !userLine.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    withAnimation { isSubmitted = true }
                } label: {
                    Text("Reveal my poem")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear {
            if !didInit {
                themeIndex = Int.random(in: 0..<themes.count)
                didInit = true
            }
            audio.play(.creative)
        }
        .onDisappear { audio.stop() }
    }
}
