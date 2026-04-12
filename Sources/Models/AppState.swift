import Foundation
import Combine
import SwiftUI

// MARK: - Journal / Mood / Craving models

struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    let mood: Int
    let time: Date
}

struct CravingEntry: Identifiable, Codable {
    var id = UUID()
    let time: Date
}

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    let text: String
    let time: Date
    let mood: Int?
    let dayNum: Int
}

struct FutureMessage: Identifiable, Codable {
    var id = UUID()
    let text: String
    let dayNum: Int
    let date: Date
}

struct LapseEntry: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let count: Int
    let trigger: String
    let plan: String
}

struct SkillEntry: Identifiable, Codable {
    var id = UUID()
    let skillId: String
    let date: Date
}

struct MicroCommitment: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let skillId: String
    let followedThrough: Bool?
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var quitTime: Date?
    @Published var elapsed: TimeInterval = 0
    @Published var demoDayOverride: Double? = nil
    @Published var currentMood: Int? = nil
    @Published var moodLog: [MoodEntry] = []
    @Published var cravingLog: [CravingEntry] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var futureMessages: [FutureMessage] = []
    @Published var lastCheckInDate: Date?
    @Published var lastCheckInMood: Int?

    // Honest reporting
    @Published var userName: String = ""
    @Published var userTriggers: [String] = []
    @Published var quitMotivation: String = ""
    @Published var lapseLog: [LapseEntry] = []
    @Published var todayCravingIntensity: Int = 0
    @Published var todayLapseReported: Bool? = nil

    // Skill mastery
    @Published var skillLog: [SkillEntry] = []
    @Published var microCommitments: [MicroCommitment] = []

    var checkedInToday: Bool {
        guard let d = lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(d)
    }

    func completeCheckIn(mood: Int) {
        lastCheckInMood = mood
        lastCheckInDate = Date()
        UserDefaults.standard.set(lastCheckInDate, forKey: "lastCheckInDate")
        if let data = try? JSONEncoder().encode(mood) {
            UserDefaults.standard.set(data, forKey: "lastCheckInMood")
        }
        objectWillChange.send()
    }

    private var timerCancellable: AnyCancellable?

    var hasStarted: Bool { quitTime != nil }
    var dayNum: Int  { max(1, Int(elapsed / 86400) + 1) }
    var moneySaved: Double { (elapsed / 86400) * 14.50 }
    var cigsAvoided: Int   { Int((elapsed / 86400) * 20) }

    init() {
        if let saved = UserDefaults.standard.object(forKey: "quitTime") as? Date {
            quitTime = saved
            elapsed = Date().timeIntervalSince(saved)
            startTimer()
        }
        loadPersistedData()
    }

    func startQuit(offsetSeconds: TimeInterval = 0) {
        quitTime = Date().addingTimeInterval(-offsetSeconds)
        UserDefaults.standard.set(quitTime, forKey: "quitTime")
        elapsed = offsetSeconds
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, let qt = self.quitTime else { return }
                if let d = self.demoDayOverride {
                    self.elapsed = d * 86400
                } else {
                    self.elapsed = Date().timeIntervalSince(qt)
                }
            }
    }

    func logMood(_ idx: Int) {
        currentMood = idx
        moodLog.append(MoodEntry(mood: idx, time: Date()))
        persist()
    }

    func logCraving() {
        cravingLog.append(CravingEntry(time: Date()))
        persist()
    }

    func saveJournal(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        journalEntries.insert(JournalEntry(text: text, time: Date(), mood: currentMood, dayNum: dayNum), at: 0)
        persist()
    }

    func saveFutureMessage(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        futureMessages.insert(FutureMessage(text: text, dayNum: dayNum, date: Date()), at: 0)
        persist()
    }

    var randomFutureMessage: FutureMessage? { futureMessages.randomElement() }

    // MARK: - Honest Reporting

    func logLapse(count: Int, trigger: String, plan: String) {
        lapseLog.append(LapseEntry(date: Date(), count: count, trigger: trigger, plan: plan))
        persist()
    }

    func logSkillPractice(_ skillId: String) {
        skillLog.append(SkillEntry(skillId: skillId, date: Date()))
        persist()
    }

    func setMicroCommitment(skillId: String) {
        microCommitments.append(MicroCommitment(date: Date(), skillId: skillId, followedThrough: nil))
        persist()
    }

    func skillPracticeCount(_ skillId: String) -> Int {
        skillLog.filter { $0.skillId == skillId }.count
    }

    func skillMasteryLevel(_ skillId: String) -> String {
        let count = skillPracticeCount(skillId)
        if count >= 7 { return "mastered" }
        if count >= 3 { return "practiced" }
        if count >= 1 { return "learning" }
        return "new"
    }

    var honestStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var checkDate = cal.startOfDay(for: Date())
        let sortedMoods = moodLog.sorted { $0.time > $1.time }
        while true {
            let hasEntry = sortedMoods.contains { cal.isDate($0.time, inSameDayAs: checkDate) }
            if hasEntry {
                streak += 1
                checkDate = cal.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }

    var lapsedToday: Bool {
        lapseLog.contains { Calendar.current.isDateInToday($0.date) }
    }

    var daysSinceLastLapse: Int {
        guard let last = lapseLog.sorted(by: { $0.date > $1.date }).first else {
            return dayNum
        }
        return max(0, Int(Date().timeIntervalSince(last.date) / 86400))
    }

    var yesterdayMood: MoodEntry? {
        let cal = Calendar.current
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) else { return nil }
        return moodLog.last { cal.isDate($0.time, inSameDayAs: yesterday) }
    }

    var yesterdayCommitment: MicroCommitment? {
        let cal = Calendar.current
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: Date()) else { return nil }
        return microCommitments.last { cal.isDate($0.date, inSameDayAs: yesterday) }
    }

    var treeHealthScore: Double {
        let abstinence = min(1.0, Double(daysSinceLastLapse) / 30.0) * 0.4
        let skillPts = min(1.0, Double(skillLog.count) / 50.0) * 0.3
        let streakPts = min(1.0, Double(honestStreak) / 14.0) * 0.3
        return abstinence + skillPts + streakPts
    }

    // MARK: - Computed helpers

    var activeSymptoms: [(symptom: Symptom, intensity: Double)] {
        RecoveryData.symptoms.compactMap { sym in
            let i = sym.intensityFn(elapsed)
            return i > 0.02 ? (sym, i) : nil
        }
    }

    var milestones: [(milestone: Milestone, done: Bool, pct: Double)] {
        RecoveryData.milestones.map { m in
            (m, elapsed >= m.time, min(1, elapsed / m.time))
        }
    }

    var nextMilestone: (milestone: Milestone, pct: Double)? {
        milestones.first(where: { !$0.done }).map { ($0.milestone, $0.pct) }
    }

    var rightNow: (title: String, body: String, phase: String) {
        let h = elapsed / 3600
        let d = elapsed / 86400
        switch true {
        case h < 0.5: return ("You just took the first step",    "Your last cigarette is behind you. Within 20 minutes, your heart rate is already starting to calm down. This moment matters.",                                       "start")
        case h < 2:   return ("First cravings may show up",     "Your body is adjusting. Cravings feel big, but they usually pass in just a few minutes. You don't have to fight them. Just let them move through you.",                "early")
        case h < 8:   return ("Your body is already healing",   "With every breath, your blood is getting cleaner. Carbon monoxide is leaving your system. You might not feel it yet, but your body notices.",                          "early")
        case h < 24:  return ("Your brain is finding its balance", "Without nicotine, your brain is recalibrating. If you feel restless or moody, that's normal. It's not a sign of weakness. It's a sign of change.",                 "acute")
        case h < 48:  return ("One full day. That's real.",      "Your lungs are already starting to clear out. Your senses of taste and smell are beginning to wake up. You did something hard today.",                                "acute")
        case h < 72:  return ("Getting through the hardest part", "Day 2-3 can be the toughest stretch. Your nerve endings are literally regrowing. If it feels intense, that means you're healing.",                                   "peak")
        case d < 7:   return ("The worst is behind you",        "Breathing is getting easier. Your body is settling into its new normal. Every day from here gets a little lighter.",                                                   "recovery")
        case d < 14:  return ("One week of freedom",            "Your lung function is measurably improving. Sleep is getting better. The hardest part of quitting is behind you.",                                                     "recovery")
        case d < 30:  return ("Two weeks strong",               "Your circulation has improved. Exercise feels different. Your brain is quietly rewiring itself toward healthier patterns.",                                             "thriving")
        case d < 90:  return ("A month of your new life",       "Your lungs are healing. Coughing is decreasing. Many people at this stage feel less anxious than when they were smoking.",                                             "thriving")
        default:      return ("Look how far you've come",       "Months of freedom. Your heart, your lungs, your mind. They've all been healing. You're not just someone who quit. You're someone who's free.",                         "thriving")
        }
    }

    var phaseColor: Color {
        switch rightNow.phase {
        case "peak":     return .rDanger
        case "acute":    return .rAmber
        case "thriving": return .rAccent
        default:         return .rAccent
        }
    }

    // MARK: - Persistence

    private func persist() {
        encode(moodLog,          key: "moodLog")
        encode(cravingLog,       key: "cravingLog")
        encode(journalEntries,   key: "journalEntries")
        encode(futureMessages,   key: "futureMessages")
        encode(lapseLog,         key: "lapseLog")
        encode(skillLog,         key: "skillLog")
        encode(microCommitments, key: "microCommitments")
    }

    private func loadPersistedData() {
        moodLog          = decode([MoodEntry].self,         key: "moodLog")          ?? []
        cravingLog       = decode([CravingEntry].self,      key: "cravingLog")       ?? []
        journalEntries   = decode([JournalEntry].self,      key: "journalEntries")   ?? []
        futureMessages   = decode([FutureMessage].self,     key: "futureMessages")   ?? []
        lapseLog         = decode([LapseEntry].self,        key: "lapseLog")         ?? []
        skillLog         = decode([SkillEntry].self,        key: "skillLog")         ?? []
        microCommitments = decode([MicroCommitment].self,   key: "microCommitments") ?? []
        lastCheckInDate  = UserDefaults.standard.object(forKey: "lastCheckInDate") as? Date
        lastCheckInMood  = decode(Int.self, key: "lastCheckInMood")
        userName         = UserDefaults.standard.string(forKey: "userName") ?? ""
        userTriggers     = UserDefaults.standard.stringArray(forKey: "userTriggers") ?? []
        quitMotivation   = UserDefaults.standard.string(forKey: "quitMotivation") ?? ""
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) { UserDefaults.standard.set(data, forKey: key) }
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
