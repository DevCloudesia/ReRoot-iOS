import SwiftUI

struct ColorBreathingView: View {
    let onComplete: () -> Void

    @State private var currentCycle = 0
    @State private var phase: Phase = .ready
    @State private var circleScale: CGFloat = 0.4
    @State private var isDone = false
    @State private var timerTask: Task<Void, Never>?
    @State private var bgOpacity: Double = 0

    enum Phase: String { case ready = "Ready", inhale = "Breathe in color", exhale = "Breathe out grey" }

    private let colors: [(name: String, color: Color, meaning: String)] = [
        ("Blue", Color(red: 0.35, green: 0.55, blue: 0.85), "calm and clarity"),
        ("Green", Color(red: 0.35, green: 0.72, blue: 0.45), "healing and renewal"),
        ("Gold", Color(red: 0.85, green: 0.72, blue: 0.25), "warmth and energy"),
        ("Violet", Color(red: 0.65, green: 0.45, blue: 0.75), "transformation"),
    ]

    private var currentColor: (name: String, color: Color, meaning: String) {
        colors[currentCycle % colors.count]
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()

            RadialGradient(
                colors: [
                    currentColor.color.opacity(phase == .inhale ? 0.15 : 0.04),
                    .clear
                ],
                center: .center, startRadius: 20, endRadius: 400
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2), value: phase)

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text("CLEAN AIR BREATHING")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(currentColor.color.opacity(0.6)).tracking(1.8)
                    Text(isDone ? "Lungs refreshed." : "Fill your lungs with clean air")
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    if !isDone && phase != .ready {
                        Text("Color \(currentCycle + 1) of \(colors.count): \(currentColor.name)")
                            .font(.sansRR(11)).foregroundColor(currentColor.color.opacity(0.6))
                    }
                }

                Spacer(minLength: 20)

                ZStack {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(colors[i].color.opacity(i == currentCycle && phase != .ready ? 0.12 : 0.03))
                            .frame(width: CGFloat(260 - i * 30), height: CGFloat(260 - i * 30))
                            .scaleEffect(i == currentCycle ? circleScale : 0.85)
                            .animation(.easeInOut(duration: 3), value: circleScale)
                    }

                    Circle()
                        .stroke(
                            phase == .exhale
                                ? Color.gray.opacity(0.3)
                                : currentColor.color.opacity(0.4),
                            lineWidth: 2.5
                        )
                        .frame(width: 140, height: 140)
                        .animation(.easeInOut(duration: 1), value: phase)

                    VStack(spacing: 8) {
                        Text(phase.rawValue)
                            .font(.serif(18, weight: .bold)).foregroundColor(.white)
                        if phase == .inhale {
                            Text("Imagine \(currentColor.name.lowercased()) light")
                                .font(.sansRR(11)).foregroundColor(currentColor.color.opacity(0.6))
                        } else if phase == .exhale {
                            Text("Release grey tension")
                                .font(.sansRR(11)).foregroundColor(.white.opacity(0.35))
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 16)

                if phase != .ready && !isDone {
                    HStack(spacing: 8) {
                        ForEach(0..<colors.count, id: \.self) { i in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(i <= currentCycle ? colors[i].color : colors[i].color.opacity(0.15))
                                    .frame(width: 12, height: 12)
                                Text(colors[i].name)
                                    .font(.sansRR(8, weight: .bold))
                                    .foregroundColor(i == currentCycle ? .white : .white.opacity(0.25))
                            }
                        }
                    }
                }

                Spacer(minLength: 24)

                if isDone {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { i in
                                Circle().fill(colors[i].color.opacity(0.5)).frame(width: 16, height: 16)
                            }
                        }
                        Text("Every deep breath pushes out residual damage and strengthens new lung tissue.")
                            .font(.sansRR(12)).foregroundColor(.white.opacity(0.45))
                            .multilineTextAlignment(.center).padding(.horizontal, 28)
                        Button(action: onComplete) {
                            Text("My lungs feel cleaner \u{2192}")
                                .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                                .frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(Color.white).clipShape(Capsule())
                        }
                        .padding(.horizontal, 22)
                    }
                } else if phase == .ready {
                    VStack(spacing: 12) {
                        Text("Breathe in vivid color. Breathe out grey tension.\n4 colors, 4 breaths.")
                            .font(.sansRR(13)).foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center).padding(.horizontal, 28)
                        Button { startCycle() } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "paintpalette.fill").font(.system(size: 14))
                                Text("Begin breathing").font(.sansRR(16, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [colors[0].color, colors[1].color, colors[2].color, colors[3].color],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: colors[0].color.opacity(0.3), radius: 12, y: 4)
                        }
                        .padding(.horizontal, 22)
                    }
                }

                Spacer(minLength: 52)
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    func startCycle() {
        timerTask = Task {
            for cycle in 0..<colors.count {
                guard !Task.isCancelled else { return }
                await MainActor.run { currentCycle = cycle }

                await MainActor.run {
                    phase = .inhale
                    withAnimation(.easeInOut(duration: 5)) { circleScale = 1.0 }
                }
                try? await Task.sleep(nanoseconds: 5_000_000_000)

                await MainActor.run {
                    phase = .exhale
                    withAnimation(.easeInOut(duration: 7)) { circleScale = 0.4 }
                }
                try? await Task.sleep(nanoseconds: 7_000_000_000)
            }
            await MainActor.run { withAnimation { isDone = true } }
        }
    }
}
