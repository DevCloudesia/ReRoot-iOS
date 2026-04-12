import SwiftUI

struct BodyScanView: View {
    let onComplete: () -> Void

    @State private var currentRegion = 0
    @State private var phase: ScanPhase = .ready
    @State private var phaseProgress: CGFloat = 0
    @State private var isDone = false
    @State private var timerTask: Task<Void, Never>?
    @State private var glowIntensity: CGFloat = 0

    enum ScanPhase: String {
        case ready = "Find this area"
        case tense = "Tense..."
        case release = "Release & breathe"
    }

    struct BodyRegion {
        let name: String; let icon: String; let instruction: String
        let y: CGFloat; let color: Color
    }

    private let warmRed = Color(red: 0.85, green: 0.35, blue: 0.30)
    private let calmGreen = Color(red: 0.35, green: 0.75, blue: 0.50)

    private let regions: [BodyRegion] = [
        .init(name: "Jaw & Face", icon: "face.smiling", instruction: "Clench your jaw hard. Scrunch your nose. Squeeze your eyes shut. Hold.", y: 0.12, color: Color(red: 0.85, green: 0.55, blue: 0.35)),
        .init(name: "Shoulders", icon: "figure.arms.open", instruction: "Pull your shoulders up toward your ears. Feel the burn. Hold.", y: 0.30, color: Color(red: 0.55, green: 0.65, blue: 0.85)),
        .init(name: "Hands & Fists", icon: "hand.raised.fill", instruction: "Make the tightest fists you can. Squeeze until knuckles go white.", y: 0.52, color: Color(red: 0.65, green: 0.50, blue: 0.80)),
        .init(name: "Feet & Toes", icon: "shoeprints.fill", instruction: "Curl your toes tight. Press the balls of your feet into the ground.", y: 0.82, color: Color(red: 0.45, green: 0.70, blue: 0.55)),
    ]

    var body: some View {
        let region = regions[min(currentRegion, regions.count - 1)]

        return ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()

            RadialGradient(
                colors: [
                    (phase == .tense ? warmRed : (phase == .release ? calmGreen : region.color)).opacity(0.08),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: CGFloat(region.y * 0.6 + 0.2)),
                startRadius: 20, endRadius: 300
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: phase)

            VStack(spacing: 0) {
                Spacer(minLength: 12)

                VStack(spacing: 4) {
                    Text("WITHDRAWAL TENSION RELEASE")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(region.color.opacity(0.5)).tracking(1.8)
                    Text(isDone ? "Tension released" : region.name)
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    if !isDone {
                        Text("Region \(currentRegion + 1) of \(regions.count)")
                            .font(.sansRR(11)).foregroundColor(region.color.opacity(0.5))
                    }
                }

                Spacer(minLength: 12)

                if isDone {
                    completionView
                } else {
                    activeView(region)
                }

                Spacer(minLength: 40)
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    func activeView(_ region: BodyRegion) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                ForEach(0..<regions.count, id: \.self) { i in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(i < currentRegion ? calmGreen.opacity(0.3) :
                                        (i == currentRegion ? region.color.opacity(0.3) : Color.white.opacity(0.06)))
                                .frame(width: 36, height: 36)
                            Image(systemName: i < currentRegion ? "checkmark" : regions[i].icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(i < currentRegion ? calmGreen :
                                                    (i == currentRegion ? region.color : .white.opacity(0.2)))
                        }
                        Text(regions[i].name.components(separatedBy: " ").first ?? "")
                            .font(.sansRR(8, weight: i == currentRegion ? .bold : .regular))
                            .foregroundColor(i == currentRegion ? .white : .white.opacity(0.25))
                    }
                }
            }
            .padding(.horizontal, 16)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (phase == .tense ? warmRed : (phase == .release ? calmGreen : region.color))
                                    .opacity(phase == .ready ? 0.1 : 0.25),
                                .clear
                            ],
                            center: .center, startRadius: 10, endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .scaleEffect(phase == .tense ? 1.15 : (phase == .release ? 0.85 : 1.0))
                    .animation(.easeInOut(duration: 0.8), value: phase)

                Circle()
                    .stroke(
                        phase == .tense ? warmRed.opacity(0.5) :
                            (phase == .release ? calmGreen.opacity(0.5) : region.color.opacity(0.2)),
                        lineWidth: 2
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: phaseProgress)
                    .stroke(
                        phase == .tense ? warmRed : calmGreen,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Image(systemName: region.icon)
                        .font(.system(size: 28))
                        .foregroundColor(phase == .tense ? warmRed : (phase == .release ? calmGreen : region.color))
                    Text(phase.rawValue)
                        .font(.sansRR(11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Text(phaseInstruction(region))
                .font(.sansRR(13)).foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                .fixedSize(horizontal: false, vertical: true)

            if phase == .ready {
                Button { startRegion() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: region.icon).font(.system(size: 14))
                        Text("Tense \(region.name)")
                            .font(.sansRR(16, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(
                        LinearGradient(colors: [region.color, region.color.opacity(0.7)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(Capsule())
                    .shadow(color: region.color.opacity(0.3), radius: 12, y: 4)
                }
                .padding(.horizontal, 22)
            } else {
                HStack(spacing: 16) {
                    statusBadge(
                        icon: phase == .tense ? "flame.fill" : "wind",
                        text: phase == .tense ? "Tensing..." : "Releasing...",
                        color: phase == .tense ? warmRed : calmGreen
                    )
                }
            }
        }
    }

    var completionView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<regions.count, id: \.self) { i in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle().fill(calmGreen.opacity(0.3)).frame(width: 40, height: 40)
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold)).foregroundColor(calmGreen)
                        }
                        Text(regions[i].name.components(separatedBy: " ").first ?? "")
                            .font(.sansRR(8, weight: .bold)).foregroundColor(calmGreen.opacity(0.6))
                    }
                }
            }

            Text("You released the physical tension that nicotine withdrawal stores in your muscles. Your body proved it can relax without a cigarette.")
                .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)

            Button(action: onComplete) {
                Text("Withdrawal tension released \u{2192}")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22)
        }
    }

    func statusBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(color)
            Text(text).font(.sansRR(11, weight: .bold)).foregroundColor(color.opacity(0.8))
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(color.opacity(0.1)).clipShape(Capsule())
    }

    func phaseInstruction(_ region: BodyRegion) -> String {
        switch phase {
        case .ready:
            return "Take a breath. On the next step, you'll tense your \(region.name.lowercased()) for 5 seconds."
        case .tense:
            return region.instruction
        case .release:
            return "Let go completely. Feel warmth flooding into your \(region.name.lowercased()). Breathe out slowly."
        }
    }

    func startRegion() {
        timerTask?.cancel()
        timerTask = Task {
            await MainActor.run {
                phase = .tense
                withAnimation(.linear(duration: 5)) { phaseProgress = 0.5 }
            }
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                phase = .release
                withAnimation(.linear(duration: 5)) { phaseProgress = 1.0 }
            }
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation {
                    phaseProgress = 0
                    if currentRegion < regions.count - 1 {
                        currentRegion += 1
                        phase = .ready
                    } else {
                        isDone = true
                    }
                }
            }
        }
    }
}
