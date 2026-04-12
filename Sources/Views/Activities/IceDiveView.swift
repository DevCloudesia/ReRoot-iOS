import SwiftUI

struct IceDiveView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var phase: Phase = .intro
    @State private var countdown = 30
    @State private var pulseScale: CGFloat = 1.0
    @State private var breatheIn = false
    @State private var ripplePhase: CGFloat = 0
    @State private var frostOpacity: Double = 0
    @State private var timerTask: Task<Void, Never>?

    enum Phase { case intro, active, done }

    private let iceBlue = Color(red: 0.3, green: 0.75, blue: 0.95)
    private let frostWhite = Color(red: 0.85, green: 0.93, blue: 0.98)

    var body: some View {
        ZStack {
            bgLayer.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text("CRAVING EMERGENCY RESET")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                    Text(phaseTitle)
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)

                Spacer(minLength: 20)

                centerVisual
                    .frame(height: 280)

                Spacer(minLength: 16)

                phaseContent

                Spacer(minLength: 20)

                phaseButton

                Spacer(minLength: 52)
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    // MARK: - Background

    var bgLayer: some View {
        ZStack {
            Color(red: 0.04, green: 0.06, blue: 0.10)

            RadialGradient(
                colors: [iceBlue.opacity(phase == .active ? 0.12 : 0.05), .clear],
                center: .center, startRadius: 40, endRadius: 400
            )
            .animation(.easeInOut(duration: 2), value: phase)

            if phase == .active || phase == .done {
                ForEach(0..<20, id: \.self) { i in
                    frostParticle(index: i)
                }
            }
        }
    }

    func frostParticle(index i: Int) -> some View {
        let size = CGFloat.random(in: 2...5)
        let x = CGFloat.random(in: -180...180)
        let y = CGFloat.random(in: -350...350)
        return Circle()
            .fill(frostWhite.opacity(frostOpacity * Double.random(in: 0.3...0.8)))
            .frame(width: size, height: size)
            .offset(x: x, y: y)
            .blur(radius: 1)
    }

    // MARK: - Center Visual

    var centerVisual: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(iceBlue.opacity(0.08 + Double(i) * 0.04), lineWidth: 1)
                    .frame(width: CGFloat(200 + i * 40), height: CGFloat(200 + i * 40))
                    .scaleEffect(phase == .active ? (ripplePhase + CGFloat(i) * 0.1) : 1.0)
                    .opacity(phase == .active ? Double(1.0 - CGFloat(i) * 0.25) : 0.3)
                    .animation(
                        .easeInOut(duration: 2.5 + Double(i) * 0.3)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.4),
                        value: ripplePhase
                    )
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            iceBlue.opacity(phase == .active ? 0.3 : 0.15),
                            iceBlue.opacity(phase == .active ? 0.08 : 0.03),
                            Color.clear,
                        ],
                        center: .center, startRadius: 5, endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .scaleEffect(pulseScale)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.15, green: 0.35, blue: 0.55).opacity(0.6),
                            Color(red: 0.08, green: 0.20, blue: 0.35).opacity(0.3),
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 10, endRadius: 80
                    )
                )
                .frame(width: 150, height: 150)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [iceBlue.opacity(0.6), iceBlue.opacity(0.1), iceBlue.opacity(0.6)],
                        center: .center
                    ),
                    lineWidth: 2.5
                )
                .frame(width: 150, height: 150)

            if phase == .active {
                Circle()
                    .trim(from: 0, to: CGFloat(countdown) / 30.0)
                    .stroke(iceBlue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: countdown)
            }

            Circle()
                .fill(frostWhite.opacity(0.08))
                .frame(width: 50, height: 40)
                .offset(x: -20, y: -30)
                .blur(radius: 8)

            centerContent
        }
    }

    @ViewBuilder
    var centerContent: some View {
        switch phase {
        case .intro:
            VStack(spacing: 6) {
                Image(systemName: "snowflake")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(iceBlue)
                    .rotationEffect(.degrees(breatheIn ? 30 : 0))
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: breatheIn)
                Text("Ready")
                    .font(.sansRR(11, weight: .bold)).foregroundColor(iceBlue.opacity(0.7))
            }
        case .active:
            VStack(spacing: 4) {
                Text("\(countdown)")
                    .font(.serif(58, weight: .heavy)).foregroundColor(.white).monospacedDigit()
                    .contentTransition(.numericText())
                Text("seconds")
                    .font(.sansRR(10, weight: .medium)).foregroundColor(iceBlue.opacity(0.6))
            }
        case .done:
            VStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(.white, iceBlue.opacity(0.3))
                Text("Reset")
                    .font(.sansRR(11, weight: .bold)).foregroundColor(iceBlue.opacity(0.7))
            }
        }
    }

    var phaseTitle: String {
        switch phase {
        case .intro: return "Nicotine craving reset"
        case .active: return breatheIn ? "Breathe slowly\nthrough your nose" : "Hold the cold.\nFeel your heart slow."
        case .done: return "Craving crushed."
        }
    }

    // MARK: - Phase Content

    @ViewBuilder
    var phaseContent: some View {
        switch phase {
        case .intro:
            VStack(spacing: 14) {
                instructionRow(icon: "drop.fill", text: "Splash cold water on your face", color: iceBlue)
                instructionRow(icon: "cube.fill", text: "Or hold ice cubes in both hands", color: frostWhite)
                instructionRow(icon: "heart.fill", text: "Your dive reflex instantly slows your heart", color: iceBlue)
            }
            .padding(.horizontal, 28)

            Text("The fastest physical way to break a nicotine craving.")
                .font(.sansRR(12)).foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center).padding(.horizontal, 32).padding(.top, 10)

        case .active:
            HStack(spacing: 20) {
                activeStatPill(icon: "heart.fill", value: "Slowing", label: "HEART RATE")
                activeStatPill(icon: "snowflake", value: "Active", label: "DIVE REFLEX")
                activeStatPill(icon: "brain.head.profile", value: "Fading", label: "CRAVING")
            }
            .padding(.horizontal, 22)

        case .done:
            VStack(spacing: 8) {
                Text("Your nervous system just proved it doesn't need a cigarette to calm down.")
                    .font(.sansRR(14)).foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                HStack(spacing: 16) {
                    doneStat(icon: "heart.fill", label: "Heart rate lowered")
                    doneStat(icon: "bolt.slash.fill", label: "Craving disrupted")
                }
                .padding(.top, 6)
            }
        }
    }

    func instructionRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 15)).foregroundColor(color)
            }
            Text(text)
                .font(.sansRR(14)).foregroundColor(.white.opacity(0.7))
            Spacer()
        }
    }

    func activeStatPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(iceBlue)
            Text(value).font(.sansRR(12, weight: .bold)).foregroundColor(.white)
            Text(label).font(.sansRR(8, weight: .bold)).foregroundColor(.white.opacity(0.3)).tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    func doneStat(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(iceBlue)
            Text(label).font(.sansRR(11, weight: .semibold)).foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(iceBlue.opacity(0.08)).clipShape(Capsule())
    }

    // MARK: - Button

    @ViewBuilder
    var phaseButton: some View {
        switch phase {
        case .intro:
            Button { startDive() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "snowflake").font(.system(size: 14))
                    Text("I'm ready, start timer")
                        .font(.sansRR(16, weight: .bold))
                }
                .foregroundColor(Color(red: 0.05, green: 0.10, blue: 0.18))
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(
                    LinearGradient(colors: [frostWhite, iceBlue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(Capsule())
                .shadow(color: iceBlue.opacity(0.3), radius: 12, y: 4)
            }
            .padding(.horizontal, 22)
        case .active:
            EmptyView()
        case .done:
            Button(action: onComplete) {
                Text("I beat the craving \u{2192}")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22)
        }
    }

    // MARK: - Timer

    func startDive() {
        withAnimation(.easeOut(duration: 0.5)) { phase = .active }
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            ripplePhase = 1.2
            breatheIn = true
        }
        withAnimation(.easeOut(duration: 1.5)) { frostOpacity = 1 }

        timerTask = Task {
            while countdown > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    withAnimation(.spring(response: 0.4)) {
                        countdown -= 1
                        pulseScale = countdown % 4 < 2 ? 1.06 : 0.96
                    }
                }
            }
            await MainActor.run {
                withAnimation(.spring(response: 0.5)) { phase = .done; pulseScale = 1.0 }
            }
        }
    }
}
