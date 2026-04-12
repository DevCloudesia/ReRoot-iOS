import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var hkManager: HealthKitManager
    @EnvironmentObject var gamification: GamificationState
    @EnvironmentObject var nudgeEngine: NudgeEngine
    @Binding var showSOS: Bool
    @Binding var switchTab: Int

    @State private var pledgeAnimation  = false
    @State private var showCheckIn      = false

    private let moods: [(emoji: String, label: String)] = [
        ("😣", "Struggling"), ("😟", "Tough"), ("😐", "Okay"), ("🙂", "Good"), ("😊", "Great")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // ── Hero Header ──
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [Color.rDark, Color(red: 0.176, green: 0.165, blue: 0.149),
                                 Color(red: 0.24, green: 0.22, blue: 0.196)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ).frame(maxWidth: .infinity)

                    Circle().fill(Color.rAccent.opacity(0.07)).frame(width: 300).offset(x: -60, y: 80)
                    Circle().fill(Color.rAmber.opacity(0.05)).frame(width: 200).offset(x: 140, y: 30)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SMOKE-FREE FOR")
                                    .font(.sansRR(10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.38)).tracking(2)
                                HStack(alignment: .lastTextBaseline, spacing: 8) {
                                    Text(timerBig)
                                        .font(.serif(58, weight: .heavy)).foregroundColor(.white).monospacedDigit()
                                        .contentTransition(.numericText())
                                    Text(timerUnit)
                                        .font(.sansRR(20, weight: .medium)).foregroundColor(.white.opacity(0.52))
                                }
                                if !timerSub.isEmpty {
                                    Text(timerSub).font(.sansRR(12)).foregroundColor(.white.opacity(0.3))
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("🌿").font(.system(size: 32))
                                // Streak badge
                                if gamification.currentStreak > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bolt.fill")
                                            .font(.system(size: 10)).foregroundColor(.rAmber)
                                        Text("\(gamification.currentStreak)d")
                                            .font(.sansRR(11, weight: .bold)).foregroundColor(.rAmber)
                                    }
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.rAmber.opacity(0.15))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.rAmber.opacity(0.3), lineWidth: 1))
                                }
                                // HRV stress indicator
                                if hkManager.authorized && hkManager.stressSignalDetected {
                                    HStack(spacing: 4) {
                                        Circle().fill(Color.rDanger)
                                            .frame(width: 6, height: 6)
                                            .scaleEffect(pledgeAnimation ? 1.3 : 1.0)
                                            .animation(.easeInOut(duration: 0.8).repeatForever(), value: pledgeAnimation)
                                        Text("HRV ⚠").font(.sansRR(10, weight: .bold)).foregroundColor(.rDanger)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 24)

                        // Stats
                        HStack(spacing: 8) {
                            StatPill(value: "$\(String(format: "%.2f", state.moneySaved))", label: "Saved")
                            StatPill(value: "\(state.daysSinceLastLapse)d", label: "Smoke-free")
                            StatPill(value: "\(gamification.currentStreak)d", label: "Streak")
                        }
                        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 22)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 0))

                VStack(spacing: 14) {

                    // ── Nudge Banner (JITAI / Loss Aversion / Kindling) ──
                    if let nudge = nudgeEngine.activeNudge {
                        NudgeBannerView(nudge: nudge) {
                            nudgeEngine.dismiss()
                        } onCTA: {
                            nudgeEngine.dismiss()
                            if nudge.category == .jitai || nudge.category == .momentum {
                                switchTab = 2  // Breathe tab
                            }
                        }
                        .padding(.top, 4)
                    }

                    // ── Daily Pledge Card ──
                    DailyPledgeCard(pledgeAnimation: $pledgeAnimation)
                        .environmentObject(state)
                        .environmentObject(gamification)

                    // ── Right Now Card ──
                    let rn = state.rightNow
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Circle().fill(state.phaseColor).frame(width: 8, height: 8)
                                .shadow(color: state.phaseColor, radius: 4)
                            Text("RIGHT NOW · HOUR \(Int(state.elapsed / 3600))")
                                .font(.sansRR(10, weight: .bold))
                                .foregroundColor(state.phaseColor).tracking(1.5)
                        }
                        Text(rn.title).font(.serif(20, weight: .bold)).foregroundColor(.rText)
                        Text(rn.body).font(.sansRR(13)).foregroundColor(.rText2).lineSpacing(3)
                    }
                    .padding(18).frame(maxWidth: .infinity, alignment: .leading)
                    .background(state.phaseColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(state.phaseColor.opacity(0.2), lineWidth: 1))

                    // ── SOS Craving Button ──
                    Button {
                        state.logCraving()
                        gamification.checkAchievements(elapsed: state.elapsed)
                        showSOS = true
                    } label: {
                        HStack {
                            Image(systemName: "sos.circle.fill").font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Craving SOS").font(.sansRR(16, weight: .bold))
                                Text("Tap to beat it in 3 minutes · \(state.cravingLog.count) resisted so far")
                                    .font(.sansRR(11))
                            }
                            Spacer()
                            Image(systemName: "chevron.right.2").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white).padding(16)
                        .background(LinearGradient(colors: [Color.rAmber, Color(red: 0.83, green: 0.54, blue: 0.35)],
                                                   startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.rAmber.opacity(0.35), radius: 12, y: 4)
                    }

                    // ── Guided Check-In (replaces inline mood buttons) ──
                    CheckInEntryCard(
                        currentMood: state.currentMood,
                        moods: moods,
                        futureMessage: state.randomFutureMessage
                    ) {
                        showCheckIn = true
                    }

                    // ── Next Milestone ──
                    if let (ms, pct) = state.nextMilestone {
                        RRCard {
                            HStack(alignment: .center, spacing: 16) {
                                ZStack {
                                    Circle().stroke(Color.rBg2, lineWidth: 5).frame(width: 56, height: 56)
                                    Circle().trim(from: 0, to: pct)
                                        .stroke(Color.rAccent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                        .frame(width: 56, height: 56).rotationEffect(.degrees(-90))
                                        .animation(.easeOut(duration: 1.0), value: pct)
                                    Text("\(Int(pct*100))%")
                                        .font(.sansRR(11, weight: .bold)).foregroundColor(.rAccent)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("NEXT MILESTONE · \(ms.label)")
                                        .font(.sansRR(10, weight: .bold)).foregroundColor(.rAccent).tracking(0.5)
                                    Text(ms.title).font(.sansRR(15, weight: .semibold)).foregroundColor(.rText)
                                    Text(ms.body).font(.sansRR(12)).foregroundColor(.rText2).lineSpacing(2)
                                }
                            }
                        }
                    }

                    // ── Active Symptoms Preview ──
                    let symptoms = state.activeSymptoms
                    if !symptoms.isEmpty {
                        RRCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    SectionHeader(icon: "🩺", title: "What You're Likely Feeling")
                                    Spacer()
                                    Button { switchTab = 1 } label: {
                                        Text("See all").font(.sansRR(12, weight: .semibold)).foregroundColor(.rAccent)
                                    }
                                }
                                ForEach(symptoms.prefix(3), id: \.symptom.id) { item in
                                    HStack(spacing: 10) {
                                        Text(item.symptom.icon).font(.system(size: 20)).frame(width: 26)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.symptom.name)
                                                .font(.sansRR(13, weight: .semibold)).foregroundColor(.rText)
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 2).fill(Color.rBg2).frame(height: 4)
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(intensityColor(item.intensity))
                                                        .frame(width: geo.size.width * item.intensity, height: 4)
                                                        .animation(.easeOut(duration: 0.8), value: item.intensity)
                                                }
                                            }.frame(height: 4)
                                        }
                                        Text("\(Int(item.intensity * 100))%")
                                            .font(.sansRR(11, weight: .semibold)).foregroundColor(.rText3)
                                            .frame(width: 36, alignment: .trailing)
                                    }
                                }
                            }
                        }
                    }

                    // ── HealthKit Nudge Refresh ──
                    Color.clear.frame(height: 1)
                        .onAppear {
                            pledgeAnimation = true
                            nudgeEngine.evaluate(state: state, hkManager: hkManager, gamification: gamification)
                            nudgeEngine.scheduleEveningCheckInReminder(pledgedToday: gamification.pledgedToday)
                            nudgeEngine.scheduleMorningMomentumReminder()
                        }
                }
                .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 100)
            }
        }
        .background(Color.rBg.ignoresSafeArea())
        .fullScreenCover(isPresented: $showCheckIn) {
            GuidedCheckInFlow(isPresented: $showCheckIn)
                .environmentObject(state)
                .environmentObject(gamification)
        }
    }

    // MARK: - Timer formatting
    private var timerBig: String {
        let d = Int(state.elapsed / 86400)
        let h = Int((state.elapsed.truncatingRemainder(dividingBy: 86400)) / 3600)
        let m = Int((state.elapsed.truncatingRemainder(dividingBy: 3600)) / 60)
        let s = Int(state.elapsed.truncatingRemainder(dividingBy: 60))
        if d > 0 { return "\(d)" }; if h > 0 { return "\(h)" }; if m > 0 { return "\(m)" }
        return "\(s)"
    }
    private var timerUnit: String {
        let d = Int(state.elapsed / 86400)
        let h = Int((state.elapsed.truncatingRemainder(dividingBy: 86400)) / 3600)
        let m = Int((state.elapsed.truncatingRemainder(dividingBy: 3600)) / 60)
        if d > 0 { return d == 1 ? "day" : "days" }
        if h > 0 { return h == 1 ? "hour" : "hours" }
        if m > 0 { return m == 1 ? "min" : "mins" }
        return "sec"
    }
    private var timerSub: String {
        let d = Int(state.elapsed / 86400)
        let h = Int((state.elapsed.truncatingRemainder(dividingBy: 86400)) / 3600)
        let m = Int((state.elapsed.truncatingRemainder(dividingBy: 3600)) / 60)
        let s = Int(state.elapsed.truncatingRemainder(dividingBy: 60))
        if d > 0 { return "\(h)h \(m)m" }; if h > 0 { return "\(m)m \(s)s" }
        return ""
    }
    private func intensityColor(_ i: Double) -> Color {
        i > 0.7 ? .rDanger : i > 0.4 ? .rAmber : .rAccent
    }
}

// MARK: - Check-In Entry Card

struct CheckInEntryCard: View {
    let currentMood: Int?
    let moods: [(emoji: String, label: String)]
    let futureMessage: FutureMessage?
    let onTap: () -> Void

    @State private var pulse = false

    private var moodInfo: (emoji: String, label: String)? {
        guard let m = currentMood, m < moods.count else { return nil }
        return moods[m]
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(moodInfo != nil ? Color.rAccent.opacity(0.12) : Color.rPurple.opacity(0.12))
                            .frame(width: 46, height: 46)
                        if let info = moodInfo {
                            Text(info.emoji).font(.system(size: 24))
                        } else {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.rPurple)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        if let info = moodInfo {
                            Text("Feeling \(info.label) today")
                                .font(.sansRR(14, weight: .bold)).foregroundColor(.rText)
                            Text("Tap to run your guided check-in")
                                .font(.sansRR(11)).foregroundColor(.rText3)
                        } else {
                            Text("How are you right now?")
                                .font(.sansRR(14, weight: .bold)).foregroundColor(.rText)
                            Text("Start your guided check-in — takes 2 minutes")
                                .font(.sansRR(11)).foregroundColor(.rText3)
                        }
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(Color.rPurple.opacity(0.12))
                            .frame(width: 34, height: 34)
                            .scaleEffect(pulse ? 1.15 : 1.0)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: pulse)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.rPurple)
                    }
                }

                // Future message teaser (shows only if user has written one)
                if let msg = futureMessage, currentMood == nil || (currentMood ?? 2) <= 1 {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 10)).foregroundColor(.rPurple.opacity(0.6))
                        Text("You have a message from Day \(msg.dayNum) waiting inside →")
                            .font(.sansRR(11)).foregroundColor(.rPurple.opacity(0.75))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.rPurple.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(moodInfo != nil ? Color.rAccent.opacity(0.2) : Color.rPurple.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .onAppear { pulse = true }
    }
}

// MARK: - Daily Pledge Card

struct DailyPledgeCard: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    @Binding var pledgeAnimation: Bool

    var body: some View {
        VStack(spacing: 12) {
            if gamification.pledgedToday {
                // Already pledged
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.rAccent.opacity(0.15)).frame(width: 44, height: 44)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 22)).foregroundColor(.rAccent)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Daily pledge complete ✓")
                            .font(.sansRR(14, weight: .bold)).foregroundColor(.rAccent)
                        Text("Streak: \(gamification.currentStreak) days · \(gamification.totalPledges) total pledges · +25 XP")
                            .font(.sansRR(11)).foregroundColor(.rText3)
                    }
                    Spacer()
                    Text("🔥").font(.system(size: 28))
                }
                .padding(14)
                .background(Color.rAccent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rAccent.opacity(0.2), lineWidth: 1))

            } else {
                // Pledge CTA with loss aversion framing
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 20)).foregroundColor(.rPurple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Make your daily pledge")
                                .font(.sansRR(14, weight: .bold)).foregroundColor(.rText)
                            // Loss aversion framing
                            Text(lossAversionMessage)
                                .font(.sansRR(11)).foregroundColor(.rText3).lineSpacing(2)
                        }
                    }

                    Button {
                        gamification.makeDailyPledge(elapsed: state.elapsed)
                        gamification.checkAchievements(elapsed: state.elapsed)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { pledgeAnimation.toggle() }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised.fill").font(.system(size: 16))
                            Text("I commit to staying smoke-free today")
                                .font(.sansRR(14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 13)
                        .background(Color.rPurple)
                        .clipShape(Capsule())
                        .shadow(color: Color.rPurple.opacity(0.3), radius: 10, y: 4)
                    }
                }
                .padding(14)
                .background(Color.rPurple.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rPurple.opacity(0.15), lineWidth: 1))
            }
        }
    }

    private var lossAversionMessage: String {
        let streak = gamification.currentStreak
        let savings = String(format: "$%.2f", state.moneySaved)
        if streak >= 7 {
            return "You're about to protect a \(streak)-day streak and \(savings) in savings. One pledge keeps it all."
        } else if streak >= 1 {
            return "Your \(streak)-day streak is at risk. 10 seconds to protect everything you've built."
        } else {
            return "Research shows the first pledge is the foundation of every long-term quit. Don't skip it."
        }
    }
}
