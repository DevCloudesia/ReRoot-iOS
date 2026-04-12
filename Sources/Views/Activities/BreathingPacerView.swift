import SwiftUI

struct BreathingPacerView: View {
    let mode: Mode
    let onComplete: () -> Void

    enum Mode: String, CaseIterable {
        case fourSevenEight = "4-7-8 Reset"
        case boxBreathing   = "Box Breathing"
        case physiologicalSigh = "Physiological Sigh"

        var phases: [(label: String, seconds: Int)] {
            switch self {
            case .fourSevenEight:    return [("Inhale", 4), ("Hold", 7), ("Exhale", 8)]
            case .boxBreathing:      return [("Inhale", 4), ("Hold", 4), ("Exhale", 4), ("Hold", 4)]
            case .physiologicalSigh: return [("Inhale", 2), ("Inhale", 1), ("Exhale", 6)]
            }
        }
        var totalCycles: Int { 3 }
        var description: String {
            switch self {
            case .fourSevenEight:    return "Extended exhale stimulates your vagus nerve, lowering cortisol immediately."
            case .boxBreathing:      return "Used by Navy SEALs. Equal phases create deep autonomic balance."
            case .physiologicalSigh: return "Stanford-researched. Double inhale + long exhale is the fastest way to calm."
            }
        }
        var accent: Color {
            switch self {
            case .fourSevenEight:    return Color(red: 0.45, green: 0.70, blue: 0.95)
            case .boxBreathing:      return Color(red: 0.55, green: 0.80, blue: 0.55)
            case .physiologicalSigh: return Color(red: 0.80, green: 0.60, blue: 0.90)
            }
        }
        var bgTop: Color {
            switch self {
            case .fourSevenEight:    return Color(red: 0.06, green: 0.10, blue: 0.18)
            case .boxBreathing:      return Color(red: 0.06, green: 0.14, blue: 0.08)
            case .physiologicalSigh: return Color(red: 0.12, green: 0.06, blue: 0.16)
            }
        }
    }

    @State private var currentPhase = 0
    @State private var currentCycle = 0
    @State private var phaseProgress: CGFloat = 0
    @State private var circleScale: CGFloat = 0.4
    @State private var isRunning = false
    @State private var isDone = false
    @State private var timerTask: Task<Void, Never>?
    @State private var ringRotation: Double = 0

    private var phases: [(label: String, seconds: Int)] { mode.phases }
    private var currentLabel: String { isDone ? "Complete" : phases[currentPhase].label }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [mode.bgTop, Color(red: 0.06, green: 0.06, blue: 0.08)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            RadialGradient(
                colors: [mode.accent.opacity(isRunning ? 0.10 : 0.04), .clear],
                center: .center, startRadius: 20, endRadius: 350
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text(mode.rawValue.uppercased())
                        .font(.sansRR(10, weight: .bold)).foregroundColor(mode.accent.opacity(0.6)).tracking(1.8)
                    Text(isDone ? "Calm restored" : "Follow the circle")
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    if !isDone {
                        Text(mode.description)
                            .font(.sansRR(12)).foregroundColor(.white.opacity(0.45))
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                    }
                }

                Spacer(minLength: 24)

                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(mode.accent.opacity(0.04 + Double(i) * 0.02), lineWidth: 1)
                            .frame(width: CGFloat(180 + i * 50), height: CGFloat(180 + i * 50))
                    }

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [mode.accent.opacity(0.25), mode.accent.opacity(0.04), .clear],
                                center: .center, startRadius: 5, endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(circleScale)

                    Circle()
                        .stroke(mode.accent.opacity(0.15), lineWidth: 2)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: phaseProgress)
                        .stroke(
                            AngularGradient(
                                colors: [mode.accent.opacity(0.8), mode.accent.opacity(0.3), mode.accent.opacity(0.8)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90 + ringRotation))

                    if isRunning {
                        Circle()
                            .fill(mode.accent)
                            .frame(width: 8, height: 8)
                            .offset(y: -80)
                            .rotationEffect(.degrees(-90 + ringRotation + 360 * phaseProgress))
                    }

                    VStack(spacing: 8) {
                        Text(currentLabel)
                            .font(.serif(26, weight: .bold)).foregroundColor(.white)
                        if !isDone {
                            Text("Cycle \(currentCycle + 1) of \(mode.totalCycles)")
                                .font(.sansRR(11)).foregroundColor(mode.accent.opacity(0.5))
                        }
                    }
                }

                Spacer(minLength: 20)

                if isRunning && !isDone {
                    phaseIndicator
                }

                Spacer(minLength: 24)

                if isDone {
                    doneSection
                } else if !isRunning {
                    Button { startBreathing() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "lungs.fill").font(.system(size: 14))
                            Text("Begin breathing")
                                .font(.sansRR(16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [mode.accent, mode.accent.opacity(0.7)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: mode.accent.opacity(0.3), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 22)
                }

                Spacer(minLength: 52)
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    var phaseIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<phases.count, id: \.self) { i in
                HStack(spacing: 4) {
                    Circle()
                        .fill(i == currentPhase ? mode.accent : mode.accent.opacity(0.2))
                        .frame(width: 6, height: 6)
                    Text(phases[i].label)
                        .font(.sansRR(10, weight: i == currentPhase ? .bold : .regular))
                        .foregroundColor(i == currentPhase ? mode.accent : .white.opacity(0.3))
                }
                .padding(.horizontal, 8).padding(.vertical, 5)
                .background(i == currentPhase ? mode.accent.opacity(0.1) : Color.clear)
                .clipShape(Capsule())
            }
        }
    }

    var doneSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                statBadge(icon: "lungs.fill", label: "\(mode.totalCycles) cycles")
                statBadge(icon: "heart.fill", label: "Calmer")
                statBadge(icon: "brain.head.profile", label: "Reset")
            }
            Button(action: onComplete) {
                Text("I feel calmer \u{2192}")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22)
        }
    }

    func statBadge(icon: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 10)).foregroundColor(mode.accent)
            Text(label).font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(mode.accent.opacity(0.1)).clipShape(Capsule())
    }

    func startBreathing() {
        isRunning = true
        timerTask = Task {
            for cycle in 0..<mode.totalCycles {
                guard !Task.isCancelled else { return }
                await MainActor.run { currentCycle = cycle }
                for (phaseIdx, phase) in phases.enumerated() {
                    guard !Task.isCancelled else { return }
                    await MainActor.run { currentPhase = phaseIdx }
                    let targetScale: CGFloat = phase.label == "Exhale" ? 0.4 : (phase.label == "Hold" ? circleScale : 0.95)
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: Double(phase.seconds))) {
                            circleScale = targetScale
                            phaseProgress = 1.0
                        }
                    }
                    try? await Task.sleep(nanoseconds: UInt64(phase.seconds) * 1_000_000_000)
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.2)) { phaseProgress = 0 }
                    }
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
            }
            await MainActor.run { withAnimation { isDone = true; isRunning = false } }
        }
    }
}
