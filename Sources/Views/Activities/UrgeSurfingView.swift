import SwiftUI

struct UrgeSurfingView: View {
    let onComplete: () -> Void

    @State private var wavePhase: CGFloat = 0
    @State private var promptIdx = 0
    @State private var elapsed = 0
    @State private var isDone = false
    @State private var isRunning = false
    @State private var timerTask: Task<Void, Never>?

    private let totalDuration = 90
    private let accent = Color(red: 0.25, green: 0.55, blue: 0.80)
    private let accentDeep = Color(red: 0.15, green: 0.30, blue: 0.55)
    private let prompts = [
        "Sit comfortably. Soften your shoulders.\nUnclench your jaw. Take one slow breath\nin through your nose.",
        "Scan your body. Where is the craving?\nChest? Hands? Throat?\nName it. Don't push it away.",
        "Picture a beach at dusk. A wave is\nforming on the horizon. The craving\nis building with it.",
        "The wave is at its peak.\nBreathe slowly. 4 counts in, 8 out.\nYou don't have to do anything.",
        "The crest tips over. The intensity drops.\nNicotinic receptors can't sustain this.\nThe wave is falling.",
        "Stillness. The craving passed through you\nand you're still here. Every wave you ride\nweakens the pathway permanently.",
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.08, blue: 0.15), Color(red: 0.02, green: 0.04, blue: 0.08)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text("NICOTINE URGE SURFING")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(accent.opacity(0.5)).tracking(1.8)
                    Text(isDone ? "You rode the wave." : "Ride the nicotine wave")
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    if isRunning && !isDone {
                        Text("\(totalDuration - elapsed)s remaining")
                            .font(.sansRR(11)).foregroundColor(accent.opacity(0.5)).monospacedDigit()
                    }
                }

                Spacer(minLength: 16)

                ZStack {
                    oceanBackground

                    WaveShape(phase: wavePhase, amplitude: waveAmplitude)
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.35), accentDeep.opacity(0.15)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(height: 200)

                    WaveShape(phase: wavePhase + 0.4, amplitude: waveAmplitude * 0.6)
                        .fill(accent.opacity(0.12))
                        .frame(height: 200)
                        .offset(y: 15)

                    WaveShape(phase: wavePhase + 0.8, amplitude: waveAmplitude * 0.4)
                        .fill(accent.opacity(0.06))
                        .frame(height: 200)
                        .offset(y: 30)

                    if isRunning {
                        intensityLabel
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)

                Spacer(minLength: 16)

                if isDone {
                    Text("The nicotine craving passed.\nYou didn't smoke. You won.")
                        .font(.serif(20, weight: .bold)).foregroundColor(.white)
                        .multilineTextAlignment(.center).lineSpacing(6)
                } else if isRunning {
                    Text(prompts[min(promptIdx, prompts.count - 1)])
                        .font(.sansRR(15)).foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center).lineSpacing(5)
                        .padding(.horizontal, 28)
                        .id(promptIdx)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.8), value: promptIdx)
                } else {
                    Text("Visualize your craving as an ocean wave.\nWatch it build, peak, and dissolve.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center).padding(.horizontal, 28)
                }

                Spacer(minLength: 20)

                if isDone {
                    HStack(spacing: 12) {
                        statPill(icon: "water.waves", label: "Wave ridden")
                        statPill(icon: "brain.head.profile", label: "Pathway weakened")
                    }
                    .padding(.bottom, 12)

                    Button(action: onComplete) {
                        Text("I beat this craving \u{2192}")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                } else if !isRunning {
                    Button { startSurfing() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "water.waves").font(.system(size: 14))
                            Text("Begin visualization").font(.sansRR(16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [accent, accentDeep], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: accent.opacity(0.3), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 22)
                }

                Spacer(minLength: 52)
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    var oceanBackground: some View {
        LinearGradient(
            colors: [accentDeep.opacity(0.2), accent.opacity(0.05), .clear],
            startPoint: .bottom, endPoint: .top
        )
    }

    var intensityLabel: some View {
        let pct = Double(elapsed) / Double(totalDuration)
        let label: String
        if pct < 0.3 { label = "Building" }
        else if pct < 0.55 { label = "Peaking" }
        else if pct < 0.75 { label = "Cresting" }
        else { label = "Dissolving" }

        return VStack(spacing: 2) {
            Text(label)
                .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.5))
            RoundedRectangle(cornerRadius: 2)
                .fill(accent.opacity(0.4))
                .frame(width: 60 * waveAmplitude / 60, height: 4)
        }
        .padding(8)
        .background(Color.black.opacity(0.3)).clipShape(RoundedRectangle(cornerRadius: 8))
        .position(x: 60, y: 30)
    }

    func statPill(icon: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 10)).foregroundColor(accent)
            Text(label).font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(accent.opacity(0.1)).clipShape(Capsule())
    }

    private var waveAmplitude: CGFloat {
        let pct = Double(elapsed) / Double(totalDuration)
        if pct < 0.4 { return 20 + CGFloat(pct / 0.4) * 40 }
        if pct < 0.6 { return 60 }
        return 60 - CGFloat((pct - 0.6) / 0.4) * 50
    }

    func startSurfing() {
        isRunning = true
        let promptInterval = max(totalDuration / prompts.count, 1)
        timerTask = Task {
            while elapsed < totalDuration && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    elapsed += 1
                    withAnimation(.linear(duration: 1)) { wavePhase += 0.08 }
                    let newIdx = min(elapsed / promptInterval, prompts.count - 1)
                    if newIdx != promptIdx { withAnimation { promptIdx = newIdx } }
                }
            }
            await MainActor.run { withAnimation { isDone = true; isRunning = false } }
        }
    }
}

struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(phase, amplitude) }
        set { phase = newValue.first; amplitude = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let midY = rect.height * 0.4
        p.move(to: CGPoint(x: 0, y: midY))
        for x in stride(from: 0, through: rect.width, by: 2) {
            let relX = x / rect.width
            let y = midY + sin((relX * 2 * .pi) + phase * .pi * 2) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
        }
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }
}
