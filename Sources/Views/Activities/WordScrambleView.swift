import SwiftUI

struct WordScrambleView: View {
    let onComplete: () -> Void

    @State private var currentWord = ""
    @State private var scrambled = ""
    @State private var userGuess = ""
    @State private var score = 0
    @State private var round = 0
    @State private var flashColor: Color? = nil
    @State private var isDone = false
    @State private var timeRemaining = 90
    @State private var timerTask: Task<Void, Never>?

    private let words = [
        "BREATHE", "FREEDOM", "NICOTINE", "TOBACCO", "HEALING",
        "QUITTER", "COURAGE", "RELAPSE", "TRIGGER", "WILLPWR",
        "RECOVER", "CRAVING", "ABSTAIN", "DETOXED", "CLEANER",
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("QUIT WORD SCRAMBLE")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Craving starved." : "Unscramble the quit word")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                Text("Unscramble tobacco recovery words.\nCognitive load starves nicotine cravings.")
                    .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center).lineSpacing(3)
            }

            Spacer(minLength: 20)

            if isDone {
                VStack(spacing: 16) {
                    Text("\(score)").font(.serif(64, weight: .heavy)).foregroundColor(.white)
                    Text("words unscrambled")
                        .font(.sansRR(15)).foregroundColor(.white.opacity(0.5))
                }
            } else {
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        VStack(spacing: 2) {
                            Text("\(score)").font(.serif(22, weight: .bold)).foregroundColor(.white).monospacedDigit()
                            Text("solved").font(.sansRR(9)).foregroundColor(.white.opacity(0.35))
                        }
                        VStack(spacing: 2) {
                            Text("\(timeRemaining)s").font(.serif(22, weight: .bold)).foregroundColor(.white).monospacedDigit()
                            Text("left").font(.sansRR(9)).foregroundColor(.white.opacity(0.35))
                        }
                    }

                    HStack(spacing: 6) {
                        ForEach(Array(scrambled.enumerated()), id: \.offset) { _, char in
                            Text(String(char))
                                .font(.serif(28, weight: .heavy)).foregroundColor(.white)
                                .frame(width: 36, height: 44)
                                .background(flashColor?.opacity(0.3) ?? Color.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    TextField("", text: $userGuess, prompt: Text("Type your answer...").foregroundColor(.white.opacity(0.3)))
                        .font(.sansRR(18, weight: .semibold)).foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.characters)
                        .padding(14)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        .padding(.horizontal, 32)

                    Button { checkAnswer() } label: {
                        Text("Submit")
                            .font(.sansRR(15, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 32)

                    Button { skipWord() } label: {
                        Text("Skip").font(.sansRR(12)).foregroundColor(.white.opacity(0.35))
                    }
                }
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("Craving had no chance \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear { newWord(); startTimer() }
        .onDisappear { timerTask?.cancel() }
    }

    func newWord() {
        currentWord = words.randomElement() ?? "BREATHE"
        scrambled = String(currentWord.shuffled())
        if scrambled == currentWord { scrambled = String(currentWord.reversed()) }
        userGuess = ""
    }

    func checkAnswer() {
        if userGuess.uppercased().trimmingCharacters(in: .whitespaces) == currentWord {
            score += 1
            flashColor = Color(red: 0.3, green: 0.75, blue: 0.4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = nil; newWord() }
        } else {
            flashColor = Color(red: 0.8, green: 0.3, blue: 0.3)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { flashColor = nil }
        }
    }

    func skipWord() { newWord() }

    func startTimer() {
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { timeRemaining -= 1 }
            }
            await MainActor.run { withAnimation { isDone = true } }
        }
    }
}
