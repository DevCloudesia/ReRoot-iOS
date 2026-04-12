import Foundation
import SwiftUI
@preconcurrency import UserNotifications

// MARK: - Nudge Types

enum NudgeCategory {
    case momentum       // First-quitter advantage, golden window
    case kindling       // Neurological cost of relapse cycles
    case lossAversion   // What they stand to lose (streak, money, health)
    case affirmation    // Motivational Interviewing / empowerment
    case jitai          // Just-in-Time Adaptive Intervention (HRV-triggered)
}

struct Nudge: Identifiable, Equatable {
    let id = UUID()
    let category: NudgeCategory
    let headline: String
    let body: String
    let cta: String
    let icon: String
    let color: Color

    static func == (lhs: Nudge, rhs: Nudge) -> Bool { lhs.id == rhs.id }
}

// MARK: - Nudge Engine

@MainActor
class NudgeEngine: ObservableObject {
    @Published var activeNudge: Nudge?
    @Published var nudgeQueue: [Nudge] = []
    @Published var dismissedNudges: Set<UUID> = []
    @Published var lastNudgeTime: Date?

    private var cooldownSeconds: TimeInterval = 1800  // 30-min minimum between nudges

    var canNudge: Bool {
        guard let last = lastNudgeTime else { return true }
        return Date().timeIntervalSince(last) > cooldownSeconds
    }

    // MARK: - Trigger Evaluation (call from HomeView on state change)

    func evaluate(state: AppState, hkManager: HealthKitManager, gamification: GamificationState) {
        guard canNudge else { return }

        // Priority 1: HRV stress signal (JITAI — highest clinical priority)
        if hkManager.stressSignalDetected {
            trigger(buildJITAINudge(state: state, gamification: gamification))
            return
        }

        // Priority 2: Missed daily pledge (evening)
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 20 && !gamification.pledgedToday && state.elapsed > 3600 {
            trigger(buildKindlingNudge(state: state, gamification: gamification))
            return
        }

        // Priority 3: Low mood + early quit (loss aversion)
        if let lastMood = state.moodLog.last, lastMood.mood < 2,
           Calendar.current.isDateInToday(lastMood.time) {
            trigger(buildLossAversionNudge(state: state, gamification: gamification))
            return
        }

        // Priority 4: First 3 days without a nudge today (momentum)
        if state.elapsed / 86400 < 3 {
            if let lastNudge = lastNudgeTime, !Calendar.current.isDateInToday(lastNudge) {
                trigger(buildMomentumNudge(state: state, gamification: gamification))
                return
            } else if lastNudgeTime == nil {
                trigger(buildMomentumNudge(state: state, gamification: gamification))
                return
            }
        }

        // Priority 5: Affirmation after resisting a craving
        if let lastCraving = state.cravingLog.last,
           Calendar.current.isDateInToday(lastCraving.time),
           state.cravingLog.count > 0 {
            trigger(buildAffirmationNudge(state: state, gamification: gamification))
        }
    }

    func trigger(_ nudge: Nudge) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            activeNudge = nudge
            lastNudgeTime = Date()
        }
    }

    func dismiss() {
        if let nudge = activeNudge { dismissedNudges.insert(nudge.id) }
        withAnimation(.easeOut(duration: 0.3)) { activeNudge = nil }
    }

    // MARK: - Nudge Builders

    func buildMomentumNudge(state: AppState, gamification: GamificationState) -> Nudge {
        let hours = Int(state.elapsed / 3600)
        let messages: [Nudge] = [
            .init(category: .momentum,
                  headline: "You're in Your Golden Window",
                  body: "Research shows momentum is your greatest asset. Stopping now makes the next attempt up to 60% harder neurologically. Your brain is already doing the hard rewiring work — don't interrupt it.",
                  cta: "Keep the momentum",
                  icon: "bolt.ring.closed.fill",
                  color: .rAmber),
            .init(category: .momentum,
                  headline: "You've Already Paid the Entry Fee",
                  body: "The first \(hours) hours are the most expensive in willpower and physical discomfort. You've already paid that price in full. Don't throw away that investment just to have to pay it all over again.",
                  cta: "Protect your investment",
                  icon: "dollarsign.circle.fill",
                  color: .rAmber),
            .init(category: .momentum,
                  headline: "Don't Let the Hill Get Steeper",
                  body: "Your brain is already rewiring. A setback now means tomorrow's attempt requires more effort for the same result. Stay on the path while the wind is at your back.",
                  cta: "Stay the course",
                  icon: "arrow.up.forward.circle.fill",
                  color: .rAmber),
        ]
        return messages.randomElement()!
    }

    func buildKindlingNudge(state: AppState, gamification: GamificationState) -> Nudge {
        let messages: [Nudge] = [
            .init(category: .kindling,
                  headline: "Protect Your Brain from the Kindling Effect",
                  body: "Every stop-and-start cycle sensitizes your nervous system — a clinically documented process called Kindling. Each future withdrawal becomes sharper and more intense. Quitting completely today is the kindest thing you can do for your future self.",
                  cta: "Check in now",
                  icon: "flame.fill",
                  color: Color(red: 0.8, green: 0.35, blue: 0.1)),
            .init(category: .kindling,
                  headline: "The Hardest Part Is Starting Over",
                  body: "Your evening check-in is unlogged. Miss it and your streak is at risk. More importantly: every failed attempt makes your brain 'learn' to react more aggressively next time. Close the loop tonight.",
                  cta: "Complete evening check-in",
                  icon: "moon.stars.fill",
                  color: Color(red: 0.8, green: 0.35, blue: 0.1)),
            .init(category: .kindling,
                  headline: "Withdrawal Is a Lesson Your Brain Learns",
                  body: "With each failed attempt, your nervous system learns to react faster and harder. Don't let the kindling build — one successful night is one less log on tomorrow's fire.",
                  cta: "Log tonight's check-in",
                  icon: "brain.head.profile",
                  color: Color(red: 0.8, green: 0.35, blue: 0.1)),
        ]
        return messages.randomElement()!
    }

    func buildLossAversionNudge(state: AppState, gamification: GamificationState) -> Nudge {
        let days = state.dayNum
        let savings = String(format: "$%.2f", state.moneySaved)
        let cigs = state.cigsAvoided
        let streak = gamification.currentStreak

        let messages: [Nudge] = [
            .init(category: .lossAversion,
                  headline: "You're About to Lose \(savings) and \(days) Days",
                  body: "Relapsing isn't a reset — it's an active loss of the streak, money, and health you've already earned. Don't let a 10-minute craving steal \(days) days of hard-won progress.",
                  cta: "Keep what's mine",
                  icon: "lock.shield.fill",
                  color: .rDanger),
            .init(category: .lossAversion,
                  headline: "Your \(streak)-Day Streak Is a Shield",
                  body: "Your streak isn't just a number — it's a biological record of your nervous system rebalancing. If you stop now, that shield shatters. You've earned \(days) days of clarity. Don't trade a permanent gain for a temporary hit.",
                  cta: "Protect my streak",
                  icon: "shield.fill",
                  color: .rDanger),
            .init(category: .lossAversion,
                  headline: "Relapse Is a Debt You Can't Afford",
                  body: "It takes minutes to relapse but weeks to return to exactly where you stand right now. You've skipped \(cigs) cigarettes and saved \(savings). Don't spend the next month wishing you were exactly where you are today.",
                  cta: "Keep what I've built",
                  icon: "chart.line.uptrend.xyaxis.circle.fill",
                  color: .rDanger),
        ]
        return messages.randomElement()!
    }

    func buildAffirmationNudge(state: AppState, gamification: GamificationState) -> Nudge {
        let cravings = state.cravingLog.count
        let messages: [Nudge] = [
            .init(category: .affirmation,
                  headline: "You're Stronger Than a Chemical Signal",
                  body: "A craving is just a 15-minute electrical storm in your brain. You've weathered \(cravings) of these already. Each one you ride makes the receptor signal weaker. You are a survivor, not a victim of your biology.",
                  cta: "I know I can do this",
                  icon: "bolt.shield.fill",
                  color: .rAccent),
            .init(category: .affirmation,
                  headline: "Recovery Is Progression, Not Perfection",
                  body: "Today, progression means not stopping. You have the ability to choose your brand-new ending right now. The neuroscience is clear: every hour of abstinence rewires your reward system away from addiction.",
                  cta: "Choose my ending",
                  icon: "star.fill",
                  color: .rAccent),
        ]
        return messages.randomElement()!
    }

    func buildJITAINudge(state: AppState, gamification: GamificationState) -> Nudge {
        let days = state.dayNum
        let savings = String(format: "$%.2f", state.moneySaved)
        return .init(
            category: .jitai,
            headline: "⚡ Stress Signal Detected",
            body: "Apple Health detected a drop in your Heart Rate Variability — a physiological sign that stress is building, often before a craving reaches conscious awareness. This is your Golden Window to act now, not after the craving peaks. You have \(days) days and \(savings) on the line.",
            cta: "Start breathing exercise",
            icon: "waveform.path.ecg.rectangle.fill",
            color: .rDanger
        )
    }

    // MARK: - Push Notification Scheduling (local)

    func scheduleEveningCheckInReminder(pledgedToday: Bool) {
        guard !pledgedToday else { return }

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "⚠️ Kindling Alert"
            content.body = "The hardest part of quitting is starting over. Check in tonight to protect your streak — and your brain."
            content.sound = .default

            var components = DateComponents()
            components.hour = 20
            components.minute = 30
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "evening_checkin", content: content, trigger: trigger)
            center.add(request)
        }
    }

    func scheduleMorningMomentumReminder() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "🌱 Golden Window — Day \(Int(Date().timeIntervalSince1970 / 86400))"
        content.body = "Make your daily pledge now. Every 24-hour pledge is a neural vote against the habit loop. Your streak is waiting."
        content.sound = .default

        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "morning_pledge", content: content, trigger: trigger)
        center.add(request)
    }
}

// MARK: - Nudge Banner View

struct NudgeBannerView: View {
    let nudge: Nudge
    let onDismiss: () -> Void
    let onCTA: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle().fill(nudge.color.opacity(0.15)).frame(width: 42, height: 42)
                    Image(systemName: nudge.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(nudge.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(categoryLabel(nudge.category))
                            .font(.sansRR(9, weight: .bold))
                            .foregroundColor(nudge.color)
                            .tracking(1)
                        Spacer()
                        Button { onDismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.rText3.opacity(0.6))
                        }
                    }
                    Text(nudge.headline)
                        .font(.sansRR(15, weight: .bold))
                        .foregroundColor(.rText)
                    Text(nudge.body)
                        .font(.sansRR(12))
                        .foregroundColor(.rText2)
                        .lineSpacing(3)
                }
            }

            Button(action: onCTA) {
                Text(nudge.cta)
                    .font(.sansRR(13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(nudge.color)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(nudge.color.opacity(0.25), lineWidth: 1.5))
        .shadow(color: nudge.color.opacity(0.2), radius: 20, y: 6)
        .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.96)))
    }

    func categoryLabel(_ cat: NudgeCategory) -> String {
        switch cat {
        case .momentum:     return "MOMENTUM ALERT"
        case .kindling:     return "KINDLING EFFECT WARNING"
        case .lossAversion: return "LOSS AVERSION — WHAT'S AT STAKE"
        case .affirmation:  return "MOTIVATIONAL CHECK-IN"
        case .jitai:        return "JUST-IN-TIME ADAPTIVE INTERVENTION"
        }
    }
}
