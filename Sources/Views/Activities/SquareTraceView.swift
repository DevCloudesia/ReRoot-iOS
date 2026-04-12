import SwiftUI

struct SquareTraceView: View {
    let onComplete: () -> Void

    @State private var currentSide = 0
    @State private var currentCycle = 0
    @State private var progress: CGFloat = 0
    @State private var isRunning = false
    @State private var isDone = false
    @State private var timerTask: Task<Void, Never>?
    @State private var glowPulse: CGFloat = 0

    private let sides = ["Breathe In", "Hold", "Breathe Out", "Hold"]
    private let totalCycles = 3
    private let secondsPerSide = 4
    private let accent = Color(red: 0.35, green: 0.85, blue: 0.75)
    private let sideColors: [Color] = [
        Color(red: 0.35, green: 0.85, blue: 0.75),
        Color(red: 0.55, green: 0.75, blue: 0.95),
        Color(red: 0.75, green: 0.55, blue: 0.90),
        Color(red: 0.55, green: 0.75, blue: 0.95),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.08, blue: 0.10).ignoresSafeArea()

            RadialGradient(
                colors: [sideColors[currentSide].opacity(isRunning ? 0.08 : 0.03), .clear],
                center: .center, startRadius: 20, endRadius: 350
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text("CRAVING CALM: SQUARE TRACE")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(accent.opacity(0.5)).tracking(1.8)
                    Text(isDone ? "Craving calmed." : sides[currentSide])
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    if !isDone && isRunning {
                        Text("Cycle \(currentCycle + 1) of \(totalCycles)")
                            .font(.sansRR(11)).foregroundColor(accent.opacity(0.5))
                    }
                }

                Spacer(minLength: 30)

                ZStack {
                    ForEach(0..<4, id: \.self) { i in
                        sideSegment(i)
                    }

                    ForEach(0..<4, id: \.self) { i in
                        cornerDot(i)
                    }

                    if isRunning {
                        tracerDot
                    }

                    VStack(spacing: 4) {
                        if isDone {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 36)).foregroundColor(accent)
                        } else {
                            Text("\(secondsPerSide)s")
                                .font(.sansRR(22, weight: .bold)).foregroundColor(.white.opacity(0.6))
                                .monospacedDigit()
                            Text("per side")
                                .font(.sansRR(9)).foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
                .frame(width: 220, height: 220)

                Spacer(minLength: 24)

                if isRunning && !isDone {
                    HStack(spacing: 12) {
                        ForEach(0..<4, id: \.self) { i in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(i == currentSide ? sideColors[i] : sideColors[i].opacity(0.15))
                                    .frame(width: 8, height: 8)
                                Text(sides[i])
                                    .font(.sansRR(9, weight: i == currentSide ? .bold : .regular))
                                    .foregroundColor(i == currentSide ? .white : .white.opacity(0.3))
                            }
                        }
                    }
                }

                if !isRunning && !isDone {
                    Text("Follow the light around the square.\nBreathe with each side.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center).padding(.horizontal, 28)
                }

                Spacer(minLength: 24)

                if isDone {
                    VStack(spacing: 12) {
                        Text("Square breathing resets your autonomic nervous system.\nNicotine craving signals just got quieter.")
                            .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center).padding(.horizontal, 28)
                        Button(action: onComplete) {
                            Text("Craving handled \u{2192}")
                                .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                                .frame(maxWidth: .infinity).padding(.vertical, 18)
                                .background(Color.white).clipShape(Capsule())
                        }
                        .padding(.horizontal, 22)
                    }
                } else if !isRunning {
                    Button { startTrace() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.dashed").font(.system(size: 14))
                            Text("Begin tracing")
                                .font(.sansRR(16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [accent, accent.opacity(0.7)],
                                           startPoint: .leading, endPoint: .trailing)
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

    func sideSegment(_ i: Int) -> some View {
        let corners: [CGPoint] = [
            CGPoint(x: 10, y: 10),
            CGPoint(x: 210, y: 10),
            CGPoint(x: 210, y: 210),
            CGPoint(x: 10, y: 210),
        ]
        let from = corners[i]
        let to = corners[(i + 1) % 4]

        let isPast = isRunning && (currentSide > i || (currentSide == i && progress > 0))
        let isCurrent = isRunning && currentSide == i

        return Path { p in
            p.move(to: from)
            p.addLine(to: to)
        }
        .stroke(
            isCurrent ? sideColors[i].opacity(0.6) :
                (isPast ? sideColors[i].opacity(0.3) : Color.white.opacity(0.08)),
            style: StrokeStyle(lineWidth: isCurrent ? 3 : 1.5, lineCap: .round)
        )
    }

    func cornerDot(_ i: Int) -> some View {
        let corners: [CGPoint] = [
            CGPoint(x: 10, y: 10),
            CGPoint(x: 210, y: 10),
            CGPoint(x: 210, y: 210),
            CGPoint(x: 10, y: 210),
        ]
        let labels = ["IN", "HOLD", "OUT", "HOLD"]
        let pt = corners[i]
        return VStack(spacing: 2) {
            Circle()
                .fill(isRunning && i == currentSide ? sideColors[i] : Color.white.opacity(0.15))
                .frame(width: 10, height: 10)
            Text(labels[i])
                .font(.sansRR(7, weight: .bold))
                .foregroundColor(isRunning && i == currentSide ? sideColors[i] : .white.opacity(0.2))
        }
        .position(x: pt.x, y: pt.y)
    }

    var tracerDot: some View {
        let corners: [CGPoint] = [
            CGPoint(x: 10, y: 10),
            CGPoint(x: 210, y: 10),
            CGPoint(x: 210, y: 210),
            CGPoint(x: 10, y: 210),
        ]
        let from = corners[currentSide]
        let to = corners[(currentSide + 1) % 4]
        let x = from.x + (to.x - from.x) * progress
        let y = from.y + (to.y - from.y) * progress

        return ZStack {
            Circle()
                .fill(sideColors[currentSide].opacity(0.3))
                .frame(width: 28, height: 28)
                .blur(radius: 6)
            Circle()
                .fill(sideColors[currentSide])
                .frame(width: 12, height: 12)
        }
        .position(x: x, y: y)
    }

    func startTrace() {
        isRunning = true
        timerTask = Task {
            for cycle in 0..<totalCycles {
                guard !Task.isCancelled else { return }
                await MainActor.run { currentCycle = cycle }
                for side in 0..<sides.count {
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        currentSide = side
                        withAnimation(.linear(duration: Double(secondsPerSide))) { progress = 1.0 }
                    }
                    try? await Task.sleep(nanoseconds: UInt64(secondsPerSide) * 1_000_000_000)
                    await MainActor.run { progress = 0 }
                }
            }
            await MainActor.run { withAnimation { isDone = true; isRunning = false } }
        }
    }
}
