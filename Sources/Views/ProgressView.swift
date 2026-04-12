import SwiftUI
import Charts

struct ProgressView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    @State private var selectedChartTab = 0

    private let moods = ["😣","😟","😐","🙂","😊"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // ── Withdrawal Wallet Hero ──
                    ZStack {
                        LinearGradient(colors: [Color.rAccent, Color(red: 0.25, green: 0.44, blue: 0.24)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                        Circle().fill(Color.white.opacity(0.04)).frame(width: 200).offset(x: 80, y: -50)
                        Circle().fill(Color.white.opacity(0.03)).frame(width: 140).offset(x: -60, y: 60)

                        VStack(spacing: 4) {
                            Text("WITHDRAWAL WALLET").font(.sansRR(10, weight: .bold))
                                .foregroundColor(.white.opacity(0.55)).tracking(2)
                            Text("$\(String(format: "%.2f", state.moneySaved))")
                                .font(.serif(52, weight: .heavy)).foregroundColor(.white).monospacedDigit()
                            HStack(spacing: 16) {
                                walletStat("$\(Int(14.50 * 30))", "this month")
                                walletStat("$\(Int(14.50 * 365))", "this year")
                                walletStat("$\(Int(14.50 * 365 * 5))", "5 years")
                            }.padding(.top, 4)
                        }.padding(.vertical, 28)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.rAccent.opacity(0.3), radius: 16, y: 6)

                    // ── Money Saved ──
                    MoneySavedCard()
                        .environmentObject(state)
                        .environmentObject(gamification)

                    // ── Digital Chips ──
                    RRCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(icon: "🏅", title: "Recovery Chips")
                            Text("Based on AA/NA contingency management research — immediate tangible rewards for verified abstinence milestones.")
                                .font(.sansRR(11)).foregroundColor(.rText3).lineSpacing(2)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                                ForEach(gamification.digitalChips) { chip in
                                    DigitalChipView(chip: chip, elapsed: state.elapsed)
                                }
                            }
                        }
                    }

                    // ── Achievement Badges ──
                    RRCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(icon: "🎖️", title: "Achievements")
                            let earned = gamification.achievements.filter(\.isEarned)
                            let pending = gamification.achievements.filter { !$0.isEarned }

                            if !earned.isEmpty {
                                Text("EARNED (\(earned.count))")
                                    .font(.sansRR(9, weight: .bold)).foregroundColor(.rAccent).tracking(1)
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                    ForEach(earned) { a in AchievementBadge(achievement: a, earned: true) }
                                }
                            }

                            if !pending.isEmpty {
                                Text("LOCKED (\(pending.count))")
                                    .font(.sansRR(9, weight: .bold)).foregroundColor(.rText3).tracking(1)
                                    .padding(.top, earned.isEmpty ? 0 : 8)
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                    ForEach(pending.prefix(6)) { a in AchievementBadge(achievement: a, earned: false) }
                                }
                            }
                        }
                    }

                    // ── Swift Charts ──
                    RRCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(icon: "📈", title: "Your Recovery Data")

                            // Tab selector
                            HStack(spacing: 0) {
                                ForEach(["Savings", "Cravings", "Mood"], id: \.self) { tab in
                                    let i = ["Savings","Cravings","Mood"].firstIndex(of: tab)!
                                    Button { withAnimation(.spring(response: 0.3)) { selectedChartTab = i } } label: {
                                        Text(tab)
                                            .font(.sansRR(12, weight: selectedChartTab == i ? .bold : .regular))
                                            .foregroundColor(selectedChartTab == i ? .white : .rText3)
                                            .padding(.vertical, 7)
                                            .frame(maxWidth: .infinity)
                                            .background(selectedChartTab == i ? Color.rAccent : Color.clear)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(3)
                            .background(Color.rBg2)
                            .clipShape(Capsule())

                            switch selectedChartTab {
                            case 0: SavingsChart(elapsed: state.elapsed).frame(height: 180)
                            case 1: CravingsChart(cravingLog: state.cravingLog).frame(height: 180)
                            default: MoodChart(moodLog: state.moodLog).frame(height: 180)
                            }
                        }
                    }

                    // ── Stats Grid ──
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        StatCard(value: "\(state.cigsAvoided)", label: "Cigarettes Avoided", color: .rAmber, icon: "xmark.circle.fill")
                        StatCard(value: "\(state.cravingLog.count)", label: "Cravings Resisted", color: .rPurple, icon: "bolt.shield.fill")
                        StatCard(value: "\(state.dayNum)", label: "Days Smoke-Free", color: .rAccent, icon: "calendar.badge.checkmark")
                        StatCard(value: "\(gamification.exerciseLog.count)", label: "Workouts Logged", color: Color(red: 0.2, green: 0.5, blue: 0.8), icon: "figure.run.circle.fill")
                    }

                    // ── Body Healing Timeline ──
                    RRCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(icon: "🧬", title: "Body Healing Timeline")
                            Text("Every milestone is sourced from peer-reviewed research.")
                                .font(.sansRR(12)).foregroundColor(.rText3)

                            ForEach(state.milestones.indices, id: \.self) { i in
                                let item = state.milestones[i]
                                HStack(alignment: .top, spacing: 12) {
                                    VStack(spacing: 0) {
                                        ZStack {
                                            Circle()
                                                .fill(item.done ? Color.rAccent : (item.pct > 0 ? Color.rAccent.opacity(0.3) : Color.rBg2))
                                                .frame(width: 16, height: 16)
                                            if item.done {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                                            }
                                        }
                                        if i < state.milestones.count - 1 {
                                            Rectangle().fill(Color.rBg2).frame(width: 2, height: 28)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(item.milestone.label)
                                                .font(.sansRR(11, weight: .bold))
                                                .foregroundColor(item.done ? .rAccent : .rText3)
                                            if !item.done && item.pct > 0 {
                                                Text("(\(Int(item.pct * 100))%)")
                                                    .font(.sansRR(10)).foregroundColor(.rAccent.opacity(0.7))
                                            }
                                        }
                                        Text(item.milestone.title)
                                            .font(.sansRR(14, weight: .semibold))
                                            .foregroundColor(item.done ? .rText : .rText2)
                                        Text(item.milestone.body)
                                            .font(.sansRR(12)).foregroundColor(.rText3).lineSpacing(2)
                                        Text(item.milestone.source)
                                            .font(.sansRR(10)).foregroundColor(.rText3.opacity(0.6)).italic()
                                    }.opacity(item.done ? 1 : 0.55)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color.rBg.ignoresSafeArea())
            .navigationTitle("Your Recovery")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    @ViewBuilder
    private func walletStat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.sansRR(14, weight: .bold)).foregroundColor(.white)
            Text(label).font(.sansRR(9)).foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Money Saved Card

struct MoneySavedCard: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState

    var body: some View {
        RRCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Color.rAccent.opacity(0.12)).frame(width: 56, height: 56)
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 24, weight: .semibold)).foregroundColor(.rAccent)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Money Saved")
                            .font(.sansRR(15, weight: .bold)).foregroundColor(.rText)
                        Spacer()
                        Text("$\(String(format: "%.2f", state.moneySaved))")
                            .font(.sansRR(14, weight: .bold)).foregroundColor(.rAccent)
                    }
                    HStack(spacing: 12) {
                        Label("\(state.daysSinceLastLapse) smoke-free days", systemImage: "shield.fill")
                            .font(.sansRR(11)).foregroundColor(.rText3)
                        Spacer()
                        Label("\(gamification.currentStreak)d streak", systemImage: "bolt.fill")
                            .font(.sansRR(11)).foregroundColor(.rText3)
                    }
                }
            }
        }
    }
}

// MARK: - Digital Chip View

struct DigitalChipView: View {
    let chip: DigitalChip
    let elapsed: TimeInterval

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(chip.isEarned ? Color.rAccent.opacity(0.15) : Color.rBg2)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(chip.isEarned ? Color.rAccent : Color.rText3.opacity(0.2), lineWidth: 2))
                if chip.isEarned {
                    Text(chip.icon).font(.system(size: 22))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16)).foregroundColor(.rText3.opacity(0.4))
                }
            }
            Text(chip.name.components(separatedBy: " ").prefix(2).joined(separator: "\n"))
                .font(.sansRR(8, weight: chip.isEarned ? .bold : .regular))
                .foregroundColor(chip.isEarned ? .rText : .rText3)
                .multilineTextAlignment(.center)
                .lineSpacing(1)
        }
        .opacity(chip.isEarned ? 1 : 0.5)
    }
}

// MARK: - Achievement Badge

struct AchievementBadge: View {
    let achievement: Achievement
    let earned: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(earned ? Color.rAccent.opacity(0.12) : Color.rBg2)
                    .frame(height: 54)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                        earned ? Color.rAccent.opacity(0.3) : Color.clear, lineWidth: 1.5
                    ))
                VStack(spacing: 2) {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(earned ? .rAccent : .rText3.opacity(0.3))
                    Text("+\(achievement.xpReward)")
                        .font(.sansRR(8, weight: .bold))
                        .foregroundColor(earned ? .rPurple : .rText3.opacity(0.3))
                }
            }
            Text(achievement.title)
                .font(.sansRR(9, weight: earned ? .semibold : .regular))
                .foregroundColor(earned ? .rText : .rText3)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

// MARK: - Charts

struct SavingsChart: View {
    let elapsed: TimeInterval

    private var dataPoints: [(day: Int, amount: Double)] {
        let totalDays = max(1, Int(elapsed / 86400))
        return stride(from: 0, through: totalDays, by: max(1, totalDays / 10)).map { d in
            (d, Double(d) * 14.50)
        }
    }

    var body: some View {
        Chart(dataPoints, id: \.day) { point in
            AreaMark(x: .value("Day", point.day), y: .value("Saved", point.amount))
                .foregroundStyle(Color.rAccent.opacity(0.15).gradient)
                .interpolationMethod(.catmullRom)
            LineMark(x: .value("Day", point.day), y: .value("Saved", point.amount))
                .foregroundStyle(Color.rAccent.gradient)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) {
                AxisGridLine(stroke: StrokeStyle(dash: [3])).foregroundStyle(Color.rBg2)
                AxisValueLabel { Text("Day").font(.sansRR(9)).foregroundStyle(Color.rText3) }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) {
                AxisGridLine(stroke: StrokeStyle(dash: [3])).foregroundStyle(Color.rBg2)
                AxisValueLabel().font(.sansRR(9)).foregroundStyle(Color.rText3)
            }
        }
    }
}

struct CravingsChart: View {
    let cravingLog: [CravingEntry]

    private var last7Days: [(label: String, count: Int)] {
        (0..<7).reversed().map { offset -> (String, Int) in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let count = cravingLog.filter { Calendar.current.isDate($0.time, inSameDayAs: date) }.count
            let label = offset == 0 ? "Today" : Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
            return (label, count)
        }
    }

    var body: some View {
        if cravingLog.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.xaxis").font(.system(size: 36)).foregroundColor(.rText3)
                Text("Log cravings to see your pattern").font(.sansRR(13)).foregroundColor(.rText3)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(last7Days, id: \.label) { item in
                BarMark(x: .value("Day", item.label), y: .value("Cravings", item.count))
                    .foregroundStyle(item.count > 3 ? Color.rDanger.gradient : Color.rAmber.gradient)
                    .cornerRadius(6)
            }
            .chartXAxis {
                AxisMarks { AxisValueLabel().font(.sansRR(10)).foregroundStyle(Color.rText3) }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) {
                    AxisGridLine(stroke: StrokeStyle(dash: [3])).foregroundStyle(Color.rBg2)
                    AxisValueLabel().font(.sansRR(9)).foregroundStyle(Color.rText3)
                }
            }
        }
    }
}

struct MoodChart: View {
    let moodLog: [MoodEntry]

    private var last7Days: [(label: String, avg: Double)] {
        (0..<7).reversed().map { offset -> (String, Double) in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let entries = moodLog.filter { Calendar.current.isDate($0.time, inSameDayAs: date) }
            let avg = entries.isEmpty ? -1 : entries.map { Double($0.mood) }.reduce(0, +) / Double(entries.count)
            let label = offset == 0 ? "Today" : Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: date) - 1]
            return (label, avg)
        }
    }

    private let moodColors: [Color] = [.rDanger, Color(red: 0.8, green: 0.4, blue: 0.2), .rAmber, .rAccent.opacity(0.7), .rAccent]

    var body: some View {
        if moodLog.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis").font(.system(size: 36)).foregroundColor(.rText3)
                Text("Log your mood to track emotional recovery").font(.sansRR(13)).foregroundColor(.rText3)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            let validDays = last7Days.filter { $0.avg >= 0 }
            Chart(validDays, id: \.label) { item in
                AreaMark(x: .value("Day", item.label), y: .value("Mood", item.avg))
                    .foregroundStyle(Color.rPurple.opacity(0.12).gradient)
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Day", item.label), y: .value("Mood", item.avg))
                    .foregroundStyle(Color.rPurple.gradient)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                PointMark(x: .value("Day", item.label), y: .value("Mood", item.avg))
                    .foregroundStyle(Color.rPurple)
                    .symbolSize(40)
            }
            .chartYScale(domain: 0...4)
            .chartXAxis {
                AxisMarks { AxisValueLabel().font(.sansRR(10)).foregroundStyle(Color.rText3) }
            }
                            .chartYAxis {
                                AxisMarks(position: .leading, values: [0, 1, 2, 3, 4]) { value in
                                    AxisGridLine(stroke: StrokeStyle(dash: [3])).foregroundStyle(Color.rBg2)
                                    AxisValueLabel {
                                        let moods = ["😣","😟","😐","🙂","😊"]
                                        if let i = value.as(Int.self), i >= 0, i < moods.count {
                                            Text(moods[i]).font(.system(size: 10))
                                        }
                                    }
                                }
                            }
        }
    }
}
