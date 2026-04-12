import SwiftUI

struct ButterflyTapView: View {
    let onComplete: () -> Void

    @State private var tapCount = 0
    @State private var lastSide: Side = .left
    @State private var pulseLeft = false
    @State private var pulseRight = false
    @State private var isDone = false
    @State private var isRunning = false

    enum Side { case left, right }
    private let targetTaps = 30
    private let accent = Color(red: 0.70, green: 0.50, blue: 0.90)
    private let accentR = Color(red: 0.50, green: 0.60, blue: 0.95)

    private var promptText: String {
        let idx = min(tapCount / 6, 4)
        return [
            "Cross your arms over your chest.",
            "Alternately tap your shoulders.",
            "Feel the rhythm calm your body.",
            "Your amygdala is settling down.",
            "Almost there. Keep the rhythm.",
        ][idx]
    }

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.04, blue: 0.10).ignoresSafeArea()
            RadialGradient(
                colors: [accent.opacity(isRunning ? 0.08 : 0.03), .clear],
                center: .center, startRadius: 20, endRadius: 350
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text("CRAVING CALM: BUTTERFLY TAP")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(accent.opacity(0.5)).tracking(1.8)
                    Text(isDone ? "Nicotine craving calmed." : "Calm your craving response")
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    if isRunning && !isDone {
                        Text("\(tapCount) of \(targetTaps) taps")
                            .font(.sansRR(11, weight: .semibold)).foregroundColor(accent.opacity(0.6))
                    }
                }

                Spacer(minLength: 20)

                if isDone {
                    doneView
                } else if isRunning {
                    activeView
                } else {
                    introView
                }

                Spacer(minLength: 24)

                if isDone {
                    Button(action: onComplete) {
                        Text("Craving response calmed \u{2192}")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                } else if !isRunning {
                    Button { withAnimation { isRunning = true } } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "hands.sparkles.fill").font(.system(size: 14))
                            Text("Begin tapping").font(.sansRR(16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [accent, accentR], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: accent.opacity(0.3), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 22)
                }

                Spacer(minLength: 52)
            }
        }
    }

    var introView: some View {
        VStack(spacing: 20) {
            ZStack {
                wingShape(left: true, scale: 1.0, opacity: 0.15)
                wingShape(left: false, scale: 1.0, opacity: 0.15)
            }
            .frame(height: 160)

            Text("Cross your arms over your chest, hands on shoulders.\nAlternately tap left, right, left, right.")
                .font(.sansRR(13)).foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
        }
    }

    var activeView: some View {
        VStack(spacing: 16) {
            ZStack {
                wingShape(left: true, scale: pulseLeft ? 1.15 : 0.95, opacity: pulseLeft ? 0.35 : 0.1)
                wingShape(left: false, scale: pulseRight ? 1.15 : 0.95, opacity: pulseRight ? 0.35 : 0.1)

                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 8, height: 8)
            }
            .frame(height: 170)

            Text(promptText)
                .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center).padding(.horizontal, 28)

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(accent.opacity(0.1)).frame(height: 6)
                    Capsule()
                        .fill(LinearGradient(colors: [accent, accentR], startPoint: .leading, endPoint: .trailing))
                        .frame(width: g.size.width * CGFloat(tapCount) / CGFloat(targetTaps), height: 6)
                        .animation(.spring(response: 0.3), value: tapCount)
                }
            }
            .frame(height: 6).padding(.horizontal, 32)

            HStack(spacing: 16) {
                Button { tap(.left) } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.point.left.fill")
                            .font(.system(size: 24)).foregroundColor(accent)
                        Text("Left")
                            .font(.sansRR(13, weight: .bold)).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(accent.opacity(pulseLeft ? 0.2 : 0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(accent.opacity(0.2), lineWidth: 1))
                }
                Button { tap(.right) } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.point.right.fill")
                            .font(.system(size: 24)).foregroundColor(accentR)
                        Text("Right")
                            .font(.sansRR(13, weight: .bold)).foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 20)
                    .background(accentR.opacity(pulseRight ? 0.2 : 0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(accentR.opacity(0.2), lineWidth: 1))
                }
            }
            .padding(.horizontal, 22)
        }
    }

    var doneView: some View {
        VStack(spacing: 16) {
            ZStack {
                wingShape(left: true, scale: 1.0, opacity: 0.25)
                wingShape(left: false, scale: 1.0, opacity: 0.25)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36)).foregroundColor(accent)
            }
            .frame(height: 140)

            Text("Bilateral stimulation calmed your amygdala's nicotine craving alarm with \(tapCount) taps.")
                .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
        }
    }

    func wingShape(left: Bool, scale: CGFloat, opacity: Double) -> some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [(left ? accent : accentR).opacity(opacity), .clear],
                    center: left ? UnitPoint(x: 0.7, y: 0.5) : UnitPoint(x: 0.3, y: 0.5),
                    startRadius: 5, endRadius: 80
                )
            )
            .frame(width: 120, height: 160)
            .scaleEffect(x: scale, y: scale * 0.9)
            .offset(x: left ? -50 : 50)
            .animation(.spring(response: 0.2), value: scale)
    }

    func tap(_ side: Side) {
        withAnimation(.easeOut(duration: 0.12)) {
            if side == .left { pulseLeft = true } else { pulseRight = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation { if side == .left { pulseLeft = false } else { pulseRight = false } }
        }
        tapCount += 1
        lastSide = side
        if tapCount >= targetTaps { withAnimation { isDone = true } }
    }
}
