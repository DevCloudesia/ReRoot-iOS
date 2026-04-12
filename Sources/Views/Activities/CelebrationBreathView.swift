import SwiftUI

struct CelebrationBreathView: View {
    let onComplete: () -> Void

    @State private var phase = 0
    @State private var circleScale: CGFloat = 0.5
    @State private var isDone = false
    @State private var timerTask: Task<Void, Never>?
    @State private var sparkleAngles: [Double] = (0..<16).map { Double($0) * 22.5 }

    private let gold = Color(red: 0.90, green: 0.75, blue: 0.30)
    private let warmGreen = Color(red: 0.45, green: 0.78, blue: 0.45)

    private let steps: [(label: String, desc: String, seconds: Int, scale: CGFloat)] = [
        ("Deep breath in", "Fill your lungs completely. These are YOUR lungs now.", 5, 1.0),
        ("Hold at the top", "Feel that fullness. No smoke. Just clean air.", 3, 1.0),
        ("Slow release", "Let it all out slowly. Feel the warm air leave.", 7, 0.5),
        ("Quick breath in", "A sharp, energizing inhale. Wake up every cell.", 2, 0.9),
        ("Power hold", "Your body is healing. Feel the energy.", 4, 0.9),
        ("Celebration exhale", "A long, satisfied exhale. You're winning.", 6, 0.4),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.10, blue: 0.04), Color(red: 0.06, green: 0.06, blue: 0.04)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            RadialGradient(
                colors: [gold.opacity(isDone ? 0.12 : 0.06), .clear],
                center: .center, startRadius: 20, endRadius: 350
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text("CELEBRATE YOUR QUIT")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(gold.opacity(0.6)).tracking(1.8)
                    Text(isDone ? "Victory claimed." : "You're beating nicotine")
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    if !isDone && timerTask != nil {
                        Text("Step \(phase + 1) of \(steps.count)")
                            .font(.sansRR(11)).foregroundColor(gold.opacity(0.5))
                    }
                }

                Spacer(minLength: 24)

                ZStack {
                    ForEach(0..<16, id: \.self) { i in
                        let dist: CGFloat = isDone ? 140 : (circleScale > 0.7 ? 120 + CGFloat(i % 3) * 10 : 100)
                        Circle()
                            .fill(i % 2 == 0 ? gold.opacity(0.4) : warmGreen.opacity(0.3))
                            .frame(width: isDone ? 6 : 4, height: isDone ? 6 : 4)
                            .offset(
                                x: cos(sparkleAngles[i] * .pi / 180) * dist,
                                y: sin(sparkleAngles[i] * .pi / 180) * dist
                            )
                            .animation(.easeInOut(duration: 1.5), value: circleScale)
                    }

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [gold.opacity(0.30), warmGreen.opacity(0.08), .clear],
                                center: .center, startRadius: 5, endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(circleScale)

                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [gold.opacity(0.5), warmGreen.opacity(0.3), gold.opacity(0.5)],
                                center: .center
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 150, height: 150)

                    if isDone {
                        VStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 36)).foregroundColor(gold)
                            Text("Winner")
                                .font(.sansRR(11, weight: .bold)).foregroundColor(gold.opacity(0.7))
                        }
                    } else {
                        VStack(spacing: 6) {
                            Text(steps[phase].label)
                                .font(.serif(20, weight: .bold)).foregroundColor(.white)
                            Text("\(phase + 1)/\(steps.count)")
                                .font(.sansRR(10)).foregroundColor(gold.opacity(0.4))
                        }
                    }
                }

                Spacer(minLength: 16)

                if !isDone && timerTask != nil {
                    Text(steps[phase].desc)
                        .font(.sansRR(14)).foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)

                    HStack(spacing: 4) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            Capsule()
                                .fill(i <= phase ? gold : gold.opacity(0.15))
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, 32).padding(.top, 12)
                } else if isDone {
                    VStack(spacing: 12) {
                        Text("Your blood oxygen is higher now than when you smoked. Your lungs are healing. This is what winning feels like.")
                            .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)

                        HStack(spacing: 12) {
                            statPill(icon: "lungs.fill", label: "Lungs celebrated")
                            statPill(icon: "star.fill", label: "Quit reinforced")
                        }
                    }
                }

                Spacer(minLength: 24)

                if isDone {
                    Button(action: onComplete) {
                        Text("I'm winning my quit \u{2192}")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(
                                LinearGradient(colors: [gold, warmGreen], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                } else if timerTask == nil {
                    Button { startBreathwork() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "party.popper.fill").font(.system(size: 14))
                            Text("Begin celebration").font(.sansRR(16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [gold, gold.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: gold.opacity(0.3), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 22)
                }

                Spacer(minLength: 52)
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    func statPill(icon: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 10)).foregroundColor(gold)
            Text(label).font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(gold.opacity(0.1)).clipShape(Capsule())
    }

    func startBreathwork() {
        timerTask = Task {
            for (i, step) in steps.enumerated() {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    phase = i
                    withAnimation(.easeInOut(duration: Double(step.seconds))) {
                        circleScale = step.scale
                    }
                }
                try? await Task.sleep(nanoseconds: UInt64(step.seconds) * 1_000_000_000)
            }
            await MainActor.run { withAnimation { isDone = true } }
        }
    }
}
