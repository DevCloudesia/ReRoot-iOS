import Foundation
import SwiftUI

// MARK: - Achievement

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let desc: String
    let icon: String
    let xpReward: Int
    var earnedDate: Date?

    var isEarned: Bool { earnedDate != nil }
}

// MARK: - Digital Chip (Recovery Milestone Reward)

struct DigitalChip: Identifiable, Codable {
    let id: String
    let name: String
    let days: Int
    let color: String   // hex
    let icon: String
    var earnedDate: Date?
    var isEarned: Bool { earnedDate != nil }
}

// MARK: - Supplement Log Entry

struct SupplementEntry: Identifiable, Codable {
    var id = UUID()
    let supplementId: String
    let date: Date
}

// MARK: - Exercise Log Entry

struct ExerciseEntry: Identifiable, Codable {
    var id = UUID()
    let type: String
    let minutes: Int
    let date: Date
    let notes: String
}

// MARK: - Supplement Definition

struct SupplementInfo: Identifiable {
    let id: String
    let name: String
    let icon: String
    let shortDesc: String
    let research: String
    let category: String
    let color: Color
}

// MARK: - Gamification State

class GamificationState: ObservableObject {
    @Published var xp: Int = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastPledgeDate: Date?
    @Published var totalPledges: Int = 0
    @Published var achievements: [Achievement] = []
    @Published var digitalChips: [DigitalChip] = []
    @Published var supplementLog: [SupplementEntry] = []
    @Published var exerciseLog: [ExerciseEntry] = []

    var pledgedToday: Bool {
        guard let last = lastPledgeDate else { return false }
        return Calendar.current.isDateInToday(last)
    }

    var level: Int { xp / 100 + 1 }
    var xpToNextLevel: Int { 100 - (xp % 100) }
    var xpProgress: Double { Double(xp % 100) / 100.0 }

    var levelTitle: String {
        switch level {
        case 1:  return "First Smoke-Free Step"
        case 2:  return "Breaking the Habit"
        case 3:  return "Beating Withdrawal"
        case 4:  return "Craving Fighter"
        case 5:  return "Turning Point"
        case 6:  return "Reclaiming Your Lungs"
        case 7:  return "Non-Smoker Rising"
        case 8:  return "Nicotine-Free Veteran"
        case 9:  return "Quit Champion"
        default: return "Permanently Free"
        }
    }

    func recoveryInsight(for state: AppState) -> String? {
        let breathingCount = state.skillLog.filter { $0.skillId.contains("breathing") }.count
        if breathingCount >= 5 {
            return "You've done \(breathingCount) anti-craving breathing exercises. Research shows this is when the technique becomes your automatic response to nicotine urges."
        }
        let urgeSurfCount = state.skillPracticeCount("urgeSurf")
        if urgeSurfCount >= 3 {
            return "You've surfed \(urgeSurfCount) nicotine urges. Each one you rode out physically weakened the craving pathway in your brain."
        }
        if state.lapsedToday {
            return "You slipped but came back. Studies show that quitters who return after a lapse are more likely to quit permanently than those who never slipped."
        }
        let totalSkills = state.skillLog.count
        if totalSkills >= 10 {
            return "You've completed \(totalSkills) anti-nicotine skill sessions. Your brain now has real alternatives to reaching for a cigarette."
        }
        if state.honestStreak >= 3 {
            return "\(state.honestStreak) days of honest check-ins about your smoking. This self-awareness is what separates people who quit temporarily from people who quit for good."
        }
        if state.daysSinceLastLapse >= 7 {
            return "\(state.daysSinceLastLapse) days without a single cigarette. Your nicotinic receptors are downregulating. The cravings are getting weaker."
        }
        return nil
    }

    // Supplements tracked (non-prescription, research-supported)
    static let availableSupplements: [SupplementInfo] = [
        .init(id: "magnesium",  name: "Magnesium",    icon: "bolt.circle",
              shortDesc: "Reduces anxiety & muscle tension",
              research: "Research suggests magnesium may reduce neuromuscular hyperactivity and anxiety during withdrawal. Commonly deficient in smokers.",
              category: "Calming", color: .rAccent),
        .init(id: "b_complex",  name: "B-Complex",    icon: "brain.head.profile",
              shortDesc: "Supports nervous system recovery",
              research: "B vitamins (especially B1/Thiamine) are essential for neurological recovery and energy metabolism disrupted by nicotine dependence.",
              category: "Neuro", color: .rAmber),
        .init(id: "nac",        name: "NAC",          icon: "atom",
              shortDesc: "May reduce cravings (glutamate modulation)",
              research: "N-Acetylcysteine has been studied for reducing nicotine and other cravings by modulating glutamate transmission in the reward circuitry. OTC supplement.",
              category: "Craving Support", color: .rPurple),
        .init(id: "melatonin",  name: "Melatonin",    icon: "moon.fill",
              shortDesc: "Restores sleep architecture",
              research: "Low-dose melatonin may help restore REM sleep patterns disrupted by years of nicotine use. Sleep quality is a key predictor of quit success.",
              category: "Sleep", color: Color(red: 0.3, green: 0.3, blue: 0.7)),
        .init(id: "omega3",     name: "Omega-3",      icon: "drop.fill",
              shortDesc: "Supports mood & brain recovery",
              research: "Omega-3 fatty acids support neuroinflammation reduction and mood regulation — both affected by chronic nicotine use and withdrawal.",
              category: "Mood", color: Color(red: 0.2, green: 0.5, blue: 0.8)),
        .init(id: "vitamin_d",  name: "Vitamin D",    icon: "sun.max.fill",
              shortDesc: "Mood regulation & immune support",
              research: "Vitamin D deficiency is associated with depression and poorer withdrawal outcomes. Supports dopamine receptor function.",
              category: "Mood", color: Color(red: 0.8, green: 0.6, blue: 0.1)),
    ]

    // MARK: - Actions

    func makeDailyPledge(elapsed: TimeInterval) {
        guard !pledgedToday else { return }
        lastPledgeDate = Date()
        totalPledges += 1

        // Update streak
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        if let last = lastPledgeDate, Calendar.current.isDate(last, inSameDayAs: yesterday) {
            currentStreak += 1
        } else if totalPledges == 1 {
            currentStreak = 1
        } else {
            currentStreak = 1  // broken streak, reset
        }
        longestStreak = max(longestStreak, currentStreak)

        addXP(25, reason: "Daily pledge")
        checkAchievements(elapsed: elapsed)
        persist()
    }

    func addXP(_ amount: Int, reason: String) {
        xp += amount
        persist()
    }

    func logSupplement(_ id: String) {
        supplementLog.append(SupplementEntry(supplementId: id, date: Date()))
        addXP(10, reason: "Supplement logged")
        persist()
    }

    func logExercise(type: String, minutes: Int, notes: String = "") {
        exerciseLog.append(ExerciseEntry(type: type, minutes: minutes, date: Date(), notes: notes))
        addXP(minutes > 30 ? 30 : 20, reason: "Exercise logged")
        persist()
    }

    func supplementsTakenToday() -> Set<String> {
        let today = supplementLog.filter { Calendar.current.isDateInToday($0.date) }
        return Set(today.map(\.supplementId))
    }

    // MARK: - Achievement & Chip Checking

    func checkAchievements(elapsed: TimeInterval) {
        let days = Int(elapsed / 86400)

        // Digital Chips
        for i in digitalChips.indices {
            if !digitalChips[i].isEarned && days >= digitalChips[i].days {
                digitalChips[i].earnedDate = Date()
                addXP(digitalChips[i].days * 10, reason: "Chip earned")
            }
        }

        // Achievements
        for i in achievements.indices {
            let ach = achievements[i]
            guard !ach.isEarned else { continue }
            var shouldEarn = false
            switch ach.id {
            case "first_craving_beaten":  shouldEarn = false  // triggered externally
            case "pledge_3":              shouldEarn = totalPledges >= 3
            case "pledge_7":              shouldEarn = totalPledges >= 7
            case "pledge_30":             shouldEarn = totalPledges >= 30
            case "streak_7":              shouldEarn = currentStreak >= 7
            case "streak_30":             shouldEarn = currentStreak >= 30
            case "day_1":                 shouldEarn = days >= 1
            case "day_3":                 shouldEarn = days >= 3
            case "day_7":                 shouldEarn = days >= 7
            case "day_30":                shouldEarn = days >= 30
            case "exercise_1":            shouldEarn = !exerciseLog.isEmpty
            case "exercise_7":            shouldEarn = exerciseLog.count >= 7
            case "supplement_7":          shouldEarn = supplementLog.count >= 7
            default: break
            }
            if shouldEarn {
                achievements[i].earnedDate = Date()
                addXP(ach.xpReward, reason: ach.title)
            }
        }
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        encode(xp,             key: "gg_xp")
        encode(currentStreak,  key: "gg_streak")
        encode(longestStreak,  key: "gg_longestStreak")
        encode(totalPledges,   key: "gg_pledges")
        encode(achievements,   key: "gg_achievements")
        encode(digitalChips,   key: "gg_chips")
        encode(supplementLog,  key: "gg_supplements")
        encode(exerciseLog,    key: "gg_exercise")
        if let d = lastPledgeDate { UserDefaults.standard.set(d, forKey: "gg_lastPledge") }
    }

    private func encode<T: Encodable>(_ v: T, key: String) {
        if let data = try? JSONEncoder().encode(v) { UserDefaults.standard.set(data, forKey: key) }
    }
    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Init

    init() {
        xp             = (try? JSONDecoder().decode(Int.self, from: UserDefaults.standard.data(forKey: "gg_xp") ?? Data())) ?? 0
        currentStreak  = (try? JSONDecoder().decode(Int.self, from: UserDefaults.standard.data(forKey: "gg_streak") ?? Data())) ?? 0
        longestStreak  = (try? JSONDecoder().decode(Int.self, from: UserDefaults.standard.data(forKey: "gg_longestStreak") ?? Data())) ?? 0
        totalPledges   = (try? JSONDecoder().decode(Int.self, from: UserDefaults.standard.data(forKey: "gg_pledges") ?? Data())) ?? 0
        lastPledgeDate = UserDefaults.standard.object(forKey: "gg_lastPledge") as? Date
        achievements   = decode([Achievement].self,    key: "gg_achievements") ?? GamificationState.defaultAchievements
        digitalChips   = decode([DigitalChip].self,    key: "gg_chips")        ?? GamificationState.defaultChips
        supplementLog  = decode([SupplementEntry].self, key: "gg_supplements") ?? []
        exerciseLog    = decode([ExerciseEntry].self,   key: "gg_exercise")    ?? []
    }

    static let defaultChips: [DigitalChip] = [
        .init(id: "chip_24h",  name: "24-Hour Chip",  days: 1,   color: "#CD7F32", icon: "🥉"),
        .init(id: "chip_7d",   name: "One Week Chip", days: 7,   color: "#C0C0C0", icon: "🥈"),
        .init(id: "chip_30d",  name: "30-Day Chip",   days: 30,  color: "#FFD700", icon: "🥇"),
        .init(id: "chip_90d",  name: "90-Day Chip",   days: 90,  color: "#E5E4E2", icon: "💎"),
        .init(id: "chip_1yr",  name: "One Year Chip", days: 365, color: "#50C878", icon: "🏆"),
    ]

    static let defaultAchievements: [Achievement] = [
        .init(id: "day_1",              title: "First Day",         desc: "24 hours smoke-free",                  icon: "1.circle.fill",           xpReward: 50),
        .init(id: "day_3",              title: "Peak Survivor",     desc: "Through the hardest 72 hours",         icon: "flame.fill",              xpReward: 75),
        .init(id: "day_7",              title: "One Week Strong",   desc: "Seven days of freedom",                icon: "7.circle.fill",           xpReward: 100),
        .init(id: "day_30",             title: "Month Milestone",   desc: "30 days changed your biology",         icon: "calendar.badge.checkmark",xpReward: 200),
        .init(id: "pledge_3",           title: "Triple Pledge",     desc: "Committed 3 days in a row",            icon: "hand.raised.fill",        xpReward: 30),
        .init(id: "pledge_7",           title: "Week Pledger",      desc: "7 consecutive daily pledges",          icon: "star.fill",               xpReward: 70),
        .init(id: "pledge_30",          title: "Pledge Master",     desc: "30 daily pledges completed",           icon: "crown.fill",              xpReward: 150),
        .init(id: "streak_7",           title: "7-Day Streak",      desc: "7 days without breaking your streak", icon: "bolt.fill",               xpReward: 70),
        .init(id: "streak_30",          title: "30-Day Streak",     desc: "Unstoppable 30-day streak",            icon: "bolt.ring.closed.fill",   xpReward: 150),
        .init(id: "first_craving_beaten",title: "Craving Crusher",  desc: "Logged and beat your first craving",  icon: "shield.fill",             xpReward: 30),
        .init(id: "exercise_1",         title: "First Workout",     desc: "Logged your first exercise session",  icon: "figure.run.circle",       xpReward: 25),
        .init(id: "exercise_7",         title: "Move to Heal",      desc: "7 exercise sessions logged",          icon: "figure.run.circle.fill",  xpReward: 75),
        .init(id: "supplement_7",       title: "Recovery Protocol", desc: "7 supplement check-ins",              icon: "cross.case.fill",         xpReward: 50),
    ]
}
