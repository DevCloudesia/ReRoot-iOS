import SwiftUI

struct TreeLandingView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    @EnvironmentObject var hkManager: HealthKitManager
    var onCheckInComplete: (() -> Void)? = nil
    var onClose: (() -> Void)? = nil

    @State private var selectedEmotion: Int? = nil
    @State private var showConfirm = false
    @State private var showFlow = false
    @State private var flowJustFinished = false
    @State private var showNearbyHelp = false
    @StateObject private var nearbyManager = NearbyHelpLocationManager()
    @State private var appear = false
    @State private var animatedGrowth: CGFloat = 0
    @State private var breathePhase = false
    @State private var bgIndex: Int = {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let hour = Calendar.current.component(.hour, from: Date())
        return (day * 3 + hour) % 20
    }()

    private let emotions: [(icon: String, label: String, color: Color)] = [
        ("bolt.heart.fill",   "Struggling", Color(red: 0.82, green: 0.35, blue: 0.35)),
        ("cloud.rain.fill",   "Tough",      Color(red: 0.78, green: 0.58, blue: 0.30)),
        ("minus.circle",      "Steady",     Color(red: 0.45, green: 0.55, blue: 0.72)),
        ("sun.max.fill",      "Good",       Color(red: 0.38, green: 0.68, blue: 0.42)),
        ("sparkles",          "Thriving",   Color(red: 0.28, green: 0.65, blue: 0.62)),
    ]

    private let calmPalettes: [[Color]] = [
        [Color(red: 0.95, green: 0.97, blue: 0.94), Color(red: 0.89, green: 0.94, blue: 0.87)],
        [Color(red: 0.92, green: 0.95, blue: 0.97), Color(red: 0.85, green: 0.91, blue: 0.96)],
        [Color(red: 0.96, green: 0.94, blue: 0.91), Color(red: 0.91, green: 0.88, blue: 0.84)],
        [Color(red: 0.93, green: 0.92, blue: 0.97), Color(red: 0.87, green: 0.85, blue: 0.94)],
        [Color(red: 0.97, green: 0.95, blue: 0.91), Color(red: 0.94, green: 0.91, blue: 0.85)],
        [Color(red: 0.91, green: 0.96, blue: 0.95), Color(red: 0.84, green: 0.93, blue: 0.91)],
        [Color(red: 0.96, green: 0.93, blue: 0.95), Color(red: 0.91, green: 0.87, blue: 0.91)],
        [Color(red: 0.94, green: 0.97, blue: 0.95), Color(red: 0.87, green: 0.94, blue: 0.89)],
        [Color(red: 0.95, green: 0.93, blue: 0.90), Color(red: 0.91, green: 0.87, blue: 0.82)],
        [Color(red: 0.90, green: 0.95, blue: 0.97), Color(red: 0.82, green: 0.91, blue: 0.96)],
        [Color(red: 0.97, green: 0.96, blue: 0.93), Color(red: 0.93, green: 0.91, blue: 0.87)],
        [Color(red: 0.93, green: 0.95, blue: 0.91), Color(red: 0.86, green: 0.91, blue: 0.84)],
        [Color(red: 0.95, green: 0.91, blue: 0.93), Color(red: 0.91, green: 0.85, blue: 0.89)],
        [Color(red: 0.91, green: 0.93, blue: 0.97), Color(red: 0.84, green: 0.87, blue: 0.94)],
        [Color(red: 0.97, green: 0.93, blue: 0.90), Color(red: 0.94, green: 0.89, blue: 0.83)],
        [Color(red: 0.90, green: 0.97, blue: 0.93), Color(red: 0.82, green: 0.94, blue: 0.87)],
        [Color(red: 0.93, green: 0.90, blue: 0.95), Color(red: 0.87, green: 0.83, blue: 0.91)],
        [Color(red: 0.97, green: 0.97, blue: 0.91), Color(red: 0.94, green: 0.93, blue: 0.85)],
        [Color(red: 0.91, green: 0.97, blue: 0.97), Color(red: 0.84, green: 0.94, blue: 0.94)],
        [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.89, green: 0.89, blue: 0.94)],
    ]

    var body: some View {
        ZStack {
            bgGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                topSection
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -12)
                    .animation(.easeOut(duration: 0.5), value: appear)

                Spacer(minLength: 8)

                treeSection
                    .scaleEffect(appear ? 1 : 0.8)
                    .opacity(appear ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1), value: appear)

                Spacer(minLength: 12)

                moodSelector
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appear)

                Spacer(minLength: 12)

                bottomBar
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.35), value: appear)
            }
            .padding(.top, 8)
            .padding(.bottom, 90)

            if showConfirm, let idx = selectedEmotion {
                confirmOverlay(idx)
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
            }
        }
        .onAppear {
            withAnimation { appear = true }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                breathePhase = true
            }
            let status = nearbyManager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                nearbyManager.startLocating()
            } else if status == .notDetermined {
                nearbyManager.requestPermission()
            }
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            withAnimation(.easeInOut(duration: 4)) {
                bgIndex = (bgIndex + 1) % calmPalettes.count
            }
        }
        .fullScreenCover(isPresented: $showFlow, onDismiss: {
            if flowJustFinished {
                flowJustFinished = false
                onCheckInComplete?()
            }
        }) {
            GuidedCheckInFlow(
                isPresented: $showFlow,
                preSelectedMood: selectedEmotion,
                onFlowComplete: { flowJustFinished = true }
            )
            .environmentObject(state)
            .environmentObject(gamification)
        }
        .sheet(isPresented: $showNearbyHelp) {
            NearbyHelpView(locManager: nearbyManager)
        }
    }

    var bgGradient: some View {
        let pal = calmPalettes[bgIndex % calmPalettes.count]
        return ZStack {
            LinearGradient(colors: [pal[0], pal[1]], startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(pal[0].opacity(0.3))
                .frame(width: 300)
                .blur(radius: 80)
                .offset(x: -60, y: -180)
            Circle()
                .fill(pal[1].opacity(0.2))
                .frame(width: 250)
                .blur(radius: 70)
                .offset(x: 80, y: 120)
        }
    }

    // MARK: - Top Section

    var topSection: some View {
        VStack(spacing: 4) {
            HStack {
                if let close = onClose {
                    Button(action: close) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.rText3.opacity(0.35))
                    }
                } else {
                    Color.clear.frame(width: 26, height: 26)
                }

                Spacer()
                Text(currentTimeString)
                    .font(.sansRR(11, weight: .medium))
                    .foregroundColor(.rText3)
                Spacer()

                Button { showNearbyHelp = true } label: {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.rText3.opacity(0.35))
                }
            }
            .padding(.horizontal, 20)

            Text(greeting)
                .font(.serif(26, weight: .bold))
                .foregroundColor(.rText)

            HStack(spacing: 6) {
                Image(systemName: "leaf.fill").font(.system(size: 10)).foregroundColor(.rAccent)
                Text(dayLabel)
                    .font(.sansRR(12, weight: .medium))
                    .foregroundColor(.rAccent)
            }

            if state.honestStreak > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").font(.system(size: 10)).foregroundColor(.rAmber)
                    Text("\(state.honestStreak)-day honest streak")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.rAmber)
                }
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color.rAmber.opacity(0.1)).clipShape(Capsule())
                .padding(.top, 2)
            }

            if state.lapsedToday {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise").font(.system(size: 10)).foregroundColor(.rAmber)
                    Text("Recovering. Your tree is healing.")
                        .font(.sansRR(10, weight: .semibold)).foregroundColor(.rAmber)
                }
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Color.rAmber.opacity(0.08)).clipShape(Capsule())
                .padding(.top, 2)
            }

            if let yMood = state.yesterdayMood {
                let moodLabels = ["struggling", "fighting withdrawal", "holding steady", "doing well", "thriving"]
                let label = yMood.mood >= 0 && yMood.mood < moodLabels.count ? moodLabels[yMood.mood] : "okay"
                Text("Yesterday: \(label)")
                    .font(.sansRR(10)).foregroundColor(.rText3)
                    .padding(.top, 2)
            }
        }
    }

    // MARK: - Tree

    var treeGrowth: CGFloat {
        let d = state.elapsed / 86400
        let timeBased: CGFloat
        switch d {
        case ..<0.04:  timeBased = 0.55
        case ..<1:     timeBased = 0.62
        case ..<3:     timeBased = 0.70
        case ..<7:     timeBased = 0.78
        case ..<14:    timeBased = 0.86
        case ..<30:    timeBased = 0.93
        default:       timeBased = 1.0
        }
        let healthFactor = CGFloat(state.treeHealthScore)
        var growth = timeBased * (0.7 + 0.3 * healthFactor)
        if state.lapsedToday { growth *= 0.9 }
        return growth
    }

    var treeSection: some View {
        let s = animatedGrowth
        let breatheScale: CGFloat = breathePhase ? 1.015 : 0.985

        return ZStack {
            Ellipse()
                .fill(Color(red: 0.42, green: 0.56, blue: 0.34).opacity(0.10))
                .frame(width: 160 * s + 40, height: 18)
                .offset(y: 100)

            VStack(spacing: -14 * s) {
                ZStack {
                    canopyLayer(w: 110 * s + 40, h: 90 * s + 30, dx: -18 * s, dy: 14 * s,
                                c: Color(red: 0.22, green: 0.48, blue: 0.26), o: 0.45)
                    canopyLayer(w: 120 * s + 45, h: 95 * s + 35, dx: 14 * s, dy: 8 * s,
                                c: Color(red: 0.26, green: 0.53, blue: 0.30), o: 0.50)
                    canopyLayer(w: 130 * s + 50, h: 105 * s + 38, dx: 0, dy: 0,
                                c: Color(red: 0.30, green: 0.58, blue: 0.34), o: 0.65)
                    canopyLayer(w: 90 * s + 30, h: 70 * s + 24, dx: -6 * s, dy: -14 * s,
                                c: Color(red: 0.36, green: 0.64, blue: 0.38), o: 0.50)

                    Ellipse()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 55 * s + 16, height: 36 * s + 10)
                        .offset(x: -20 * s, y: -22 * s)

                    if s > 0.55 {
                        blossoms(scale: s)
                    }
                }
                .scaleEffect(breatheScale)
                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: breathePhase)

                trunk(scale: s)
            }
        }
        .frame(height: 260)
        .onAppear {
            withAnimation(.easeOut(duration: 1.6)) {
                animatedGrowth = treeGrowth
            }
        }
    }

    func canopyLayer(w: CGFloat, h: CGFloat, dx: CGFloat, dy: CGFloat, c: Color, o: Double) -> some View {
        Ellipse()
            .fill(c.opacity(o))
            .frame(width: max(w, 0), height: max(h, 0))
            .offset(x: dx, y: dy)
    }

    func trunk(scale s: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.52, green: 0.38, blue: 0.24),
                        Color(red: 0.42, green: 0.30, blue: 0.18),
                        Color(red: 0.38, green: 0.26, blue: 0.16),
                    ],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(width: 14 * s + 10, height: 40 * s + 30)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.06))
                    .frame(width: 3)
                    .offset(x: 2 * s)
            )
    }

    func blossoms(scale s: CGFloat) -> some View {
        let colors: [Color] = [
            Color(red: 0.94, green: 0.82, blue: 0.88),
            Color(red: 0.96, green: 0.90, blue: 0.68),
            Color(red: 0.88, green: 0.94, blue: 0.76),
            Color(red: 0.84, green: 0.72, blue: 0.80),
            Color(red: 0.76, green: 0.90, blue: 0.84),
            Color(red: 0.95, green: 0.84, blue: 0.74),
            Color(red: 0.90, green: 0.86, blue: 0.94),
            Color(red: 0.82, green: 0.94, blue: 0.88),
        ]
        let positions: [(CGFloat, CGFloat)] = [
            (-36, -26), (40, -12), (-18, 18), (28, 24),
            (0, -38), (-42, 8), (16, -30), (-30, -6)
        ]
        let count = min(positions.count, Int((s - 0.55) / 0.05) + 2)

        return ForEach(0..<count, id: \.self) { i in
            blossomDot(i: i, scale: s, colors: colors, positions: positions)
        }
    }

    private func blossomDot(i: Int, scale s: CGFloat, colors: [Color], positions: [(CGFloat, CGFloat)]) -> some View {
        let size: CGFloat = 6 + CGFloat(i % 3) * 1.5
        let pos = positions[i]
        let c = colors[i % colors.count]
        return Circle()
            .fill(c.opacity(0.75))
            .frame(width: size, height: size)
            .offset(x: pos.0 * s, y: pos.1 * s)
            .opacity(min(Double(s - 0.55) * 3.0, 1.0))
    }

    // MARK: - Mood Selector

    var moodSelector: some View {
        VStack(spacing: 14) {
            Text("How are you feeling right now?")
                .font(.sansRR(15, weight: .semibold))
                .foregroundColor(.rText)

            HStack(spacing: 10) {
                ForEach(emotions.indices, id: \.self) { i in
                    moodPill(i)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    func moodPill(_ i: Int) -> some View {
        let sel = selectedEmotion == i
        let e = emotions[i]

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedEmotion = i
                showConfirm = true
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(sel ? e.color : e.color.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Image(systemName: e.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(sel ? .white : e.color)
                }

                Text(e.label)
                    .font(.sansRR(9, weight: .bold))
                    .foregroundColor(sel ? e.color : .rText3)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(sel ? 1.08 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Bar

    var bottomBar: some View {
        VStack(spacing: 8) {
            if let lastSkill = yesterdaySkillName {
                Text("Yesterday you practiced \(lastSkill)")
                    .font(.sansRR(10)).foregroundColor(.rText3)
            }
        }
    }

    // MARK: - Confirm Overlay

    func confirmOverlay(_ idx: Int) -> some View {
        let e = emotions[idx]
        return ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) { showConfirm = false; selectedEmotion = nil }
                }

            VStack(spacing: 18) {
                ZStack {
                    Circle().fill(e.color.opacity(0.12)).frame(width: 72, height: 72)
                    Image(systemName: e.icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(e.color)
                }

                VStack(spacing: 6) {
                    Text("Feeling \(e.label.lowercased()) today?")
                        .font(.serif(22, weight: .bold)).foregroundColor(.rText)
                    Text(confirmSubtext(idx))
                        .font(.sansRR(13)).foregroundColor(.rText2)
                        .multilineTextAlignment(.center).lineSpacing(3)
                }

                if idx == 0 {
                    Button {
                        withAnimation { showConfirm = false }
                        showNearbyHelp = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse").font(.system(size: 13, weight: .semibold))
                            Text("Find support nearby").font(.sansRR(13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(e.color).clipShape(Capsule())
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.3)) { showConfirm = false; selectedEmotion = nil }
                    } label: {
                        Text("Cancel")
                            .font(.sansRR(14, weight: .semibold)).foregroundColor(.rText3)
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95)).clipShape(Capsule())
                    }
                    Button {
                        withAnimation { showConfirm = false }
                        state.logMood(idx)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { showFlow = true }
                    } label: {
                        Text("Start check-in")
                            .font(.sansRR(14, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 13)
                            .background(e.color).clipShape(Capsule())
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 20, y: 6)
            .padding(.horizontal, 28)
        }
    }

    func confirmSubtext(_ idx: Int) -> String {
        switch idx {
        case 0: return "It's okay to have hard days. We're here for you, and we have some things that might help."
        case 1: return "Tough moments don't last forever. Let's take a few minutes together."
        case 2: return "Steady is strong. Let's keep this going, one step at a time."
        case 3: return "You're doing so well. Let's take a moment to appreciate that."
        default: return "What a good day. Let's make the most of this feeling."
        }
    }

    // MARK: - Helpers

    var dayLabel: String {
        if state.lapsedToday {
            return "Day \(state.dayNum) \u{00B7} Still on your journey"
        }
        return "Day \(state.dayNum) smoke-free \u{00B7} \(state.cigsAvoided) cigarettes not smoked"
    }

    var yesterdaySkillName: String? {
        let cal = Calendar.current
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) else { return nil }
        let skillNames: [String: String] = [
            "breathing-fourSevenEight": "4-7-8 breathing", "breathing-boxBreathing": "box breathing",
            "breathing-physiologicalSigh": "the physiological sigh", "urgeSurf": "urge surfing",
            "iceDive": "the ice dive reset", "serial7s": "serial 7s", "sensory": "5-4-3-2-1 grounding",
            "bodyScan": "body scanning", "thoughtDefusion": "thought defusion",
            "squareTrace": "square breathing", "emotionWheel": "emotion labeling",
            "butterflyTap": "butterfly tapping", "lovingKindness": "loving-kindness",
            "visualization": "visualization", "fingerTap": "finger tapping",
            "gratitudeGarden": "gratitude practice", "affirmationCards": "quit affirmations",
            "colorBreathing": "color breathing", "mindfulListening": "mindful listening",
            "cognitiveReframe": "cognitive reframing", "wordScramble": "word scramble",
            "safePlaceBuilder": "safe place building", "joyMapping": "joy mapping",
            "patternMemory": "pattern memory", "celebrationBreath": "celebration breathwork",
        ]
        guard let entry = state.skillLog.last(where: { cal.isDate($0.date, inSameDayAs: yesterday) }) else { return nil }
        return skillNames[entry.skillId] ?? entry.skillId
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = state.userName.isEmpty ? "" : ", \(state.userName)"
        if hour < 12 { return "Good morning\(name)" }
        if hour < 17 { return "Good afternoon\(name)" }
        return "Good evening\(name)"
    }

    var currentTimeString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date())
    }
}
