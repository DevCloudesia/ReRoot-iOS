import SwiftUI

struct PatternMemoryView: View {
    let onComplete: () -> Void

    @State private var gridSize = 3
    @State private var pattern: Set<Int> = []
    @State private var userTaps: Set<Int> = []
    @State private var showingPattern = false
    @State private var score = 0
    @State private var round = 0
    @State private var isDone = false
    @State private var flashResult: Bool? = nil
    @State private var timerTask: Task<Void, Never>?

    private let totalRounds = 5

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("IMPULSE CONTROL TRAINING")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Impulse control strengthened." : "Strengthen your quit muscles")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                Text("Your prefrontal cortex controls impulse resistance.\nThis exercise strengthens it. Watch the tiles, then tap from memory.")
                    .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 20)

            if isDone {
                VStack(spacing: 16) {
                    Text("\(score)/\(totalRounds)").font(.serif(64, weight: .heavy)).foregroundColor(.white)
                    Text("patterns recalled correctly")
                        .font(.sansRR(15)).foregroundColor(.white.opacity(0.5))
                    Text("You just exercised your prefrontal cortex, the part of your brain that says 'no' to nicotine. Every time you strengthen it here, saying no to a real craving gets easier.")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                }
            } else {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Text("Round \(round + 1)/\(totalRounds)")
                            .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                        Text("Score: \(score)")
                            .font(.sansRR(12, weight: .bold)).foregroundColor(.white.opacity(0.6))
                    }

                    let total = gridSize * gridSize
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize), spacing: 8) {
                        ForEach(0..<total, id: \.self) { i in
                            tileButton(i)
                        }
                    }
                    .padding(.horizontal, 40)

                    if showingPattern {
                        Text("Watch carefully...")
                            .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                    } else {
                        Text("Tap the tiles that were highlighted")
                            .font(.sansRR(13)).foregroundColor(.white.opacity(0.4))
                    }
                }
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("My impulse control is stronger \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear { startRound() }
        .onDisappear { timerTask?.cancel() }
    }

    func tileColor(_ i: Int) -> Color {
        let highlighted = showingPattern && pattern.contains(i)
        let tapped = userTaps.contains(i)
        if highlighted { return Color.white.opacity(0.5) }
        if tapped && flashResult == true { return Color(red: 0.35, green: 0.75, blue: 0.45).opacity(0.5) }
        if tapped && flashResult == false { return Color.red.opacity(0.4) }
        if tapped { return Color.white.opacity(0.2) }
        return Color.white.opacity(0.08)
    }

    func tileButton(_ i: Int) -> some View {
        let highlighted = showingPattern && pattern.contains(i)
        return Button {
            guard !showingPattern else { return }
            _ = withAnimation(.spring(response: 0.2)) { userTaps.insert(i) }
            if userTaps.count >= pattern.count { checkResult() }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor(i))
                .frame(height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(highlighted ? Color.white.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(showingPattern || isDone)
    }

    func startRound() {
        let count = min(3 + round / 2, 5)
        gridSize = round < 4 ? 3 : 4
        let total = gridSize * gridSize
        var p = Set<Int>()
        while p.count < count { p.insert(Int.random(in: 0..<total)) }
        pattern = p
        userTaps = []
        showingPattern = true
        flashResult = nil

        timerTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_500_000_000 + 300_000_000 * count))
            guard !Task.isCancelled else { return }
            await MainActor.run { withAnimation { showingPattern = false } }
        }
    }

    func checkResult() {
        let correct = userTaps == pattern
        flashResult = correct
        if correct { score += 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if round < totalRounds - 1 {
                round += 1
                startRound()
            } else {
                withAnimation { isDone = true }
            }
        }
    }
}
