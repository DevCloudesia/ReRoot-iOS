import SwiftUI

struct BreathingView: View {
    @State private var selected: BreathExercise?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Text("Even 60 seconds of controlled breathing activates the parasympathetic nervous system, reducing cortisol and directly counteracting the fight-or-flight response that cravings trigger.")
                        .font(.sansRR(13))
                        .foregroundColor(.rText2)
                        .lineSpacing(3)
                        .padding(14)
                        .background(Color.rAccent.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    ForEach(RecoveryData.breathingExercises) { ex in
                        Button { selected = ex } label: {
                            RRCard {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(ex.color.opacity(0.1))
                                            .overlay(Circle().stroke(ex.color.opacity(0.25), lineWidth: 2))
                                            .frame(width: 52, height: 52)
                                        Image(systemName: "lungs.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(ex.color)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(ex.name)
                                            .font(.sansRR(16, weight: .semibold))
                                            .foregroundColor(.rText)
                                        Text(ex.desc)
                                            .font(.sansRR(12))
                                            .foregroundColor(.rText3)
                                            .lineSpacing(2)
                                        Text(breathPattern(ex))
                                            .font(.sansRR(11, weight: .bold))
                                            .foregroundColor(ex.color)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.rText3)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // Science card
                    VStack(alignment: .leading, spacing: 8) {
                        Label("The Science", systemImage: "brain.head.profile")
                            .font(.sansRR(13, weight: .semibold))
                            .foregroundColor(.rText)
                        Text("The extended exhale phase activates the vagus nerve, shifting the nervous system from sympathetic (fight-or-flight) to parasympathetic (rest and digest). This directly counters the cortisol spike that accompanies nicotine cravings.")
                            .font(.sansRR(12))
                            .foregroundColor(.rText2)
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .background(Color.rPurple.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rPurple.opacity(0.15), lineWidth: 1))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color.rBg.ignoresSafeArea())
            .navigationTitle("Breathing")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selected) { ex in
                BreathingSessionView(exercise: ex)
            }
        }
    }

    private func breathPattern(_ ex: BreathExercise) -> String {
        var parts = ["\(ex.inhale)s in"]
        if ex.hold > 0 { parts.append("\(ex.hold)s hold") }
        parts.append("\(ex.exhale)s out")
        if ex.holdAfter > 0 { parts.append("\(ex.holdAfter)s hold") }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Breathing Session

struct BreathingSessionView: View {
    let exercise: BreathExercise
    @Environment(\.dismiss) var dismiss

    enum Phase { case idle, inhale, hold, exhale, holdAfter }

    @State private var phase: Phase = .idle
    @State private var timer: Int = 0
    @State private var cycles: Int = 0
    @State private var running = false
    @State private var timerTask: Task<Void, Never>?

    var circleScale: CGFloat {
        switch phase {
        case .inhale:   return 1.5
        case .exhale:   return 0.7
        default:        return 1.1
        }
    }

    var transitionDuration: Double {
        switch phase {
        case .inhale:  return Double(exercise.inhale)
        case .exhale:  return Double(exercise.exhale)
        default:       return 0.4
        }
    }

    var phaseLabel: String {
        switch phase {
        case .idle:     return "Ready"
        case .inhale:   return "Breathe In"
        case .hold:     return "Hold"
        case .exhale:   return "Breathe Out"
        case .holdAfter: return "Hold"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Capsule().fill(Color.rText3.opacity(0.3)).frame(width: 40, height: 4).padding(.top, 14)

            Text(exercise.name)
                .font(.serif(24, weight: .bold))
                .foregroundColor(.rText)

            Text(exercise.desc)
                .font(.sansRR(13))
                .foregroundColor(.rText3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // Animated circle
            ZStack {
                // Outer glow rings
                ForEach([1.8, 1.65, 1.5], id: \.self) { scale in
                    Circle()
                        .fill(exercise.color.opacity(0.04))
                        .frame(width: 160, height: 160)
                        .scaleEffect(running ? circleScale * scale / 1.5 : scale / 1.5)
                        .animation(.easeInOut(duration: transitionDuration), value: phase)
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [exercise.color.opacity(0.2), exercise.color.opacity(0.05)],
                            center: .center, startRadius: 10, endRadius: 80
                        )
                    )
                    .overlay(Circle().stroke(exercise.color.opacity(0.3), lineWidth: 2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(running ? circleScale : 1.0)
                    .animation(.easeInOut(duration: transitionDuration), value: phase)

                VStack(spacing: 4) {
                    if running, case .idle = phase { EmptyView() } else if running {
                        Text("\(timer)")
                            .font(.serif(44, weight: .heavy))
                            .foregroundColor(exercise.color)
                            .monospacedDigit()
                    }
                    Text(phaseLabel)
                        .font(.sansRR(14, weight: .semibold))
                        .foregroundColor(running ? exercise.color : exercise.color.opacity(0.5))
                }
            }
            .frame(height: 220)

            if cycles > 0 {
                Text("\(cycles) \(cycles == 1 ? "cycle" : "cycles") completed")
                    .font(.sansRR(14, weight: .semibold))
                    .foregroundColor(exercise.color)
            }

            Spacer()

            Button {
                if running { stopBreathing() } else { startBreathing() }
            } label: {
                Text(running ? "Stop" : "Begin")
                    .font(.sansRR(17, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 16)
                    .background(running ? Color.rDanger : exercise.color)
                    .clipShape(Capsule())
                    .shadow(color: (running ? Color.rDanger : exercise.color).opacity(0.4), radius: 14, y: 5)
            }
            .padding(.bottom, 40)
        }
        .background(Color.rBg.ignoresSafeArea())
        .onDisappear { stopBreathing() }
    }

    func startBreathing() {
        running = true
        cycles = 0
        runPhase(.inhale, duration: exercise.inhale)
    }

    func stopBreathing() {
        running = false
        phase = .idle
        timer = 0
        timerTask?.cancel()
    }

    func runPhase(_ p: Phase, duration: Int) {
        phase = p
        timer = duration
        timerTask?.cancel()
        timerTask = Task {
            for i in stride(from: duration, through: 1, by: -1) {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                await MainActor.run { timer = i - 1 }
            }
            await MainActor.run { nextPhase() }
        }
    }

    func nextPhase() {
        guard running else { return }
        switch phase {
        case .inhale:
            if exercise.hold > 0 { runPhase(.hold, duration: exercise.hold) }
            else { runPhase(.exhale, duration: exercise.exhale) }
        case .hold:
            runPhase(.exhale, duration: exercise.exhale)
        case .exhale:
            if exercise.holdAfter > 0 { runPhase(.holdAfter, duration: exercise.holdAfter) }
            else { cycles += 1; runPhase(.inhale, duration: exercise.inhale) }
        case .holdAfter:
            cycles += 1; runPhase(.inhale, duration: exercise.inhale)
        case .idle: break
        }
    }
}
