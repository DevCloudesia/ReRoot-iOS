import SwiftUI

struct Serial7sGameView: View {
    let onComplete: () -> Void

    @State private var currentNumber = 1000
    @State private var options: [Int] = []
    @State private var score = 0
    @State private var streak = 0
    @State private var timeRemaining = 60
    @State private var isRunning = false
    @State private var isDone = false
    @State private var flashColor: Color? = nil
    @State private var timerTask: Task<Void, Never>?

    private let accent = Color(red: 0.95, green: 0.60, blue: 0.25)

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.06, blue: 0.04).ignoresSafeArea()
            RadialGradient(
                colors: [accent.opacity(isRunning ? 0.08 : 0.03), .clear],
                center: .center, startRadius: 20, endRadius: 350
            ).ignoresSafeArea()

        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("SERIAL 7s CHALLENGE")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(accent.opacity(0.6)).tracking(1.8)
                Text(isDone ? "Craving defeated." : "Subtract 7")
                    .font(.serif(30, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("\(timeRemaining)s left")
                        .font(.sansRR(11)).foregroundColor(accent.opacity(0.5)).monospacedDigit()
                }
            }

            Spacer(minLength: 24)

            if isDone {
                VStack(spacing: 16) {
                    Text("\(score)").font(.serif(64, weight: .heavy)).foregroundColor(.white)
                    Text("correct answers in 60 seconds")
                        .font(.sansRR(15)).foregroundColor(.white.opacity(0.5))
                    if streak > 3 {
                        Text("Best streak: \(streak)")
                            .font(.sansRR(13, weight: .bold)).foregroundColor(Color(red: 0.95, green: 0.72, blue: 0.25))
                    }
                }
            } else {
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        VStack(spacing: 2) {
                            Text("\(score)").font(.serif(22, weight: .bold)).foregroundColor(.white).monospacedDigit()
                            Text("correct").font(.sansRR(9)).foregroundColor(.white.opacity(0.35))
                        }
                        VStack(spacing: 2) {
                            Text("\(timeRemaining)s").font(.serif(22, weight: .bold)).foregroundColor(.white).monospacedDigit()
                            Text("left").font(.sansRR(9)).foregroundColor(.white.opacity(0.35))
                        }
                    }

                    Text("\(currentNumber)")
                        .font(.serif(72, weight: .heavy)).foregroundColor(.white).monospacedDigit()
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(flashColor?.opacity(0.3) ?? Color.white.opacity(0.07))
                        )
                        .animation(.easeOut(duration: 0.15), value: flashColor == nil)

                    Text("minus 7 = ?")
                        .font(.sansRR(16)).foregroundColor(.white.opacity(0.5))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(options, id: \.self) { opt in
                            Button {
                                checkAnswer(opt)
                            } label: {
                                Text("\(opt)")
                                    .font(.serif(24, weight: .bold)).foregroundColor(.white).monospacedDigit()
                                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            }
                            .disabled(!isRunning)
                        }
                    }
                    .padding(.horizontal, 28)
                }
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("My brain feels different \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else if !isRunning {
                Button { startGame() } label: {
                    Text("Start challenge")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        }
        .onDisappear { timerTask?.cancel() }
    }

    func generateOptions() {
        let correct = currentNumber - 7
        var opts = Set([correct])
        while opts.count < 4 {
            let offset = Int.random(in: -14...14)
            let fake = correct + offset
            if fake != correct && fake > 0 { opts.insert(fake) }
        }
        options = Array(opts).shuffled()
    }

    func checkAnswer(_ answer: Int) {
        let correct = currentNumber - 7
        if answer == correct {
            score += 1
            streak += 1
            flashColor = Color(red: 0.3, green: 0.75, blue: 0.4)
            currentNumber = correct
            if currentNumber <= 7 { currentNumber = 1000 }
        } else {
            streak = 0
            flashColor = Color(red: 0.8, green: 0.3, blue: 0.3)
        }
        generateOptions()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { flashColor = nil }
    }

    func startGame() {
        isRunning = true
        currentNumber = 1000
        generateOptions()
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { timeRemaining -= 1 }
            }
            await MainActor.run { withAnimation { isDone = true; isRunning = false } }
        }
    }
}
