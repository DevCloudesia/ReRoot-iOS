import SwiftUI

// ════════════════════════════════════════════════════════
// MARK: - Guided Check-In Flow
// Full-screen emotion-driven adaptive recovery experience.
// Mood → Acknowledgement → Science → Action → Quote → Done
// ════════════════════════════════════════════════════════

struct GuidedCheckInFlow: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    @Binding var isPresented: Bool
    var preSelectedMood: Int? = nil
    var onFlowComplete: (() -> Void)? = nil

    @State private var selectedMood: Int?
    @State private var currentStage: Stage = .honestLapse
    @State private var sequence: [Stage] = [.honestLapse, .cravingCheck, .emotionSelect]
    @State private var futureMessageText = ""
    @State private var xpAwarded = false
    @State private var creativeOutput = ""
    @State private var reportedLapse = false
    @State private var almostSlipped = false
    @State private var cravingIntensity: Int = 0
    @State private var lapseCount: Int = 0
    @State private var lapseTriggers: [String] = []
    @State private var almostStoppers: [String] = []
    @State private var almostTriggers: [String] = []

    enum Stage: String, Equatable {
        case honestLapse, cravingCheck, emotionSelect
        case lapseDebrief
        case acknowledgement, science
        case fiveMinuteBoost, action, futureSelf
        case creativeActivity, claudeChat
        case microCommit, pledge, endQuote, complete
    }

    private var stageIdx: Int { sequence.firstIndex(of: currentStage) ?? 0 }
    private var progress: CGFloat {
        let total = max(1, sequence.count - 1)
        return CGFloat(stageIdx) / CGFloat(total)
    }

    var body: some View {
        ZStack(alignment: .top) {
            moodBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                if currentStage != .honestLapse { topChrome }
                currentStageView
                    .id(currentStage)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .onAppear {
            if let mood = preSelectedMood {
                selectedMood = mood
                sequence = [.honestLapse, .cravingCheck]
                buildSequence(for: mood)
                currentStage = .honestLapse
            }
        }
    }

    // MARK: - Top Chrome

    var topChrome: some View {
        VStack(spacing: 10) {
            HStack {
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white.opacity(0.28))
                }
                Spacer()
                Text(stageTitle)
                    .font(.sansRR(10, weight: .bold))
                    .foregroundColor(.white.opacity(0.42))
                    .tracking(1.5)
                Spacer()
                Text("DAY \(state.dayNum)")
                    .font(.sansRR(10, weight: .bold))
                    .foregroundColor(.white.opacity(0.28))
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 2)
                    Capsule().fill(Color.white.opacity(0.5))
                        .frame(width: g.size.width * progress, height: 2)
                        .animation(.easeOut(duration: 0.45), value: progress)
                }
            }
            .frame(height: 2)
            .padding(.horizontal, 22)
            .padding(.bottom, 6)
        }
    }

    var stageTitle: String {
        switch currentStage {
        case .honestLapse:      return "CHECKING IN"
        case .cravingCheck:     return "HOW YOU'RE DOING"
        case .emotionSelect:    return "YOUR FEELINGS"
        case .lapseDebrief:     return "LEARNING TOGETHER"
        case .acknowledgement:  return "WE SEE YOU"
        case .science:          return "GOOD TO KNOW"
        case .fiveMinuteBoost:  return "A MOMENT FOR YOU"
        case .action:           return "SOMETHING HELPFUL"
        case .futureSelf:       return "A NOTE TO YOURSELF"
        case .creativeActivity: return "CREATIVE MOMENT"
        case .claudeChat:       return "TALK IT OUT"
        case .microCommit:      return "YOUR NEXT STEP"
        case .pledge:           return "YOUR PROMISE"
        case .endQuote:         return "A THOUGHT FOR YOU"
        case .complete:         return "WELL DONE"
        }
    }

    // MARK: - Stage Router

    @ViewBuilder
    var currentStageView: some View {
        switch currentStage {
        case .honestLapse:
            HonestLapseStage(
                userName: state.userName,
                dayNum: state.dayNum,
                honestStreak: state.honestStreak,
                onAnswer: { didSmoke, almost, count, triggers, stoppers, almTriggers in
                    reportedLapse = didSmoke
                    almostSlipped = almost
                    lapseCount = count
                    lapseTriggers = triggers
                    almostStoppers = stoppers
                    almostTriggers = almTriggers
                    state.todayLapseReported = didSmoke
                    if preSelectedMood != nil {
                        if didSmoke {
                            sequence = [.honestLapse, .cravingCheck, .lapseDebrief]
                        } else {
                            sequence = [.honestLapse, .cravingCheck]
                        }
                    } else {
                        if didSmoke {
                            sequence = [.honestLapse, .cravingCheck, .lapseDebrief, .emotionSelect]
                        } else {
                            sequence = [.honestLapse, .cravingCheck, .emotionSelect]
                        }
                    }
                    advance()
                }
            )

        case .cravingCheck:
            CravingCheckStage(
                reportedLapse: reportedLapse,
                onContinue: { intensity in
                    cravingIntensity = intensity
                    state.todayCravingIntensity = intensity
                    if !reportedLapse, preSelectedMood != nil {
                        buildSequence(for: selectedMood ?? 2)
                    }
                    advance()
                }
            )

        case .lapseDebrief:
            LapseDebriefStage(
                triggers: state.userTriggers,
                onComplete: { trigger, plan in
                    state.logLapse(count: 1, trigger: trigger, plan: plan)
                    if preSelectedMood != nil {
                        buildSequence(for: selectedMood ?? 2)
                    }
                    advance()
                }
            )

        case .emotionSelect:
            EmotionSelectStage(
                reportedLapse: reportedLapse,
                cravingIntensity: cravingIntensity
            ) { mood in
                state.logMood(mood)
                selectedMood = mood
                buildSequence(for: mood)
                advance()
            }

        case .acknowledgement:
            AcknowledgementStage(
                mood: selectedMood ?? 2,
                dayNum: state.dayNum,
                elapsed: state.elapsed,
                moneySaved: state.moneySaved,
                cigsAvoided: state.cigsAvoided,
                futureMessage: state.randomFutureMessage,
                userName: state.userName,
                motivation: state.quitMotivation,
                cravingIntensity: cravingIntensity,
                reportedLapse: reportedLapse,
                daysSinceLastLapse: state.daysSinceLastLapse,
                onContinue: advance
            )

        case .science:
            ScienceStage(
                elapsed: state.elapsed,
                mood: selectedMood ?? 2,
                onContinue: advance
            )

        case .fiveMinuteBoost:
            FiveMinuteBoostStage(
                elapsed: state.elapsed,
                onContinue: advance
            )

        case .action:
            ActionStage(
                elapsed: state.elapsed,
                mood: selectedMood ?? 0,
                cravingIntensity: cravingIntensity,
                reportedLapse: reportedLapse,
                onContinue: advance
            )

        case .creativeActivity:
            CreativeActivityStage(
                mood: selectedMood ?? 2,
                onComplete: { output in
                    creativeOutput = output
                    advance()
                }
            )

        case .claudeChat:
            ClaudeChatView(
                mood: selectedMood ?? 2,
                dayNum: state.dayNum,
                elapsed: state.elapsed,
                creativeOutput: creativeOutput,
                reportedLapse: reportedLapse,
                almostSlipped: almostSlipped,
                lapseCount: lapseCount,
                lapseTriggers: lapseTriggers,
                almostStoppers: almostStoppers,
                almostTriggers: almostTriggers,
                cravingIntensity: cravingIntensity,
                userName: state.userName,
                quitMotivation: state.quitMotivation,
                onDone: { reassessedMood in
                    if let m = reassessedMood {
                        selectedMood = m
                        state.lastCheckInMood = m
                    }
                    advance()
                }
            )

        case .futureSelf:
            FutureSelfStage(
                message: $futureMessageText,
                dayNum: state.dayNum,
                moodEmoji: ["😣","😟","😐","🙂","😊"][min(max(selectedMood ?? 3, 0), 4)],
                onContinue: {
                    let t = futureMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !t.isEmpty {
                        state.saveFutureMessage(text: t)
                    }
                    advance()
                }
            )

        case .microCommit:
            MicroCommitStage(
                yesterdayCommitment: state.yesterdayCommitment,
                onCommit: { skillId in
                    if !skillId.isEmpty {
                        state.setMicroCommitment(skillId: skillId)
                    }
                    advance()
                }
            )

        case .pledge:
            PledgeStage(
                pledgedToday: gamification.pledgedToday,
                streak: gamification.currentStreak,
                totalPledges: gamification.totalPledges,
                onPledge: {
                    gamification.makeDailyPledge(elapsed: state.elapsed)
                    advance()
                },
                onContinue: advance
            )

        case .endQuote:
            EndQuoteStage(
                mood: selectedMood ?? 2,
                elapsed: state.elapsed,
                dayNum: state.dayNum,
                cigsAvoided: state.cigsAvoided,
                moneySaved: state.moneySaved,
                onContinue: advance
            )

        case .complete:
            CompleteStage(
                mood: selectedMood ?? 2,
                dayNum: state.dayNum,
                elapsed: state.elapsed,
                onDone: {
                    if !xpAwarded {
                        xpAwarded = true
                        gamification.checkAchievements(elapsed: state.elapsed)
                    }
                    let mood = selectedMood ?? 2
                    onFlowComplete?()
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        state.completeCheckIn(mood: mood)
                    }
                }
            )
        }
    }

    // MARK: - Navigation

    func buildSequence(for mood: Int) {
        var seq: [Stage] = [.honestLapse, .cravingCheck]
        if reportedLapse { seq.append(.lapseDebrief) }
        if preSelectedMood == nil { seq.append(.emotionSelect) }
        seq.append(.acknowledgement)

        switch mood {
        case 0:
            seq += [.science, .fiveMinuteBoost, .action, .creativeActivity, .claudeChat, .microCommit, .pledge, .endQuote, .complete]
        case 1:
            seq += [.science, .action, .creativeActivity, .claudeChat, .microCommit, .pledge, .endQuote, .complete]
        case 2:
            seq += [.science, .action, .creativeActivity, .claudeChat, .microCommit, .pledge, .endQuote, .complete]
        case 3:
            seq += [.futureSelf, .action, .creativeActivity, .claudeChat, .microCommit, .pledge, .endQuote, .complete]
        default:
            seq += [.futureSelf, .action, .creativeActivity, .claudeChat, .microCommit, .pledge, .endQuote, .complete]
        }
        sequence = seq
    }

    func advance() {
        withAnimation(.easeInOut(duration: 0.38)) {
            let next = stageIdx + 1
            if next < sequence.count {
                currentStage = sequence[next]
            } else {
                isPresented = false
            }
        }
    }

    // MARK: - Dynamic Background

    var moodBackground: LinearGradient {
        switch selectedMood ?? -1 {
        case 0: // Struggling — deep red/black
            return LinearGradient(
                colors: [Color(red: 0.24, green: 0.06, blue: 0.06), Color(red: 0.12, green: 0.08, blue: 0.08)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case 1: // Tough — warm amber/brown
            return LinearGradient(
                colors: [Color(red: 0.22, green: 0.14, blue: 0.06), Color(red: 0.14, green: 0.10, blue: 0.07)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case 2: // Steady — steel blue
            return LinearGradient(
                colors: [Color(red: 0.10, green: 0.12, blue: 0.22), Color(red: 0.09, green: 0.11, blue: 0.18)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case 3: // Doing Well — warm green
            return LinearGradient(
                colors: [Color(red: 0.06, green: 0.20, blue: 0.12), Color(red: 0.08, green: 0.16, blue: 0.10)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case 4: // Thriving — deep teal/emerald
            return LinearGradient(
                colors: [Color(red: 0.04, green: 0.18, blue: 0.20), Color(red: 0.06, green: 0.14, blue: 0.16)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color(red: 0.118, green: 0.110, blue: 0.098), Color(red: 0.20, green: 0.18, blue: 0.15)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage 1: Emotion Select
// ════════════════════════════════════════════════════════

struct EmotionSelectStage: View {
    var reportedLapse: Bool = false
    var cravingIntensity: Int = 0
    let onSelect: (Int) -> Void

    @State private var selectedIdx: Int? = nil
    @State private var appear = false

    private let moods: [(emoji: String, label: String, desc: String)] = [
        ("😣", "Struggling",     "It's been really hard today"),
        ("😟", "Hanging in",     "Tough, but I'm still here"),
        ("😐", "Okay",           "Not great, not terrible"),
        ("🙂", "Good",           "Feeling more like myself"),
        ("😊", "Great",          "Genuinely feeling free today"),
    ]

    private var contextText: String {
        if reportedLapse && cravingIntensity >= 7 {
            return "You've been through a lot today. Take a breath. How are you feeling inside?"
        } else if reportedLapse {
            return "Thank you for being honest. Now, just check in with yourself. How's your heart?"
        } else if cravingIntensity >= 7 {
            return "Cravings can be overwhelming. That's okay. Beyond the craving, how are you doing?"
        } else if cravingIntensity >= 4 {
            return "You're dealing with some cravings. That's part of this. How are you feeling overall?"
        } else {
            return "Take a moment. Beyond the day-to-day, how are you really doing?"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 50)

            VStack(spacing: 6) {
                Text("CHECK IN WITH YOURSELF")
                    .font(.sansRR(11, weight: .bold))
                    .foregroundColor(.white.opacity(0.32))
                    .tracking(2.5)
                Text("How are you\nreally feeling?")
                    .font(.serif(30, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(4)
                Text(contextText)
                    .font(.sansRR(13))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 22)
            .animation(.easeOut(duration: 0.5), value: appear)
            .padding(.horizontal, 28)

            Spacer(minLength: 36)

            VStack(spacing: 10) {
                ForEach(moods.indices, id: \.self) { i in
                    moodButton(i)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 28)
                        .animation(.easeOut(duration: 0.45).delay(Double(i) * 0.07 + 0.15), value: appear)
                }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 28)

            Group {
                if let idx = selectedIdx {
                    Button { onSelect(idx) } label: {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.sansRR(17, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 19)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .white.opacity(0.18), radius: 16, y: 4)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 52)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Color.clear.frame(height: 72).padding(.bottom, 52)
                }
            }
        }
        .onAppear { withAnimation { appear = true } }
    }

    func moodButton(_ i: Int) -> some View {
        let sel = selectedIdx == i
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) { selectedIdx = i }
        } label: {
            HStack(spacing: 16) {
                Text(moods[i].emoji)
                    .font(.system(size: 34))
                    .scaleEffect(sel ? 1.12 : 1.0)
                    .animation(.spring(response: 0.28), value: sel)

                VStack(alignment: .leading, spacing: 3) {
                    Text(moods[i].label)
                        .font(.sansRR(16, weight: .bold))
                        .foregroundColor(sel ? .white : .white.opacity(0.72))
                    Text(moods[i].desc)
                        .font(.sansRR(12))
                        .foregroundColor(sel ? .white.opacity(0.7) : .white.opacity(0.32))
                }

                Spacer()

                if sel {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(sel ? Color.white.opacity(0.16) : Color.white.opacity(0.055))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(sel ? Color.white.opacity(0.38) : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage 2: Acknowledgement
// ════════════════════════════════════════════════════════

struct AcknowledgementStage: View {
    let mood: Int
    let dayNum: Int
    let elapsed: TimeInterval
    let moneySaved: Double
    let cigsAvoided: Int
    let futureMessage: FutureMessage?
    var userName: String = ""
    var motivation: String = ""
    var cravingIntensity: Int = 0
    var reportedLapse: Bool = false
    var daysSinceLastLapse: Int = 0
    let onContinue: () -> Void

    @State private var appear = false

    private var isStruggling: Bool { mood <= 1 }
    private var isThriving:   Bool { mood >= 3 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Spacer(minLength: 24)

                Text(["😣","😟","😐","🙂","😊"][min(max(mood,0),4)])
                    .font(.system(size: 72))
                    .scaleEffect(appear ? 1 : 0.55)
                    .opacity(appear ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.62), value: appear)

                VStack(spacing: 10) {
                    Text(headline)
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text(subheadline)
                        .font(.sansRR(14)).foregroundColor(.white.opacity(0.58))
                        .multilineTextAlignment(.center).lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0).offset(y: appear ? 0 : 16)
                .animation(.easeOut(duration: 0.5).delay(0.14), value: appear)

                if reportedLapse {
                    lapseContextCard
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.22), value: appear)
                }

                if cravingIntensity >= 5 {
                    cravingContextCard
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.24), value: appear)
                }

                statsStrip
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.26), value: appear)

                if isStruggling, let msg = futureMessage {
                    futureMessageCard(msg)
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.36), value: appear)
                }

                if !motivation.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill").font(.system(size: 12)).foregroundColor(.rAmber)
                        Text("You're quitting for: \(motivation.lowercased())")
                            .font(.sansRR(12, weight: .semibold)).foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.white.opacity(0.06)).clipShape(Capsule())
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.38), value: appear)
                }

                Text(bodyText)
                    .font(.sansRR(14)).foregroundColor(.white.opacity(0.62))
                    .multilineTextAlignment(.center).lineSpacing(4).padding(.horizontal, 28)
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.44), value: appear)

                Spacer(minLength: 20)

                Button(action: onContinue) {
                    Text(ctaLabel)
                        .font(.sansRR(16, weight: .bold))
                        .foregroundColor(isStruggling ? .white : .black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(isStruggling ? Color.white.opacity(0.18) : Color.white)
                        .clipShape(Capsule())
                        .overlay(isStruggling ? Capsule().stroke(Color.white.opacity(0.32), lineWidth: 1.5) : nil)
                }
                .padding(.horizontal, 22).padding(.bottom, 52)
                .opacity(appear ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.54), value: appear)
            }
        }
        .onAppear { withAnimation { appear = true } }
    }

    var lapseContextCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill").font(.system(size: 14)).foregroundColor(.rAmber)
                Text("Be gentle with yourself").font(.sansRR(13, weight: .bold)).foregroundColor(.white)
            }
            Text("One cigarette doesn't undo \(daysSinceLastLapse > 0 ? "\(daysSinceLastLapse) days of" : "all your") progress. Your body is still healing. Most people who successfully quit had moments like this along the way. What matters is you showed up today.")
                .font(.sansRR(12)).foregroundColor(.white.opacity(0.55)).lineSpacing(3)
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .background(Color.rAmber.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 22)
    }

    var cravingContextCard: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "wind").font(.system(size: 14)).foregroundColor(.rDanger)
                Text("Craving level: \(cravingIntensity)/10").font(.sansRR(13, weight: .bold)).foregroundColor(.white)
            }
            Text(cravingIntensity >= 8
                 ? "This is intense, and it's okay to feel it. Cravings usually peak and fade within a few minutes. You don't have to fight it. Just ride it out. We have some things that might help."
                 : "Cravings come in waves, and they always pass. The activities ahead are here to help you through this moment. Take it one breath at a time.")
                .font(.sansRR(12)).foregroundColor(.white.opacity(0.55)).lineSpacing(3)
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .background(Color.rDanger.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 22)
    }

    var headline: String {
        let name = userName.isEmpty ? "" : ", \(userName)"
        if reportedLapse {
            return "You came back\(name).\nThat's what matters."
        }
        switch mood {
        case 0: return "I see you\(name).\nThis is hard."
        case 1: return "You're still here\(name).\nThat takes strength."
        case 2: return "Steady and present\(name)."
        case 3: return "Look at you\(name).\nYou're doing this."
        default: return "You're really doing it\(name)."
        }
    }

    var subheadline: String {
        if reportedLapse {
            return "Day \(dayNum). A slip doesn't undo your progress. The fact that you're being honest about it shows real strength."
        }
        switch mood {
        case 0:
            return "Day \(dayNum). What you're going through right now is temporary, even though it doesn't feel like it. You don't have to do this alone."
        case 1:
            return "Day \(dayNum). Tough days are part of getting free. The discomfort is your body adjusting to life without nicotine."
        case 2:
            return "Day \(dayNum). Quiet days like this are where real change happens. You're building something, even when it feels ordinary."
        case 3:
            return "Day \(dayNum). Notice how this feels. This calm, this clarity. This is your natural state coming back."
        default:
            return "Day \(dayNum). This lightness you're feeling? That's who you really are without nicotine."
        }
    }

    var bodyText: String {
        if reportedLapse {
            return "A slip is not the end. It's a moment, not a direction. Be gentle with yourself. The progress you've made over \(dayNum) days is still real. Your body is still healing. And you're here, which means you haven't given up."
        }
        switch mood {
        case 0: return "When it feels this hard, remember: cravings peak and then they pass. Usually within just a few minutes. You don't have to feel ready or strong. You just have to get through this moment. And we're right here with you."
        case 1: return "The restlessness, the irritability, the foggy thinking. These are signs your body is healing, not signs you're failing. Every uncomfortable moment is your brain learning to work without nicotine. It gets easier."
        case 2: return "Days like today might not feel like progress, but they are. Every ordinary smoke-free day rewires your brain a little more. You're quietly becoming someone who doesn't need cigarettes."
        case 3: return "Can you feel it? The deeper breaths, the clearer thinking. That's your body thanking you. After \(dayNum) days, real physical healing is happening. You deserve to feel this good."
        default: return "This is what freedom feels like. Not just from cravings, but from the cycle of needing something just to feel normal. You've earned this. Take a moment to really feel proud of yourself."
        }
    }

    var ctaLabel: String {
        if reportedLapse { return "I'm ready to keep going" }
        switch mood {
        case 0:    return "Help me through this"
        case 1:    return "I could use some support"
        case 2:    return "Let's keep going"
        case 3:    return "Let's build on this"
        default:   return "Let's celebrate this"
        }
    }

    var statsStrip: some View {
        HStack(spacing: 0) {
            ackStat(formatElapsed(elapsed), "SMOKE-FREE")
            Rectangle().fill(Color.white.opacity(0.12)).frame(width: 1, height: 28)
            ackStat("$\(Int(moneySaved))", "SAVED")
            Rectangle().fill(Color.white.opacity(0.12)).frame(width: 1, height: 28)
            ackStat("\(cigsAvoided)", "NOT SMOKED")
        }
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 22)
    }

    func ackStat(_ v: String, _ l: String) -> some View {
        VStack(spacing: 4) {
            Text(v).font(.serif(18, weight: .bold)).foregroundColor(.white).monospacedDigit()
            Text(l).font(.sansRR(8, weight: .bold)).foregroundColor(.white.opacity(0.38)).tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    func futureMessageCard(_ msg: FutureMessage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Image(systemName: "envelope.fill").font(.system(size: 11)).foregroundColor(.white.opacity(0.45))
                Text("MESSAGE FROM YOU — DAY \(msg.dayNum)")
                    .font(.sansRR(9, weight: .bold)).foregroundColor(.white.opacity(0.45)).tracking(0.8)
            }
            Text("\u{201C}\(msg.text)\u{201D}")
                .font(.sansRR(14)).foregroundColor(.white.opacity(0.88)).italic().lineSpacing(4)
        }
        .padding(16)
        .background(Color.white.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.18), lineWidth: 1))
        .padding(.horizontal, 22)
    }

    func formatElapsed(_ s: TimeInterval) -> String {
        let d = Int(s / 86400)
        let h = Int((s.truncatingRemainder(dividingBy: 86400)) / 3600)
        if d > 0 { return "\(d)d \(h)h" }
        let m = Int((s.truncatingRemainder(dividingBy: 3600)) / 60)
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage 3: Science
// ════════════════════════════════════════════════════════

struct ScienceStage: View {
    let elapsed: TimeInterval
    let mood: Int
    let onContinue: () -> Void

    @State private var appear = false

    private var content: (icon: String, phase: String, headline: String, body: String, source: String) {
        let h = elapsed / 3600
        let d = elapsed / 86400
        switch true {
        case h < 1:
            return ("brain", "FIRST HOUR",
                    "Your Brain Is Sounding an Alarm",
                    "Nicotine binds to receptors that trigger dopamine release. Without it, those receptors are now firing distress signals — this feels urgent because your brain has been trained to treat it as an emergency. It isn't. It's just chemistry asking for something you've decided to stop giving it.",
                    "NIDA · National Institute on Drug Abuse")
        case h < 8:
            return ("lungs.fill", "HOUR \(Int(h))",
                    "Carbon Monoxide Is Leaving Your Blood",
                    "CO levels in your blood are dropping by half right now. Oxygen is reaching your tissues more efficiently than it has in years. Your heart, lungs, and brain are receiving cleaner fuel with every single breath you take.",
                    "American Lung Association")
        case h < 24:
            return ("waveform.path.ecg", "HOUR \(Int(h))",
                    "Dopamine Drought — Not Your Baseline",
                    "Nicotine hijacked your dopamine system. Your baseline is temporarily below normal — this is why things feel gray or irritable. This is neurochemical, not character. Research confirms it fully reverses within 2–4 weeks. You are not broken. You are recalibrating.",
                    "NIDA · Harvard Health")
        case d < 3:
            return ("exclamationmark.triangle", "DAY \(Int(d) + 1)",
                    "This Is Peak Withdrawal",
                    "Days 2–3 are clinically the hardest phase. Your nicotinic receptors are downregulating — literally reducing in number to match a nicotine-free reality. Each hour you hold, fewer receptors demand attention. You are not failing. You are detoxing.",
                    "CDC · NIH")
        case d < 7:
            return ("sparkles", "DAY \(Int(d) + 1)",
                    "Nerve Endings Are Regrowing",
                    "At 48 hours, damaged nerve endings begin regenerating — which is why your senses are sharpening. At 72 hours, bronchial tubes relax and breathing becomes physically easier. You can feel what is happening in your body right now.",
                    "Medical News Today · ALA")
        case d < 14:
            return ("heart.fill", "DAY \(Int(d) + 1)",
                    "Circulation Has Already Improved",
                    "Lung function is measurably improving. Walking and activity feel different — not because of fitness, but because your cardiovascular system is working better. That is a direct, documented result of not smoking.",
                    "American Lung Association")
        default:
            return ("chart.line.uptrend.xyaxis.circle.fill", "DAY \(Int(d) + 1)",
                    "Your Brain Chemistry Has Shifted",
                    "Former smokers report significantly lower anxiety and depression than active smokers after recovery — the opposite of what most expect. The cigarettes didn't calm you. They relieved withdrawal while creating more of it. That loop is now broken.",
                    "Harvard Health · NCI")
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer(minLength: 20)

                Text(content.phase)
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.38)).tracking(1.8)
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.4), value: appear)

                // Icon circle
                ZStack {
                    Circle().fill(Color.white.opacity(0.07)).frame(width: 92, height: 92)
                    Circle().stroke(Color.white.opacity(0.12), lineWidth: 1).frame(width: 92, height: 92)
                    Image(systemName: content.icon)
                        .font(.system(size: 38, weight: .medium)).foregroundColor(.white.opacity(0.88))
                }
                .scaleEffect(appear ? 1 : 0.68).opacity(appear ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.1), value: appear)

                Text(content.headline)
                    .font(.serif(26, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).padding(.horizontal, 28)
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.2), value: appear)

                Text(content.body)
                    .font(.sansRR(15)).foregroundColor(.white.opacity(0.68))
                    .multilineTextAlignment(.center).lineSpacing(5).padding(.horizontal, 26)
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.3), value: appear)

                Text("SOURCE: \(content.source)")
                    .font(.sansRR(10)).foregroundColor(.white.opacity(0.28)).italic()
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.38), value: appear)

                // Withdrawal timeline
                withdrawalTimeline
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.44), value: appear)

                Spacer(minLength: 20)

                Button(action: onContinue) {
                    Text(mood <= 1 ? "I understand — give me a boost →" : "Got it →")
                        .font(.sansRR(16, weight: .bold))
                        .foregroundColor(mood <= 1 ? .white : .black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(mood <= 1 ? Color.white.opacity(0.18) : Color.white)
                        .clipShape(Capsule())
                        .overlay(mood <= 1 ? Capsule().stroke(Color.white.opacity(0.28), lineWidth: 1.5) : nil)
                }
                .padding(.horizontal, 22).padding(.bottom, 52)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.54), value: appear)
            }
        }
        .onAppear { withAnimation { appear = true } }
    }

    var withdrawalTimeline: some View {
        let pct = min(1.0, elapsed / (28 * 86400))
        return VStack(spacing: 8) {
            HStack {
                Text("WITHDRAWAL TIMELINE — YOUR POSITION")
                    .font(.sansRR(8, weight: .bold)).foregroundColor(.white.opacity(0.3)).tracking(0.8)
                Spacer()
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 6)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.75, green: 0.28, blue: 0.28),
                                     Color(red: 0.35, green: 0.62, blue: 0.38)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: g.size.width * CGFloat(pct), height: 6)
                    Circle().fill(Color.white).frame(width: 14, height: 14)
                        .shadow(color: .white.opacity(0.55), radius: 4)
                        .offset(x: max(0, g.size.width * CGFloat(pct) - 7))
                }
            }
            .frame(height: 14)
            HStack {
                Text("Start").font(.sansRR(9)).foregroundColor(.white.opacity(0.28))
                Spacer()
                Text("Week 1").font(.sansRR(9)).foregroundColor(.white.opacity(0.28))
                Spacer()
                Text("4 weeks").font(.sansRR(9)).foregroundColor(.white.opacity(0.28))
            }
        }
        .padding(.horizontal, 22)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage 4: Five-Minute Boost
// ════════════════════════════════════════════════════════

struct FiveMinuteBoostStage: View {
    let elapsed: TimeInterval
    let onContinue: () -> Void

    @State private var appear = false
    @State private var chosen: BoostOption?

    enum BoostOption: Identifiable {
        case breathing, urgeSurf, serial7s
        var id: String {
            switch self {
            case .breathing: return "b"
            case .urgeSurf: return "u"
            case .serial7s: return "s"
            }
        }
    }

    var body: some View {
        ZStack {
            if let opt = chosen {
                boostView(opt)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                pickerView
            }
        }
    }

    var pickerView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            VStack(spacing: 8) {
                Text("5-MINUTE CRAVING BUSTER")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.38)).tracking(1.8)
                Text("Pick your weapon.")
                    .font(.serif(34, weight: .bold)).foregroundColor(.white)
                Text("Each of these is scientifically proven to\nbreak a craving in under 5 minutes.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45), value: appear)

            Spacer(minLength: 32)

            VStack(spacing: 14) {
                boostCard(
                    icon: "lungs.fill",
                    title: "4-7-8 Breathing",
                    desc: "Guided animated pacer. Extended exhale activates your vagus nerve.",
                    color: Color(red: 0.35, green: 0.65, blue: 0.85),
                    delay: 0.12
                ) { withAnimation(.spring(response: 0.3)) { chosen = .breathing } }

                boostCard(
                    icon: "water.waves",
                    title: "Urge Surfing",
                    desc: "Ride a 3-minute animated wave. Watch the craving peak and dissolve.",
                    color: Color(red: 0.55, green: 0.45, blue: 0.75),
                    delay: 0.20
                ) { withAnimation(.spring(response: 0.3)) { chosen = .urgeSurf } }

                boostCard(
                    icon: "number",
                    title: "Serial 7s Challenge",
                    desc: "2-minute math game. Starve the craving of cognitive bandwidth.",
                    color: Color(red: 0.85, green: 0.55, blue: 0.25),
                    delay: 0.28
                ) { withAnimation(.spring(response: 0.3)) { chosen = .serial7s } }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 24)

            Button(action: onContinue) {
                Text("I'm past it, skip")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.32))
            }
            .padding(.bottom, 52)
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.4), value: appear)
        }
        .onAppear { withAnimation { appear = true } }
    }

    func boostCard(icon: String, title: String, desc: String, color: Color, delay: Double, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle().fill(color.opacity(0.2)).frame(width: 52, height: 52)
                    Image(systemName: icon).font(.system(size: 22)).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title).font(.sansRR(16, weight: .bold)).foregroundColor(.white)
                        Text("IN-APP").font(.sansRR(7, weight: .heavy)).foregroundColor(.black)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(color).clipShape(Capsule())
                    }
                    Text(desc).font(.sansRR(12)).foregroundColor(.white.opacity(0.45)).lineSpacing(2)
                }
                Spacer()
                Image(systemName: "play.circle.fill").font(.system(size: 28)).foregroundColor(color.opacity(0.6))
            }
            .padding(16)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(.easeOut(duration: 0.42).delay(delay), value: appear)
    }

    @ViewBuilder
    func boostView(_ opt: BoostOption) -> some View {
        switch opt {
        case .breathing:
            BreathingPacerView(mode: .fourSevenEight, onComplete: onContinue)
        case .urgeSurf:
            UrgeSurfingView(onComplete: onContinue)
        case .serial7s:
            Serial7sGameView(onComplete: onContinue)
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage 5: Action Steps
// ════════════════════════════════════════════════════════

struct ActionStage: View {
    @EnvironmentObject var state: AppState
    let elapsed: TimeInterval
    let mood: Int
    var cravingIntensity: Int = 0
    var reportedLapse: Bool = false
    let onContinue: () -> Void

    @State private var completed: Set<Int> = []
    @State private var appear = false
    @State private var activities: [InteractiveActivity] = []
    @State private var activeActivity: InteractiveActivity?

    enum InteractiveActivity: Identifiable, Equatable {
        case breathing(BreathingPacerView.Mode)
        case urgeSurfing
        case serial7s
        case sensoryGrounding
        case bodyScan
        case iceDive
        case thoughtDefusion
        case squareTrace
        case emotionWheel
        case butterflyTap
        case lovingKindness
        case visualizationJourney
        case fingerTap
        case gratitudeGarden
        case affirmationCards
        case colorBreathing
        case mindfulListening
        case cognitiveReframe
        case wordScramble
        case safePlaceBuilder
        case joyMapping
        case patternMemory
        case celebrationBreath

        var id: String {
            switch self {
            case .breathing(let m): return "breathing-\(m.rawValue)"
            case .urgeSurfing: return "urgeSurf"
            case .serial7s: return "serial7s"
            case .sensoryGrounding: return "sensory"
            case .bodyScan: return "bodyScan"
            case .iceDive: return "iceDive"
            case .thoughtDefusion: return "thoughtDefusion"
            case .squareTrace: return "squareTrace"
            case .emotionWheel: return "emotionWheel"
            case .butterflyTap: return "butterflyTap"
            case .lovingKindness: return "lovingKindness"
            case .visualizationJourney: return "visualization"
            case .fingerTap: return "fingerTap"
            case .gratitudeGarden: return "gratitudeGarden"
            case .affirmationCards: return "affirmationCards"
            case .colorBreathing: return "colorBreathing"
            case .mindfulListening: return "mindfulListening"
            case .cognitiveReframe: return "cognitiveReframe"
            case .wordScramble: return "wordScramble"
            case .safePlaceBuilder: return "safePlaceBuilder"
            case .joyMapping: return "joyMapping"
            case .patternMemory: return "patternMemory"
            case .celebrationBreath: return "celebrationBreath"
            }
        }

        var skillId: String { id }

        var skillUnit: String {
            switch self {
            case .breathing, .urgeSurfing, .iceDive:
                return "Urge Management"
            case .thoughtDefusion, .cognitiveReframe, .serial7s:
                return "Cognitive Tools"
            case .bodyScan, .sensoryGrounding, .squareTrace, .butterflyTap:
                return "Body & Calm"
            case .gratitudeGarden, .affirmationCards, .lovingKindness, .visualizationJourney:
                return "Identity & Values"
            case .emotionWheel, .colorBreathing, .fingerTap, .mindfulListening:
                return "Mindfulness"
            case .wordScramble, .safePlaceBuilder, .joyMapping, .patternMemory, .celebrationBreath:
                return "Resilience & Joy"
            }
        }

        var icon: String {
            switch self {
            case .breathing: return "lungs.fill"
            case .urgeSurfing: return "water.waves"
            case .serial7s: return "number"
            case .sensoryGrounding: return "eye.fill"
            case .bodyScan: return "figure.mind.and.body"
            case .iceDive: return "snowflake"
            case .thoughtDefusion: return "cloud.fill"
            case .squareTrace: return "square.dashed"
            case .emotionWheel: return "circle.grid.cross.fill"
            case .butterflyTap: return "hands.sparkles.fill"
            case .lovingKindness: return "heart.circle.fill"
            case .visualizationJourney: return "sparkles"
            case .fingerTap: return "hand.point.up.braille.fill"
            case .gratitudeGarden: return "leaf.fill"
            case .affirmationCards: return "text.badge.star"
            case .colorBreathing: return "paintpalette.fill"
            case .mindfulListening: return "ear.fill"
            case .cognitiveReframe: return "arrow.triangle.2.circlepath"
            case .wordScramble: return "textformat.abc"
            case .safePlaceBuilder: return "house.lodge.fill"
            case .joyMapping: return "star.fill"
            case .patternMemory: return "square.grid.3x3.fill"
            case .celebrationBreath: return "party.popper.fill"
            }
        }

        var title: String {
            switch self {
            case .breathing(let m): return m.rawValue + " Anti-Craving Breath"
            case .urgeSurfing: return "Nicotine Urge Surfing"
            case .serial7s: return "Craving Bandwidth Steal"
            case .sensoryGrounding: return "5-4-3-2-1 Grounding"
            case .bodyScan: return "Withdrawal Tension Release"
            case .iceDive: return "Craving Emergency Reset"
            case .thoughtDefusion: return "Quit-Thought Defusion"
            case .squareTrace: return "Craving Calm Trace"
            case .emotionWheel: return "Withdrawal Feeling ID"
            case .butterflyTap: return "Craving Calm Tap"
            case .lovingKindness: return "Self-Compassion for Quitters"
            case .visualizationJourney: return "Smoke-Free Visualization"
            case .fingerTap: return "Craving Redirect"
            case .gratitudeGarden: return "Smoke-Free Gratitude"
            case .affirmationCards: return "Quit Affirmations"
            case .colorBreathing: return "Clean Air Breathing"
            case .mindfulListening: return "Craving Interrupt: Listen"
            case .cognitiveReframe: return "Smoking Thought Reframe"
            case .wordScramble: return "Quit Word Scramble"
            case .safePlaceBuilder: return "Smoke-Free Sanctuary"
            case .joyMapping: return "Smoke-Free Joy Map"
            case .patternMemory: return "Impulse Control Training"
            case .celebrationBreath: return "Celebrate Your Quit"
            }
        }

        var why: String {
            switch self {
            case .breathing(.fourSevenEight): return "Extended exhale activates your vagus nerve, directly countering the fight-or-flight response that nicotine withdrawal triggers."
            case .breathing(.boxBreathing): return "Used by Navy SEALs under stress. Equal-phase breathing creates autonomic balance that disrupts nicotine craving signals."
            case .breathing(.physiologicalSigh): return "Stanford-researched. The fastest way to calm your nervous system when a nicotine craving hits hard."
            case .urgeSurfing: return "Ride a 3-minute wave that mirrors your nicotine craving. Watch it peak, crest, and dissolve. Cravings can't sustain themselves."
            case .serial7s: return "Math requires the same brain regions as cravings. Complex arithmetic literally starves nicotine urges of cognitive bandwidth."
            case .sensoryGrounding: return "Ground yourself in the present moment. Nicotine cravings pull you into desperation. This pulls you back to reality."
            case .bodyScan: return "Nicotine withdrawal stores as muscle tension. Systematic tense-and-release drains the physical grip of the craving."
            case .iceDive: return "Triggers your dive reflex, instantly slowing your heart rate. The fastest physical way to break a nicotine craving."
            case .thoughtDefusion: return "Type smoking thoughts like 'just one puff' and watch them float away. Breaks the thought-to-cigarette loop."
            case .squareTrace: return "Trace a breathing square on screen. Visual focus plus controlled breathing disrupts the craving signal in your brain."
            case .emotionWheel: return "Nicotine withdrawal causes irritability, anxiety, sadness. Naming the feeling reduces its intensity by up to 50%."
            case .butterflyTap: return "Bilateral tapping calms the amygdala's craving alarm. Your brain's panic response to missing nicotine settles down."
            case .lovingKindness: return "Quitting often comes with shame. Self-compassion practice reduces cortisol and builds the self-forgiveness you need to stay quit."
            case .visualizationJourney: return "Build a mental space where cigarettes don't exist. Visualization activates the same pathways as real experience."
            case .fingerTap: return "Activates your motor cortex, pulling neural resources away from the nicotine craving circuits. Simple but effective."
            case .gratitudeGarden: return "Name what's better since quitting. Gratitude increases natural dopamine, replacing the artificial boost nicotine provided."
            case .affirmationCards: return "Repetition rewires your identity from 'smoker trying to quit' to 'non-smoker.' Identity shift prevents relapse."
            case .colorBreathing: return "Fill your healing lungs with clean air. Every deep breath pushes out residual damage and strengthens new tissue."
            case .mindfulListening: return "Cravings hijack your attention. Sensory focus redirects your brain away from nicotine craving circuits."
            case .cognitiveReframe: return "When your brain says 'just one cigarette,' this CBT technique helps you challenge that thought with evidence from your quit."
            case .wordScramble: return "Cognitive load under time pressure starves nicotine cravings of the bandwidth they need. You can't crave and think hard simultaneously."
            case .safePlaceBuilder: return "Build a portable mental sanctuary for when nicotine cravings strike. Close your eyes and go there instead of to a cigarette."
            case .joyMapping: return "Map your smoke-free joys. Builds evidence that your life without nicotine has real, tangible rewards."
            case .patternMemory: return "Exercises your prefrontal cortex, the part of your brain that says 'no' to nicotine. Stronger here means stronger against cravings."
            case .celebrationBreath: return "Energizing breathwork to celebrate what your quit has achieved. Your lungs are healing. This is what winning feels like."
            }
        }

        var duration: String {
            switch self {
            case .breathing(.fourSevenEight): return "~1 min"
            case .breathing(.boxBreathing): return "~1 min"
            case .breathing(.physiologicalSigh): return "~40 sec"
            case .urgeSurfing: return "~90 sec"
            case .serial7s: return "~60 sec"
            case .sensoryGrounding: return "~2 min"
            case .bodyScan: return "~90 sec"
            case .iceDive: return "~30 sec"
            case .thoughtDefusion: return "~1 min"
            case .squareTrace: return "~1 min"
            case .emotionWheel: return "~30 sec"
            case .butterflyTap: return "~1 min"
            case .lovingKindness: return "~1 min"
            case .visualizationJourney: return "~1 min"
            case .fingerTap: return "~1 min"
            case .gratitudeGarden: return "~1 min"
            case .affirmationCards: return "~1 min"
            case .colorBreathing: return "~50 sec"
            case .mindfulListening: return "~1 min"
            case .cognitiveReframe: return "~1 min"
            case .wordScramble: return "~90 sec"
            case .safePlaceBuilder: return "~1 min"
            case .joyMapping: return "~1 min"
            case .patternMemory: return "~90 sec"
            case .celebrationBreath: return "~30 sec"
            }
        }

        var isInApp: Bool { true }

        static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    }

    static func pool(for mood: Int) -> [InteractiveActivity] {
        switch mood {
        case 0:
            return [
                .breathing(.fourSevenEight),
                .urgeSurfing,
                .iceDive,
                .sensoryGrounding,
                .thoughtDefusion,
            ]
        case 1:
            return [
                .breathing(.boxBreathing),
                .bodyScan,
                .squareTrace,
                .emotionWheel,
                .butterflyTap,
            ]
        case 2:
            return [
                .breathing(.physiologicalSigh),
                .serial7s,
                .lovingKindness,
                .visualizationJourney,
                .fingerTap,
            ]
        case 3:
            return [
                .gratitudeGarden,
                .affirmationCards,
                .colorBreathing,
                .mindfulListening,
                .cognitiveReframe,
            ]
        default:
            return [
                .wordScramble,
                .safePlaceBuilder,
                .joyMapping,
                .patternMemory,
                .celebrationBreath,
            ]
        }
    }

    private var headerLabel: String {
        if cravingIntensity >= 7 { return "CRAVING EMERGENCY" }
        if reportedLapse { return "GETTING BACK ON TRACK" }
        switch mood {
        case 0: return "CRISIS INTERVENTION"
        case 1: return "NICOTINE WITHDRAWAL TOOLS"
        case 2: return "STAYING SMOKE-FREE"
        case 3: return "BUILDING YOUR QUIT"
        default: return "PROTECTING YOUR FREEDOM"
        }
    }

    private var headerTitle: String {
        if cravingIntensity >= 7 { return "Your craving is at \(cravingIntensity)/10.\nThese will bring it down." }
        if reportedLapse { return "A slip is a lesson,\nnot a failure. Let's recover." }
        switch mood {
        case 0: return "Your brain wants nicotine.\nThese tools fight back."
        case 1: return "Withdrawal is tough.\nThese skills get you through."
        case 2: return "Every smoke-free day\nweakens the addiction."
        case 3: return "Build on this momentum.\nYour quit is getting stronger."
        default: return "You're beating nicotine.\nLock in this freedom."
        }
    }

    var allDone: Bool { !completed.isEmpty }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        Spacer(minLength: 20)

                        VStack(spacing: 8) {
                            Text(headerLabel)
                                .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.38)).tracking(1.8)
                            Text(headerTitle)
                                .font(.serif(28, weight: .bold)).foregroundColor(.white)
                            Text("Choose 1 activity")
                                .font(.sansRR(12)).foregroundColor(.white.opacity(0.35))
                        }
                        .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.42), value: appear)

                        VStack(spacing: 12) {
                            ForEach(Array(activities.enumerated()), id: \.element.id) { i, act in
                                actionCard(i, act)
                                    .opacity(appear ? 1 : 0)
                                    .offset(y: appear ? 0 : 22)
                                    .animation(.easeOut(duration: 0.42).delay(Double(i) * 0.09 + 0.16), value: appear)
                            }
                        }
                        .padding(.horizontal, 22)

                        Color.clear.frame(height: 20)
                    }
                }

                Button(action: onContinue) {
                    Text(allDone ? "Continue \u{2192}" : "Pick an activity above")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(allDone ? .black : .black.opacity(0.4))
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(allDone ? Color.white : Color.white.opacity(0.4)).clipShape(Capsule())
                }
                .disabled(!allDone)
                .padding(.horizontal, 22).padding(.bottom, 52).padding(.top, 12)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.5), value: appear)
            }

            if let act = activeActivity {
                interactiveOverlay(act)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            if activities.isEmpty {
                let effectiveMood = cravingIntensity >= 7 ? 0 : mood
                var pool = Self.pool(for: effectiveMood)
                pool.sort { a, b in
                    state.skillPracticeCount(a.skillId) < state.skillPracticeCount(b.skillId)
                }
                activities = pool
            }
            withAnimation { appear = true }
        }
    }

    func actionCard(_ i: Int, _ act: InteractiveActivity) -> some View {
        let done = completed.contains(i)
        return Button {
            if act.isInApp && !done {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { activeActivity = act }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                    if done { completed.remove(i) } else { completed.insert(i) }
                }
            }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(done ? Color(red: 0.35, green: 0.75, blue: 0.45) : Color.white.opacity(0.1))
                        .frame(width: 46, height: 46)
                    Image(systemName: done ? "checkmark" : act.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(done ? .white : .white.opacity(0.72))
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(act.title)
                            .font(.sansRR(14, weight: .bold))
                            .foregroundColor(done ? .white.opacity(0.45) : .white)
                            .strikethrough(done)
                            .multilineTextAlignment(.leading)
                        Text(act.duration)
                            .font(.sansRR(9, weight: .bold)).foregroundColor(.white.opacity(0.35))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.white.opacity(0.08)).clipShape(Capsule())
                    }
                    Text(act.why)
                        .font(.sansRR(11))
                        .foregroundColor(.white.opacity(done ? 0.22 : 0.42))
                        .lineLimit(2).lineSpacing(2).multilineTextAlignment(.leading)
                    if !done {
                        Text("Tap to start \u{2192}")
                            .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.55))
                            .padding(.top, 2)
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(done ? Color.white.opacity(0.04) : Color.white.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(
                        done ? Color(red: 0.35, green: 0.75, blue: 0.45).opacity(0.3) : Color.white.opacity(0.12), lineWidth: 1
                    ))
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func interactiveOverlay(_ act: InteractiveActivity) -> some View {
        let bg = LinearGradient(
            colors: [Color(red: 0.10, green: 0.10, blue: 0.12), Color(red: 0.14, green: 0.12, blue: 0.10)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )

        ZStack(alignment: .topLeading) {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            activeActivity = nil
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left").font(.system(size: 12, weight: .bold))
                            Text("Back").font(.sansRR(14, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(.horizontal, 18).padding(.top, 16)

                interactiveContent(act) {
                    if let idx = activities.firstIndex(of: act) {
                        completed.insert(idx)
                        state.logSkillPractice(act.skillId)
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        activeActivity = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        onContinue()
                    }
                }
            }
        }
    }

    @ViewBuilder
    func interactiveContent(_ act: InteractiveActivity, onDone: @escaping () -> Void) -> some View {
        switch act {
        case .breathing(let mode):
            BreathingPacerView(mode: mode, onComplete: onDone)
        case .urgeSurfing:
            UrgeSurfingView(onComplete: onDone)
        case .serial7s:
            Serial7sGameView(onComplete: onDone)
        case .sensoryGrounding:
            SensoryGroundingView(onComplete: onDone)
        case .bodyScan:
            BodyScanView(onComplete: onDone)
        case .iceDive:
            IceDiveView(onComplete: onDone)
        case .thoughtDefusion:
            ThoughtDefusionView(onComplete: onDone)
        case .squareTrace:
            SquareTraceView(onComplete: onDone)
        case .emotionWheel:
            EmotionWheelView(onComplete: onDone)
        case .butterflyTap:
            ButterflyTapView(onComplete: onDone)
        case .lovingKindness:
            LovingKindnessView(onComplete: onDone)
        case .visualizationJourney:
            VisualizationJourneyView(onComplete: onDone)
        case .fingerTap:
            FingerTapView(onComplete: onDone)
        case .gratitudeGarden:
            GratitudeGardenView(onComplete: onDone)
        case .affirmationCards:
            AffirmationCardsView(onComplete: onDone)
        case .colorBreathing:
            ColorBreathingView(onComplete: onDone)
        case .mindfulListening:
            MindfulListeningView(onComplete: onDone)
        case .cognitiveReframe:
            CognitiveReframeView(onComplete: onDone)
        case .wordScramble:
            WordScrambleView(onComplete: onDone)
        case .safePlaceBuilder:
            SafePlaceBuilderView(onComplete: onDone)
        case .joyMapping:
            JoyMappingView(onComplete: onDone)
        case .patternMemory:
            PatternMemoryView(onComplete: onDone)
        case .celebrationBreath:
            CelebrationBreathView(onComplete: onDone)
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage 6: Future Self Message
// ════════════════════════════════════════════════════════

struct FutureSelfStage: View {
    @Binding var message: String
    let dayNum: Int
    let moodEmoji: String
    let onContinue: () -> Void

    @State private var appear = false
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Spacer(minLength: 22)

                VStack(spacing: 8) {
                    Text(moodEmoji).font(.system(size: 64))
                    Text("CAPTURE THIS FEELING")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.38)).tracking(1.8)
                    Text("Write to your struggling self")
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                }
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45), value: appear)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.pencil").font(.system(size: 11)).foregroundColor(.white.opacity(0.38))
                        Text("FROM: You on Day \(dayNum) · feeling \(moodEmoji)")
                            .font(.sansRR(11, weight: .semibold)).foregroundColor(.white.opacity(0.42))
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down").font(.system(size: 11)).foregroundColor(.white.opacity(0.25))
                        Text("TO: You on your next hard day")
                            .font(.sansRR(11)).foregroundColor(.white.opacity(0.3))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.1), value: appear)

                // Text editor
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.07))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(focused ? 0.3 : 0.11), lineWidth: 1.5))
                    TextEditor(text: $message)
                        .font(.sansRR(14)).foregroundColor(.white)
                        .scrollContentBackground(.hidden).background(Color.clear)
                        .focused($focused).frame(minHeight: 140).padding(14)
                    if message.isEmpty {
                        Text("\"I know today is hard. But I need you to remember what Day \(dayNum) felt like — clear, in control, and free. That feeling is real and it will come back. Just don't quit quitting.\"")
                            .font(.sansRR(13)).foregroundColor(.white.opacity(0.22)).italic()
                            .padding(18).allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, 22)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.2), value: appear)

                HStack(spacing: 8) {
                    Image(systemName: "sparkles").font(.system(size: 11)).foregroundColor(.white.opacity(0.3))
                    Text("This message will appear the next time you check in as struggling.")
                        .font(.sansRR(11)).foregroundColor(.white.opacity(0.32)).lineSpacing(2)
                }
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.3), value: appear)

                Spacer(minLength: 20)

                HStack(spacing: 12) {
                    Button(action: onContinue) {
                        Text("Skip")
                            .font(.sansRR(14, weight: .semibold)).foregroundColor(.white.opacity(0.4))
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.white.opacity(0.07)).clipShape(Capsule())
                    }
                    Button(action: onContinue) {
                        Text(message.isEmpty ? "Continue →" : "Send to future self →")
                            .font(.sansRR(15, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(Color.white).clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 22).padding(.bottom, 52)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.4), value: appear)
            }
        }
        .onAppear { withAnimation { appear = true } }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage 7: End Quote
// ════════════════════════════════════════════════════════

struct EndQuoteStage: View {
    let mood: Int
    let elapsed: TimeInterval
    let dayNum: Int
    let cigsAvoided: Int
    let moneySaved: Double
    let onContinue: () -> Void

    @State private var appear = false

    private struct Quote { let text: String; let attr: String }

    private var quote: Quote {
        let d = Int(elapsed / 86400)
        switch mood {
        case 0: // Struggling — survival-focused
            let pool: [Quote] = [
                Quote(text: "Cravings are temporary. Freedom is forever. This feeling peaks at 3 minutes and subsides. You are minutes away from being stronger.", attr: "Behavioral Delay Framework"),
                Quote(text: "You don't need willpower to quit smoking; you need understanding. This is a biological neuroadaptation process, not a moral failing.", attr: "Cognitive Reframing"),
                Quote(text: "Every cigarette you don't smoke is a victory over your addiction. Surviving a single craving is a monumental triumph.", attr: "Incremental Reinforcement"),
                Quote(text: "The urge to smoke will pass; your health will benefit forever. Transient pain now, permanent biological payoff ahead.", attr: "Acceptance Theory"),
                Quote(text: "One cigarette doesn't make you a smoker again, but it resets your progress. Don't let one slip justify a full relapse.", attr: "Relapse Prevention Theory"),
            ]
            return pool[d % pool.count]
        case 1: // Tough — endurance-focused
            let pool: [Quote] = [
                Quote(text: "The cigarette would end the craving. It would also restart everything — the withdrawals, the wiring, the whole cycle. There is a profound difference.", attr: "Allen Carr"),
                Quote(text: "Every craving you outlast makes the next one permanently weaker. You are not white-knuckling through this. You are rewiring your brain.", attr: "Neuroscience of addiction"),
                Quote(text: "What you're feeling is withdrawal making its final argument. Arguments end. You win by staying in the room.", attr: "Behavioral therapy"),
                Quote(text: "Your brain is healing. The discomfort is proof of recovery, not failure. Each minute of pain is a step toward neurochemical freedom.", attr: "NIDA"),
                Quote(text: "Don't quit quitting. The hardest days build the most resilience. Every minute you hold weakens the receptor signal permanently.", attr: "Recovery principle"),
            ]
            return pool[d % pool.count]
        case 2: // Steady — persistence-focused
            let pool: [Quote] = [
                Quote(text: "The secret of getting ahead is getting started. Daily persistence, even when uneventful, is the literal mechanism of long-term success.", attr: "Action-Oriented Motivation"),
                Quote(text: "Progress, not perfection. Recovery is a trajectory, not a flawless performance. Softening perfectionism prevents relapse.", attr: "CBT Cognitive Defusion"),
                Quote(text: "Health is not valued till sickness comes. You are accruing invisible somatic benefits every single hour of not smoking.", attr: "Protective Motivation"),
                Quote(text: "Quitting is hard. Staying addicted is harder. The temporary boredom of maintenance is nothing compared to lifelong pathology.", attr: "Consequence Reframing"),
                Quote(text: "Strength does not come from physical capacity. It comes from an indomitable will. Consistency is the most profound display of willpower.", attr: "Self-Efficacy Enhancement"),
            ]
            return pool[d % pool.count]
        case 3: // Doing Well — growth-focused
            let pool: [Quote] = [
                Quote(text: "You're not giving up tobacco. You're gaining back your life. Cessation is an aggressive acquisition of freedom, not a loss.", attr: "Positivity Offset"),
                Quote(text: "Quitting smoking is not a sacrifice; it's a liberation. The cigarette didn't provide a crutch. It was the thing that broke your leg.", attr: "Cognitive Restructuring"),
                Quote(text: "Freedom from nicotine addiction is the greatest gift you can give yourself. This is an act of profound self-love.", attr: "Intrinsic Reward Alignment"),
                Quote(text: "This clarity, this control — this is what freedom actually feels like. Not temporary relief. Freedom.", attr: "Recovery insight"),
                Quote(text: "Days like this are why you quit. Your hard days are fighting for them. Don't let the hard days win.", attr: "Motivational interviewing"),
            ]
            return pool[d % pool.count]
        default: // Thriving — identity-focused
            let pool: [Quote] = [
                Quote(text: "I am a non-smoker making a comeback. Not an ex-smoker. Not a quitter. A non-smoker. That identity is statistically protective.", attr: "Identity Shift Paradigm"),
                Quote(text: "Quitting smoking is not about giving up pleasure; it's about giving up poison. The toxicity is real. The pleasure was an illusion.", attr: "Aversive Conditioning"),
                Quote(text: "You didn't just quit smoking. You proved to your brain that you make the decisions — not the craving.", attr: "NIDA"),
                Quote(text: "You've changed your identity. 'Ex-smoker' preserves vulnerability. 'Non-smoker' severs the psychological tether to the drug completely.", attr: "Identity Integration"),
                Quote(text: "The best revenge against addiction is living well. Every breath, every run, every clear-headed morning is evidence of your victory.", attr: "Positive Reinforcement"),
            ]
            return pool[d % pool.count]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // Decorative quote mark
                Text("\"")
                    .font(.serif(110, weight: .heavy))
                    .foregroundColor(.white.opacity(0.06))
                    .offset(y: 44)

                VStack(spacing: 18) {
                    Text(quote.text)
                        .font(.serif(22, weight: .bold)).foregroundColor(.white)
                        .multilineTextAlignment(.center).lineSpacing(7).padding(.horizontal, 26)
                    Text("— \(quote.attr)")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.38)).italic()
                }
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.94)
                .animation(.easeOut(duration: 0.7).delay(0.2), value: appear)

                // Stats reminder
                HStack(spacing: 0) {
                    endStat("\(dayNum)", "days")
                    endStat("\(cigsAvoided)", "avoided")
                    endStat("$\(Int(moneySaved))", "saved")
                }
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.5), value: appear)
            }

            Spacer()

            Button(action: onContinue) {
                Text(endCTA)
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22).padding(.bottom, 52)
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.7), value: appear)
        }
        .onAppear { withAnimation { appear = true } }
    }

    var endCTA: String {
        switch mood {
        case 0: return "I survived. That's everything. \u{2192}"
        case 1: return "I'm still here. I didn't quit. \u{2192}"
        case 2: return "Another day protected. \u{2192}"
        case 3: return "Claim this moment \u{2192}"
        default: return "I am a non-smoker. \u{2192}"
        }
    }

    func endStat(_ v: String, _ l: String) -> some View {
        VStack(spacing: 4) {
            Text(v).font(.serif(22, weight: .bold)).foregroundColor(.white).monospacedDigit()
            Text(l).font(.sansRR(9)).foregroundColor(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(Color.white.opacity(0.07)).clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 4)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage: Pledge
// ════════════════════════════════════════════════════════

struct PledgeStage: View {
    let pledgedToday: Bool
    let streak: Int
    let totalPledges: Int
    let onPledge: () -> Void
    let onContinue: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.07)).frame(width: 92, height: 92)
                    Image(systemName: pledgedToday ? "checkmark.seal.fill" : "hand.raised.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white.opacity(0.88))
                }
                .scaleEffect(appear ? 1 : 0.6).opacity(appear ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.62), value: appear)

                if pledgedToday {
                    VStack(spacing: 10) {
                        Text("YOUR PLEDGE IS LOCKED IN")
                            .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.5)
                        Text("Pledged today. Day protected.")
                            .font(.serif(26, weight: .bold)).foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("\(streak)-day streak \u{00B7} \(totalPledges) total pledges")
                            .font(.sansRR(14)).foregroundColor(.white.opacity(0.5))
                    }
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.2), value: appear)
                } else {
                    VStack(spacing: 10) {
                        Text("DAILY PLEDGE")
                            .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.5)
                        Text("No cigarettes today.")
                            .font(.serif(30, weight: .bold)).foregroundColor(.white)
                        Text("One pledge protects everything\nyour body has been healing.")
                            .font(.sansRR(15)).foregroundColor(.white.opacity(0.55))
                            .multilineTextAlignment(.center).lineSpacing(4)
                        if streak > 0 {
                            Text("Your \(streak)-day streak is at stake.")
                                .font(.sansRR(13, weight: .semibold))
                                .foregroundColor(Color(red: 0.95, green: 0.72, blue: 0.25))
                        }
                    }
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.2), value: appear)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                if pledgedToday {
                    Button(action: onContinue) {
                        Text("Continue →")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                    }
                } else {
                    Button(action: onPledge) {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised.fill").font(.system(size: 16))
                            Text("I commit to staying smoke-free today")
                                .font(.sansRR(15, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                    }
                    Button(action: onContinue) {
                        Text("Skip for now")
                            .font(.sansRR(13)).foregroundColor(.white.opacity(0.32))
                    }
                }
            }
            .padding(.horizontal, 22).padding(.bottom, 52)
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.44), value: appear)
        }
        .onAppear { withAnimation { appear = true } }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Stage: Complete
// ════════════════════════════════════════════════════════

struct CompleteStage: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    let mood: Int
    let dayNum: Int
    let elapsed: TimeInterval
    let onDone: () -> Void

    @State private var appear     = false
    @State private var ringScale  : CGFloat = 0.4

    var completionText: String {
        switch mood {
        case 0: return "You showed up on one of the\nhardest days. That's incredible."
        case 1: return "Today was tough, and you\nstill chose yourself. Be proud."
        case 2: return "Another day of quiet strength.\nYou're doing better than you think."
        case 3: return "You're really finding your way.\nThis progress is yours to keep."
        default: return "Day \(dayNum) of your new life.\nYou deserve to feel this good."
        }
    }

    private var achievedMilestones: [Milestone] {
        RecoveryData.milestones.filter { elapsed >= $0.time }
    }

    private var nextMilestone: (milestone: Milestone, pct: Double)? {
        guard let next = RecoveryData.milestones.first(where: { elapsed < $0.time }) else { return nil }
        let prev = RecoveryData.milestones.last(where: { elapsed >= $0.time })?.time ?? 0
        let pct = (elapsed - prev) / (next.time - prev)
        return (next, min(1, pct))
    }

    private var recentMilestone: Milestone? {
        achievedMilestones.last
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 30)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 2)
                        .frame(width: 104, height: 104)
                    Circle()
                        .fill(Color.white.opacity(0.09))
                        .frame(width: 104, height: 104)
                        .scaleEffect(ringScale)
                    Image(systemName: "checkmark")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(appear ? 1 : 0.45)
                .opacity(appear ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.58), value: appear)

                VStack(spacing: 8) {
                    Text("CHECK-IN COMPLETE")
                        .font(.sansRR(11, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.5)
                    Text(completionText)
                        .font(.serif(26, weight: .bold)).foregroundColor(.white)
                        .multilineTextAlignment(.center).lineSpacing(7)
                }
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.28), value: appear)

                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(Color(red: 0.45, green: 0.78, blue: 0.45))
                    Text("$\(String(format: "%.2f", state.moneySaved)) saved")
                        .font(.sansRR(14, weight: .bold)).foregroundColor(.white)
                    Text("\(state.daysSinceLastLapse) smoke-free days")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.45))
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color.white.opacity(0.09)).clipShape(Capsule())
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.46), value: appear)

                if let recent = recentMilestone {
                    VStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "trophy.fill").font(.system(size: 14))
                                .foregroundColor(Color(red: 0.92, green: 0.76, blue: 0.22))
                            Text("MILESTONE ACHIEVED").font(.sansRR(9, weight: .bold))
                                .foregroundColor(Color(red: 0.92, green: 0.76, blue: 0.22)).tracking(1)
                        }
                        Text(recent.title).font(.serif(18, weight: .bold)).foregroundColor(.white)
                        Text(recent.body).font(.sansRR(12)).foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center).lineSpacing(2).padding(.horizontal, 28)
                        Text(recent.label).font(.sansRR(10, weight: .bold))
                            .foregroundColor(.white.opacity(0.3)).tracking(0.5)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0.92, green: 0.76, blue: 0.22).opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal, 22)
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.58), value: appear)
                }

                if let (next, pct) = nextMilestone {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle().stroke(Color.white.opacity(0.1), lineWidth: 4).frame(width: 44, height: 44)
                            Circle().trim(from: 0, to: pct)
                                .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 44, height: 44).rotationEffect(.degrees(-90))
                            Text("\(Int(pct * 100))%").font(.sansRR(9, weight: .bold)).foregroundColor(.white.opacity(0.5))
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text("NEXT: \(next.label)").font(.sansRR(9, weight: .bold))
                                .foregroundColor(.white.opacity(0.4)).tracking(0.5)
                            Text(next.title).font(.sansRR(14, weight: .semibold)).foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 22)
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.64), value: appear)
                }

                if let insight = gamification.recoveryInsight(for: state) {
                    HStack(spacing: 10) {
                        Image(systemName: "lightbulb.fill").font(.system(size: 14))
                            .foregroundColor(.rAmber)
                        Text(insight)
                            .font(.sansRR(12)).foregroundColor(.white.opacity(0.65))
                            .lineSpacing(3)
                    }
                    .padding(14)
                    .background(Color.rAmber.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 22)
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.66), value: appear)
                }

                Button(action: onDone) {
                    Text("Done")
                        .font(.sansRR(17, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22).padding(.bottom, 52)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.72), value: appear)
            }
        }
        .onAppear {
            withAnimation { appear = true }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.3)) {
                ringScale = 1.25
            }
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Honest Lapse Stage
// ════════════════════════════════════════════════════════

struct HonestLapseStage: View {
    let userName: String
    let dayNum: Int
    let honestStreak: Int
    let onAnswer: (Bool, Bool, Int, [String], [String], [String]) -> Void

    @State private var appear = false
    @State private var selection: String? = nil
    @State private var count: Int = 1
    @State private var step = 0 // 0 = choose, 1 = follow-up

    // "yes" triggers
    @State private var trigger1 = ""
    @State private var trigger2 = ""
    @State private var trigger3 = ""

    // "almost" fields
    @State private var stopped1 = ""
    @State private var stopped2 = ""
    @State private var almostTrigger1 = ""
    @State private var almostTrigger2 = ""

    @FocusState private var focusedField: String?

    private var greeting: String {
        let name = userName.isEmpty ? "" : ", \(userName)"
        let hour = Calendar.current.component(.hour, from: Date())
        let tod = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        return "\(tod)\(name)"
    }

    private var canContinue: Bool {
        switch selection {
        case "no": return true
        case "yes": return step == 0 || !trigger1.trimmingCharacters(in: .whitespaces).isEmpty
        case "almost": return step == 0 || !stopped1.trimmingCharacters(in: .whitespaces).isEmpty
        default: return false
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 40)

                if step == 0 {
                    selectionView
                } else if selection == "yes" {
                    triggersView
                } else if selection == "almost" {
                    almostView
                }

                privacyBadge
                    .padding(.top, 16)

                Spacer(minLength: 24)

                if selection != nil {
                    Button {
                        if selection == "no" {
                            onAnswer(false, false, 0, [], [], [])
                        } else if step == 0 {
                            withAnimation(.easeInOut(duration: 0.35)) { step = 1 }
                        } else if selection == "yes" {
                            let triggers = [trigger1, trigger2, trigger3]
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                            onAnswer(true, false, count, triggers, [], [])
                        } else {
                            let stoppers = [stopped1, stopped2]
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                            let triggers = [almostTrigger1, almostTrigger2]
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                            onAnswer(false, true, 0, [], stoppers, triggers)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(selection == "no" ? "Continue" : (step == 0 ? "Next" : "Continue"))
                                .font(.sansRR(17, weight: .bold))
                            Image(systemName: "arrow.right").font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 19)
                        .background(canContinue ? Color.white : Color.white.opacity(0.4))
                        .clipShape(Capsule())
                        .shadow(color: .white.opacity(0.18), radius: 16, y: 4)
                    }
                    .disabled(!canContinue)
                    .padding(.horizontal, 22).padding(.bottom, 52)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Color.clear.frame(height: 72).padding(.bottom, 52)
                }
            }
        }
        .onAppear { withAnimation { appear = true } }
    }

    // MARK: - Step 0: Selection

    var selectionView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                if honestStreak > 1 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill").font(.system(size: 12)).foregroundColor(.rAmber)
                        Text("\(honestStreak)-day honest streak")
                            .font(.sansRR(12, weight: .semibold)).foregroundColor(.rAmber)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Color.rAmber.opacity(0.12)).clipShape(Capsule())
                    .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.4), value: appear)
                }

                Text(greeting)
                    .font(.sansRR(14)).foregroundColor(.white.opacity(0.45))
                Text("How has it been\nsince last time?")
                    .font(.serif(30, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("Whatever happened, you're here now and that matters. There's no wrong answer.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
                    .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 32)
            }
            .opacity(appear ? 1 : 0).offset(y: appear ? 0 : 18)
            .animation(.easeOut(duration: 0.5), value: appear)

            Spacer(minLength: 32).frame(height: 32)

            VStack(spacing: 12) {
                lapseButton("I stayed smoke-free", icon: "leaf.fill", id: "no",
                            color: Color(red: 0.35, green: 0.75, blue: 0.45))
                lapseButton("It was close, but I held on", icon: "hand.raised.fill", id: "almost",
                            color: .rAmber)
                lapseButton("I had a cigarette", icon: "heart.fill", id: "yes",
                            color: Color(red: 0.70, green: 0.50, blue: 0.55))
            }
            .padding(.horizontal, 22)
            .opacity(appear ? 1 : 0).offset(y: appear ? 0 : 22)
            .animation(.easeOut(duration: 0.45).delay(0.15), value: appear)

            if selection == "yes" {
                VStack(spacing: 8) {
                    Text("Around how many?")
                        .font(.sansRR(13, weight: .semibold)).foregroundColor(.white.opacity(0.6))
                    HStack(spacing: 16) {
                        Button { if count > 1 { count -= 1 } } label: {
                            Image(systemName: "minus.circle.fill").font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        Text("\(count)")
                            .font(.serif(32, weight: .bold)).foregroundColor(.white).monospacedDigit()
                            .frame(minWidth: 44)
                        Button { count += 1 } label: {
                            Image(systemName: "plus.circle.fill").font(.system(size: 28))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    Text("Thank you for being honest with yourself. That takes real courage.")
                        .font(.sansRR(11)).foregroundColor(.white.opacity(0.3))
                }
                .padding(.top, 16)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    // MARK: - Step 1: "Yes" Triggers

    var triggersView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("UNDERSTANDING TOGETHER")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.35)).tracking(2)
                Text("What were your\ntop 3 triggers?")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("Knowing your triggers is one of the most powerful things you can do. Even one word is enough.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
                    .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
            }

            VStack(spacing: 12) {
                triggerField("What set it off?", text: $trigger1, num: 1, id: "t1")
                triggerField("What else was going on?", text: $trigger2, num: 2, id: "t2")
                triggerField("Anything else?", text: $trigger3, num: 3, id: "t3")
            }
            .padding(.horizontal, 22)

            Text("Skip any you're not sure about")
                .font(.sansRR(11)).foregroundColor(.white.opacity(0.25))
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Step 1: "Almost" Reflections

    var almostView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("YOU HELD ON")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.rAmber).tracking(2)
                Text("That took strength.\nLet's learn from it.")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("Understanding what nearly pulled you in, and what kept you strong, helps build your defense.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
                    .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
            }

            VStack(alignment: .leading, spacing: 6) {
                Label("What helped you resist?", systemImage: "shield.fill")
                    .font(.sansRR(13, weight: .bold)).foregroundColor(Color(red: 0.45, green: 0.78, blue: 0.45))
                triggerField("What kept you from smoking?", text: $stopped1, num: 1, id: "s1")
                triggerField("Anything else that helped?", text: $stopped2, num: 2, id: "s2")
            }
            .padding(.horizontal, 22)

            VStack(alignment: .leading, spacing: 6) {
                Label("What almost pulled you in?", systemImage: "wind")
                    .font(.sansRR(13, weight: .bold)).foregroundColor(.rAmber)
                triggerField("What triggered the urge?", text: $almostTrigger1, num: 1, id: "a1")
                triggerField("Was there anything else?", text: $almostTrigger2, num: 2, id: "a2")
            }
            .padding(.horizontal, 22)

            Text("Skip any you're not sure about")
                .font(.sansRR(11)).foregroundColor(.white.opacity(0.25))
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }

    // MARK: - Privacy Badge

    var privacyBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 13)).foregroundColor(Color(red: 0.45, green: 0.78, blue: 0.45))
            VStack(alignment: .leading, spacing: 1) {
                Text("100% on-device. Nothing leaves your phone.")
                    .font(.sansRR(10, weight: .semibold)).foregroundColor(.white.opacity(0.4))
                Text("Chat history is zero-trace.")
                    .font(.sansRR(9)).foregroundColor(.white.opacity(0.25))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 1))
        .padding(.horizontal, 22)
    }

    // MARK: - Shared Components

    func triggerField(_ placeholder: String, text: Binding<String>, num: Int, id: String) -> some View {
        HStack(spacing: 10) {
            Text("\(num)")
                .font(.sansRR(12, weight: .bold)).foregroundColor(.white.opacity(0.3))
                .frame(width: 22, height: 22)
                .background(Color.white.opacity(0.06)).clipShape(Circle())
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.22)))
                .font(.sansRR(14)).foregroundColor(.white)
                .focused($focusedField, equals: id)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color.white.opacity(focusedField == id ? 0.08 : 0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
            focusedField == id ? Color.white.opacity(0.2) : Color.white.opacity(0.06), lineWidth: 1
        ))
    }

    func lapseButton(_ label: String, icon: String, id: String, color: Color) -> some View {
        let sel = selection == id
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.62)) { selection = id }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(sel ? color : Color.white.opacity(0.08)).frame(width: 42, height: 42)
                    Image(systemName: sel ? "checkmark" : icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(sel ? .white : color)
                }
                Text(label).font(.sansRR(15, weight: .semibold))
                    .foregroundColor(sel ? .white : .white.opacity(0.7))
                Spacer()
                if sel {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 18)).foregroundColor(color)
                }
            }
            .padding(14)
            .background(Color.white.opacity(sel ? 0.12 : 0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(
                sel ? color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: sel ? 1.5 : 1
            ))
        }
        .buttonStyle(.plain)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Craving Check Stage
// ════════════════════════════════════════════════════════

struct CravingCheckStage: View {
    let reportedLapse: Bool
    let onContinue: (Int) -> Void

    @State private var intensity: Double = 3
    @State private var appear = false

    private var intVal: Int { Int(intensity) }

    private var intensityLabel: String {
        switch intVal {
        case 0:     return "Peaceful"
        case 1...2: return "Just a whisper"
        case 3...4: return "I can handle this"
        case 5...6: return "It's pulling at me"
        case 7...8: return "It's loud right now"
        case 9:     return "Really struggling"
        default:    return "I need help"
        }
    }

    private var intensityColor: Color {
        switch intVal {
        case 0...2:  return Color(red: 0.35, green: 0.75, blue: 0.45)
        case 3...4:  return .rAmber
        case 5...6:  return Color(red: 0.85, green: 0.55, blue: 0.25)
        case 7...8:  return Color(red: 0.85, green: 0.35, blue: 0.25)
        default:     return .rDanger
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 50)

            VStack(spacing: 8) {
                Text("RIGHT NOW")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.35)).tracking(2)
                Text("How are cravings\nfeeling right now?")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("No judgment here. This helps us find the right support for you today.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
                    .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
            }
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45), value: appear)

            Spacer(minLength: 36)

            VStack(spacing: 18) {
                Text("\(intVal)")
                    .font(.serif(56, weight: .bold)).foregroundColor(intensityColor)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: intVal)
                Text(intensityLabel)
                    .font(.sansRR(16, weight: .semibold)).foregroundColor(.white.opacity(0.7))

                VStack(spacing: 8) {
                    Slider(value: $intensity, in: 0...10, step: 1)
                        .tint(intensityColor)
                        .padding(.horizontal, 32)
                    HStack {
                        Text("0").font(.sansRR(10)).foregroundColor(.white.opacity(0.25))
                        Spacer()
                        Text("10").font(.sansRR(10)).foregroundColor(.white.opacity(0.25))
                    }
                    .padding(.horizontal, 36)
                }
            }
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.15), value: appear)

            Spacer(minLength: 32)

            Button { onContinue(intVal) } label: {
                HStack(spacing: 8) {
                    Text("Continue").font(.sansRR(17, weight: .bold))
                    Image(systemName: "arrow.right").font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity).padding(.vertical, 19)
                .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22).padding(.bottom, 52)
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.3), value: appear)
        }
        .onAppear { withAnimation { appear = true } }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Lapse Debrief Stage
// ════════════════════════════════════════════════════════

struct LapseDebriefStage: View {
    let triggers: [String]
    let onComplete: (String, String) -> Void

    @State private var appear = false
    @State private var step = 0
    @State private var selectedTrigger: String? = nil
    @State private var selectedPlan: String? = nil

    private let allTriggers: [(String, String, String)] = [
        ("bolt.fill",       "Stress",          "Work, money, relationships"),
        ("person.2.fill",   "Social pressure", "Friends smoking, parties"),
        ("clock.fill",      "Habit/routine",   "After meals, morning coffee"),
        ("cloud.rain.fill", "Boredom",         "Nothing to do, restless"),
        ("wineglass.fill",  "Alcohol",         "Drinking lowered my guard"),
        ("heart.slash.fill","Emotional pain",   "Sadness, anger, loneliness"),
        ("moon.fill",       "Poor sleep",       "Tired, foggy, irritable"),
    ]

    private let planOptions: [(String, String, String)] = [
        ("wind",               "Breathing exercise", "Use 4-7-8 or box breathing"),
        ("figure.walk",        "Walk it off",        "Change your environment"),
        ("brain.head.profile", "Urge surf it",       "Observe without acting"),
        ("phone.fill",         "Call someone",       "Reach out for support"),
        ("timer",              "30-minute delay",    "Just wait it out"),
        ("pencil.line",        "Journal about it",   "Write what you feel"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 32)

            VStack(spacing: 8) {
                Text("LEARNING TOGETHER")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.35)).tracking(2)
                Text(step == 0 ? "What was going on\naround that time?" : "What might help\nnext time?")
                    .font(.serif(26, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text(step == 0
                     ? "Understanding your triggers turns slips into data, not defeat."
                     : "Pick one skill to try when this trigger hits again.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
                    .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 24)
            }
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45), value: appear)

            Spacer(minLength: 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    if step == 0 {
                        ForEach(allTriggers.indices, id: \.self) { i in
                            let t = allTriggers[i]
                            debriefOption(icon: t.0, label: t.1, desc: t.2,
                                          selected: selectedTrigger == t.1) {
                                withAnimation(.spring(response: 0.25)) { selectedTrigger = t.1 }
                            }
                        }
                    } else {
                        ForEach(planOptions.indices, id: \.self) { i in
                            let p = planOptions[i]
                            debriefOption(icon: p.0, label: p.1, desc: p.2,
                                          selected: selectedPlan == p.1) {
                                withAnimation(.spring(response: 0.25)) { selectedPlan = p.1 }
                            }
                        }
                    }
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 16)

            let canContinue = step == 0 ? selectedTrigger != nil : selectedPlan != nil
            Button {
                if step == 0 {
                    withAnimation { step = 1 }
                } else {
                    onComplete(selectedTrigger ?? "Unknown", selectedPlan ?? "")
                }
            } label: {
                Text(step == 0 ? "Next" : "I have a plan")
                    .font(.sansRR(17, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.4)
            .padding(.horizontal, 22).padding(.bottom, 52)
        }
        .onAppear { withAnimation { appear = true } }
    }

    func debriefOption(icon: String, label: String, desc: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(selected ? Color.white.opacity(0.2) : Color.white.opacity(0.06))
                        .frame(width: 42, height: 42)
                    Image(systemName: icon).font(.system(size: 17)).foregroundColor(selected ? .white : .white.opacity(0.55))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.sansRR(14, weight: .bold)).foregroundColor(.white)
                    Text(desc).font(.sansRR(11)).foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 18))
                        .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.45))
                }
            }
            .padding(14)
            .background(Color.white.opacity(selected ? 0.1 : 0.05))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(
                selected ? Color.white.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1
            ))
        }
        .buttonStyle(.plain)
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Micro-Commitment Stage
// ════════════════════════════════════════════════════════

struct MicroCommitStage: View {
    let yesterdayCommitment: MicroCommitment?
    let onCommit: (String) -> Void

    @State private var appear = false
    @State private var selectedSkill: String? = nil
    @State private var followedThrough: Bool? = nil

    private let skills: [(String, String)] = [
        ("wind",               "Breathing exercise"),
        ("figure.walk",        "Go for a walk"),
        ("brain.head.profile", "Urge surf the craving"),
        ("timer",              "30-minute delay"),
        ("drop.fill",          "Cold water on face"),
        ("pencil.line",        "Write about it"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 32)

            VStack(spacing: 8) {
                Text("YOUR PLAN")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.35)).tracking(2)
                Text("If a craving hits today,\nwhat will you do?")
                    .font(.serif(26, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("People who pick a specific response ahead of time are 2-3x more likely to resist.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
                    .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
            }
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45), value: appear)

            if let yc = yesterdayCommitment {
                VStack(spacing: 10) {
                    Text("YESTERDAY YOU COMMITTED TO:")
                        .font(.sansRR(9, weight: .bold)).foregroundColor(.white.opacity(0.3)).tracking(1)
                    Text(yc.skillId)
                        .font(.sansRR(14, weight: .semibold)).foregroundColor(.white.opacity(0.7))
                    if followedThrough == nil {
                        HStack(spacing: 12) {
                            Button { withAnimation { followedThrough = true } } label: {
                                Text("I used it")
                                    .font(.sansRR(13, weight: .bold)).foregroundColor(.white)
                                    .padding(.horizontal, 20).padding(.vertical, 10)
                                    .background(Color(red: 0.35, green: 0.75, blue: 0.45).opacity(0.3))
                                    .clipShape(Capsule())
                            }
                            Button { withAnimation { followedThrough = false } } label: {
                                Text("Didn't need it")
                                    .font(.sansRR(13, weight: .bold)).foregroundColor(.white.opacity(0.5))
                                    .padding(.horizontal, 20).padding(.vertical, 10)
                                    .background(Color.white.opacity(0.06)).clipShape(Capsule())
                            }
                        }
                    } else {
                        Text(followedThrough == true ? "That's great. Building those habits makes you stronger." : "Good to know. Having the plan ready still matters.")
                            .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 22).padding(.top, 20)
                .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.1), value: appear)
            }

            Spacer(minLength: 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(skills.indices, id: \.self) { i in
                        let s = skills[i]
                        let sel = selectedSkill == s.1
                        Button {
                            withAnimation(.spring(response: 0.25)) { selectedSkill = s.1 }
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: s.0).font(.system(size: 17))
                                    .foregroundColor(sel ? .white : .white.opacity(0.5)).frame(width: 24)
                                Text(s.1).font(.sansRR(14, weight: .semibold))
                                    .foregroundColor(sel ? .white : .white.opacity(0.65))
                                Spacer()
                                if sel {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 18))
                                        .foregroundColor(Color(red: 0.35, green: 0.75, blue: 0.45))
                                }
                            }
                            .padding(14)
                            .background(Color.white.opacity(sel ? 0.1 : 0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                                sel ? Color.white.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1
                            ))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 16)

            Button { onCommit(selectedSkill ?? "") } label: {
                Text(selectedSkill != nil ? "That's my plan" : "Skip for now")
                    .font(.sansRR(17, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22).padding(.bottom, 52)
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.45).delay(0.3), value: appear)
        }
        .onAppear { withAnimation { appear = true } }
    }
}
