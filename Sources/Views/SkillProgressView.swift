import SwiftUI

struct SkillUnit: Identifiable {
    let id: String
    let name: String
    let icon: String
    let skills: [(id: String, name: String)]
}

struct SkillProgressView: View {
    @EnvironmentObject var state: AppState

    private let units: [SkillUnit] = [
        SkillUnit(id: "urge", name: "Craving Emergency Kit", icon: "flame.fill", skills: [
            ("breathing-fourSevenEight", "4-7-8 Anti-Craving Breath"),
            ("breathing-boxBreathing", "Box Breathing for Urges"),
            ("breathing-physiologicalSigh", "Physiological Sigh"),
            ("urgeSurf", "Nicotine Urge Surfing"),
            ("iceDive", "Craving Emergency Reset"),
        ]),
        SkillUnit(id: "cognitive", name: "Fighting Smoking Thoughts", icon: "brain.head.profile", skills: [
            ("thoughtDefusion", "Quit-Thought Defusion"),
            ("cognitiveReframe", "Smoking Thought Reframe"),
            ("serial7s", "Craving Bandwidth Steal"),
        ]),
        SkillUnit(id: "body", name: "Withdrawal Body Tools", icon: "figure.mind.and.body", skills: [
            ("bodyScan", "Withdrawal Tension Release"),
            ("sensory", "5-4-3-2-1 Grounding"),
            ("squareTrace", "Craving Calm Trace"),
            ("butterflyTap", "Craving Calm Tap"),
            ("fingerTap", "Craving Redirect"),
        ]),
        SkillUnit(id: "values", name: "Non-Smoker Identity", icon: "heart.fill", skills: [
            ("gratitudeGarden", "Smoke-Free Gratitude"),
            ("affirmationCards", "Quit Affirmations"),
            ("lovingKindness", "Self-Compassion for Quitters"),
            ("visualization", "Smoke-Free Visualization"),
        ]),
        SkillUnit(id: "mind", name: "Withdrawal Awareness", icon: "leaf.fill", skills: [
            ("emotionWheel", "Withdrawal Feeling ID"),
            ("colorBreathing", "Clean Air Breathing"),
            ("mindfulListening", "Craving Interrupt"),
        ]),
        SkillUnit(id: "joy", name: "Life Without Nicotine", icon: "sparkles", skills: [
            ("wordScramble", "Quit Word Scramble"),
            ("safePlaceBuilder", "Smoke-Free Sanctuary"),
            ("joyMapping", "Smoke-Free Joy Map"),
            ("patternMemory", "Impulse Control Training"),
            ("celebrationBreath", "Celebrate Your Quit"),
        ]),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.95, blue: 0.93).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    overviewStats

                    ForEach(units) { unit in
                        unitCard(unit)
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.top, 20)
            }
        }
    }

    var headerSection: some View {
        VStack(spacing: 6) {
            Text("QUIT TOOLKIT")
                .font(.sansRR(10, weight: .bold)).foregroundColor(.rText3).tracking(2)
            Text("Your Anti-Nicotine Arsenal")
                .font(.serif(26, weight: .bold)).foregroundColor(.rText)
            Text("Every technique here fights nicotine addiction from a different angle. Practice makes them automatic when cravings hit.")
                .font(.sansRR(13)).foregroundColor(.rText2)
                .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
        }
    }

    var overviewStats: some View {
        HStack(spacing: 16) {
            statBadge(
                value: "\(state.skillLog.count)",
                label: "Sessions",
                icon: "bolt.fill",
                color: .rAccent
            )
            statBadge(
                value: "\(masteredCount)",
                label: "Mastered",
                icon: "star.fill",
                color: Color(red: 0.92, green: 0.76, blue: 0.22)
            )
            statBadge(
                value: "\(practicedCount)",
                label: "Practiced",
                icon: "checkmark.circle.fill",
                color: Color(red: 0.35, green: 0.75, blue: 0.45)
            )
        }
        .padding(.horizontal, 22)
    }

    func statBadge(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            Text(value).font(.serif(22, weight: .bold)).foregroundColor(.rText)
            Text(label).font(.sansRR(10, weight: .medium)).foregroundColor(.rText3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    var masteredCount: Int {
        allSkillIds.filter { state.skillMasteryLevel($0) == "mastered" }.count
    }

    var practicedCount: Int {
        allSkillIds.filter { state.skillMasteryLevel($0) == "practiced" }.count
    }

    var allSkillIds: [String] {
        units.flatMap { $0.skills.map(\.id) }
    }

    func unitCard(_ unit: SkillUnit) -> some View {
        let unitSkillCounts = unit.skills.map { state.skillPracticeCount($0.id) }
        let unitTotal = unitSkillCounts.reduce(0, +)
        let unitMastered = unit.skills.filter { state.skillMasteryLevel($0.id) == "mastered" }.count

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(unitColor(unit.id).opacity(0.15)).frame(width: 38, height: 38)
                    Image(systemName: unit.icon).font(.system(size: 16)).foregroundColor(unitColor(unit.id))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(unit.name).font(.sansRR(15, weight: .bold)).foregroundColor(.rText)
                    Text("\(unitTotal) sessions total")
                        .font(.sansRR(11)).foregroundColor(.rText3)
                }
                Spacer()
                if unitMastered == unit.skills.count && !unit.skills.isEmpty {
                    Image(systemName: "crown.fill").font(.system(size: 14))
                        .foregroundColor(Color(red: 0.92, green: 0.76, blue: 0.22))
                }
            }

            VStack(spacing: 8) {
                ForEach(unit.skills, id: \.id) { skill in
                    skillRow(skill, unit: unit)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        .padding(.horizontal, 18)
    }

    func skillRow(_ skill: (id: String, name: String), unit: SkillUnit) -> some View {
        let count = state.skillPracticeCount(skill.id)
        let level = state.skillMasteryLevel(skill.id)
        let maxForBar = 7

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(levelColor(level).opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: levelIcon(level))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(levelColor(level))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(skill.name)
                        .font(.sansRR(13, weight: .semibold)).foregroundColor(.rText)
                    Text(level.uppercased())
                        .font(.sansRR(8, weight: .heavy))
                        .foregroundColor(levelColor(level))
                        .padding(.horizontal, 5).padding(.vertical, 2)
                        .background(levelColor(level).opacity(0.12))
                        .clipShape(Capsule())
                }

                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.06)).frame(height: 4)
                        Capsule().fill(levelColor(level))
                            .frame(width: g.size.width * CGFloat(min(count, maxForBar)) / CGFloat(maxForBar), height: 4)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            Text("\(count)")
                .font(.sansRR(13, weight: .bold)).foregroundColor(.rText3).monospacedDigit()
        }
    }

    func unitColor(_ unitId: String) -> Color {
        switch unitId {
        case "urge":      return .rDanger
        case "cognitive":  return Color(red: 0.55, green: 0.45, blue: 0.85)
        case "body":       return Color(red: 0.35, green: 0.75, blue: 0.45)
        case "values":     return Color(red: 0.85, green: 0.45, blue: 0.55)
        case "mind":       return .rAccent
        case "joy":        return .rAmber
        default:           return .rAccent
        }
    }

    func levelColor(_ level: String) -> Color {
        switch level {
        case "mastered":  return Color(red: 0.92, green: 0.76, blue: 0.22)
        case "practiced": return Color(red: 0.35, green: 0.75, blue: 0.45)
        case "learning":  return Color(red: 0.45, green: 0.65, blue: 0.85)
        default:          return Color.black.opacity(0.2)
        }
    }

    func levelIcon(_ level: String) -> String {
        switch level {
        case "mastered":  return "star.fill"
        case "practiced": return "checkmark.circle.fill"
        case "learning":  return "circle.dotted"
        default:          return "circle"
        }
    }
}
