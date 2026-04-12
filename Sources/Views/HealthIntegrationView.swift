import SwiftUI
import HealthKit

struct HealthIntegrationView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var hkManager: HealthKitManager
    @EnvironmentObject var gamification: GamificationState

    @State private var appear = false
    @State private var dailyStepGoal: Double = Double(UserDefaults.standard.integer(forKey: "stepGoal") == 0 ? 10000 : UserDefaults.standard.integer(forKey: "stepGoal"))
    @State private var dailyActiveGoal: Double = Double(UserDefaults.standard.integer(forKey: "activeGoal") == 0 ? 30 : UserDefaults.standard.integer(forKey: "activeGoal"))
    @State private var showGoalEditor = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                headerCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5), value: appear)

                if !hkManager.authorized {
                    authCard
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: appear)
                } else {
                    goalCard
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.08), value: appear)

                    activityCard
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.14), value: appear)

                    healthMetrics
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: appear)

                    hrvCard
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.3), value: appear)

                    sleepCard
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: appear)
                }

                startWorkoutCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.45), value: appear)

                fitnessRecoveryCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: appear)

                Color.clear.frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(Color.rBg.ignoresSafeArea())
        .onAppear {
            hkManager.checkExistingAuth()
            withAnimation { appear = true }
            if hkManager.authorized { Task { await hkManager.fetchAll() } }
        }
    }

    // MARK: - Header

    var headerCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color(red: 0.96, green: 0.30, blue: 0.32))
            VStack(alignment: .leading, spacing: 2) {
                Text("Health & Fitness")
                    .font(.serif(22, weight: .bold)).foregroundColor(.rText)
                Text("Your body's recovery in real data")
                    .font(.sansRR(12)).foregroundColor(.rText3)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    // MARK: - Auth Card

    var authCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 48)).foregroundColor(.rAccent)
            Text("Connect Apple Health")
                .font(.serif(20, weight: .bold)).foregroundColor(.rText)
            Text("See how quitting is improving your heart rate, sleep, and activity in real time. Your data stays private on your device.")
                .font(.sansRR(13)).foregroundColor(.rText2)
                .multilineTextAlignment(.center).lineSpacing(3)
            Button {
                Task { await hkManager.requestAuthorization() }
            } label: {
                Label("Connect Health", systemImage: "heart.fill")
                    .font(.sansRR(15, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Color.rAccent).clipShape(Capsule())
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Goal Card

    var goalCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.rAccent)
                Text("DAILY GOALS")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.rAccent).tracking(1)
                Spacer()
                Button { withAnimation { showGoalEditor.toggle() } } label: {
                    Text(showGoalEditor ? "Done" : "Edit")
                        .font(.sansRR(11, weight: .bold)).foregroundColor(.rAccent)
                }
            }

            if showGoalEditor {
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Step goal: \(Int(dailyStepGoal))")
                            .font(.sansRR(13, weight: .semibold)).foregroundColor(.rText)
                        Slider(value: $dailyStepGoal, in: 2000...20000, step: 1000)
                            .tint(.rAccent)
                            .onChange(of: dailyStepGoal) { _, v in UserDefaults.standard.set(Int(v), forKey: "stepGoal") }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active minutes goal: \(Int(dailyActiveGoal))")
                            .font(.sansRR(13, weight: .semibold)).foregroundColor(.rText)
                        Slider(value: $dailyActiveGoal, in: 10...120, step: 5)
                            .tint(.rAmber)
                            .onChange(of: dailyActiveGoal) { _, v in UserDefaults.standard.set(Int(v), forKey: "activeGoal") }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                HStack(spacing: 16) {
                    goalPill(
                        current: hkManager.stepsToday,
                        goal: Int(dailyStepGoal),
                        label: "Steps",
                        color: .rAccent,
                        icon: "figure.walk"
                    )
                    goalPill(
                        current: hkManager.activeMinutesToday,
                        goal: Int(dailyActiveGoal),
                        label: "Active min",
                        color: .rAmber,
                        icon: "flame.fill"
                    )
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    func goalPill(current: Int, goal: Int, label: String, color: Color, icon: String) -> some View {
        let pct = min(1.0, Double(current) / Double(goal))
        let done = current >= goal
        return VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: done ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(done ? .rAccent : color)
                Text("\(current) / \(goal)")
                    .font(.sansRR(14, weight: .bold)).foregroundColor(.rText).monospacedDigit()
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.rBg2).frame(height: 6)
                    Capsule().fill(done ? Color.rAccent : color).frame(width: g.size.width * pct, height: 6)
                }
            }
            .frame(height: 6)
            Text(label).font(.sansRR(10)).foregroundColor(.rText3)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Start Workout Card

    var startWorkoutCard: some View {
        Button {
            openAppleFitness()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(red: 0.65, green: 1.0, blue: 0.0), Color(red: 0.0, green: 0.85, blue: 0.65)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "figure.run")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(.black)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Start a Workout")
                        .font(.sansRR(15, weight: .bold)).foregroundColor(.rText)
                    Text("Opens Apple Fitness to begin an exercise session")
                        .font(.sansRR(11)).foregroundColor(.rText3)
                }
                Spacer()
                Image(systemName: "arrow.up.forward.square")
                    .font(.system(size: 16)).foregroundColor(.rText3)
            }
            .padding(14)
            .background(Color.white.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    func openAppleFitness() {
        let schemes = [
            "fitness://workout",
            "fitnessapp://",
            "apple-health://browse",
            "x-apple-health://",
        ]
        for scheme in schemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
    }

    // MARK: - Activity Card (Rings-style)

    var activityCard: some View {
        HStack(spacing: 20) {
            // Mini ring display
            ZStack {
                // Steps ring (outer)
                Circle().stroke(Color.rAccent.opacity(0.15), lineWidth: 8).frame(width: 90, height: 90)
                Circle().trim(from: 0, to: min(1.0, CGFloat(hkManager.stepsToday) / CGFloat(dailyStepGoal)))
                    .stroke(Color.rAccent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 90, height: 90).rotationEffect(.degrees(-90))

                // Active minutes ring (inner)
                Circle().stroke(Color.rAmber.opacity(0.15), lineWidth: 8).frame(width: 66, height: 66)
                Circle().trim(from: 0, to: min(1.0, CGFloat(hkManager.activeMinutesToday) / CGFloat(dailyActiveGoal)))
                    .stroke(Color.rAmber, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 66, height: 66).rotationEffect(.degrees(-90))

                Image(systemName: "flame.fill")
                    .font(.system(size: 16)).foregroundColor(.rAmber)
            }

            VStack(alignment: .leading, spacing: 10) {
                activityRow(
                    icon: "figure.walk", color: .rAccent,
                    value: "\(hkManager.stepsToday)", label: "steps today",
                    goal: "/ \(Int(dailyStepGoal))"
                )
                activityRow(
                    icon: "timer", color: .rAmber,
                    value: "\(hkManager.activeMinutesToday)", label: "active min",
                    goal: "/ \(Int(dailyActiveGoal))"
                )
                if let rhr = hkManager.restingHR {
                    activityRow(
                        icon: "heart.fill", color: Color(red: 0.96, green: 0.30, blue: 0.32),
                        value: "\(Int(rhr))", label: "resting HR",
                        goal: "bpm"
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    func activityRow(icon: String, color: Color, value: String, label: String, goal: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 12, weight: .semibold)).foregroundColor(color)
                .frame(width: 16)
            Text(value).font(.sansRR(16, weight: .bold)).foregroundColor(.rText).monospacedDigit()
            Text(label).font(.sansRR(11)).foregroundColor(.rText3)
            Text(goal).font(.sansRR(10)).foregroundColor(.rText3.opacity(0.6))
        }
    }

    // MARK: - Health Metrics

    var healthMetrics: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            metricTile(
                "HRV",
                hkManager.latestHRV.map { "\(Int($0)) ms" } ?? "—",
                "Heart Rate Variability",
                hrvIcon, hrvColor
            )
            metricTile(
                "Sleep",
                hkManager.sleepHoursLast.map { String(format: "%.1fh", $0) } ?? "—",
                "Last Night",
                "moon.fill", .rPurple
            )
            metricTile(
                "Steps",
                "\(hkManager.stepsToday)",
                "Today",
                "figure.walk", .rAccent
            )
            metricTile(
                "Active",
                "\(hkManager.activeMinutesToday) min",
                "Exercise Today",
                "flame.fill", .rAmber
            )
        }
    }

    func metricTile(_ title: String, _ value: String, _ sub: String, _ icon: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
                Text(title).font(.sansRR(10, weight: .bold)).foregroundColor(.rText3).tracking(0.5)
            }
            Text(value).font(.serif(22, weight: .bold)).foregroundColor(.rText).monospacedDigit()
            Text(sub).font(.sansRR(10)).foregroundColor(.rText3)
        }
        .padding(12).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    var hrvIcon: String {
        switch hkManager.hrvTrend {
        case .rising:   return "arrow.up.heart.fill"
        case .dropping: return "arrow.down.heart.fill"
        case .stable:   return "heart.fill"
        }
    }
    var hrvColor: Color {
        switch hkManager.hrvTrend {
        case .rising:   return .rAccent
        case .dropping: return .rDanger
        case .stable:   return Color(red: 0.96, green: 0.30, blue: 0.32)
        }
    }

    // MARK: - HRV Card

    var hrvCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 14)).foregroundColor(hkManager.stressSignalDetected ? .rDanger : .rAccent)
                Text("HRV ANALYSIS")
                    .font(.sansRR(10, weight: .bold))
                    .foregroundColor(hkManager.stressSignalDetected ? .rDanger : .rAccent)
                    .tracking(1)
                Spacer()
                if hkManager.stressSignalDetected {
                    Text("STRESS DETECTED")
                        .font(.sansRR(9, weight: .bold)).foregroundColor(.rDanger)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.rDanger.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if let latest = hkManager.latestHRV, let avg = hkManager.avgHRV7d {
                HStack(spacing: 20) {
                    VStack(spacing: 2) {
                        Text("\(Int(latest))").font(.serif(28, weight: .bold)).foregroundColor(.rText)
                        Text("Latest (ms)").font(.sansRR(10)).foregroundColor(.rText3)
                    }
                    VStack(spacing: 2) {
                        Text("\(Int(avg))").font(.serif(28, weight: .bold)).foregroundColor(.rText2)
                        Text("7d avg (ms)").font(.sansRR(10)).foregroundColor(.rText3)
                    }
                    VStack(spacing: 2) {
                        Text(trendText).font(.serif(16, weight: .bold)).foregroundColor(trendColor)
                        Text("Trend").font(.sansRR(10)).foregroundColor(.rText3)
                    }
                }
            }

            Text(hrvExplanation)
                .font(.sansRR(12)).foregroundColor(.rText2).lineSpacing(3)
        }
        .padding(14)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(
            hkManager.stressSignalDetected ? Color.rDanger.opacity(0.3) : Color.rBg2.opacity(0.8), lineWidth: 1
        ))
    }

    var trendText: String {
        switch hkManager.hrvTrend {
        case .rising: return "↑ Rising"
        case .dropping: return "↓ Dropping"
        case .stable: return "→ Stable"
        }
    }
    var trendColor: Color {
        switch hkManager.hrvTrend {
        case .rising: return .rAccent
        case .dropping: return .rDanger
        case .stable: return .rText2
        }
    }
    var hrvExplanation: String {
        if hkManager.stressSignalDetected {
            return "Your HRV dropped significantly, a physiological sign of stress. This is common during withdrawal. Exercise and deep breathing can restore it."
        }
        return "HRV measures your autonomic nervous system health. Higher HRV = better recovery. Quitting smoking typically improves HRV within 2-4 weeks."
    }

    // MARK: - Sleep Card

    var sleepCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill").font(.system(size: 14)).foregroundColor(.rPurple)
                Text("SLEEP RECOVERY").font(.sansRR(10, weight: .bold)).foregroundColor(.rPurple).tracking(1)
            }
            if let hours = hkManager.sleepHoursLast {
                HStack(spacing: 4) {
                    Text(String(format: "%.1f", hours))
                        .font(.serif(32, weight: .bold)).foregroundColor(.rText)
                    Text("hours last night").font(.sansRR(13)).foregroundColor(.rText2)
                }
                sleepBar(hours)
                Text(sleepAdvice(hours))
                    .font(.sansRR(12)).foregroundColor(.rText2).lineSpacing(3)
            } else {
                Text("No sleep data available yet. Make sure Sleep tracking is enabled in Apple Health.")
                    .font(.sansRR(12)).foregroundColor(.rText3)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    func sleepBar(_ hours: Double) -> some View {
        let pct = min(1.0, hours / 8.0)
        let color: Color = hours >= 7 ? .rAccent : hours >= 5.5 ? .rAmber : .rDanger
        return GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.rBg2).frame(height: 6)
                Capsule().fill(color).frame(width: g.size.width * pct, height: 6)
            }
        }
        .frame(height: 6)
    }

    func sleepAdvice(_ hours: Double) -> String {
        if hours < 5 {
            return "Very low sleep is strongly linked to relapse. Prioritize rest tonight — try melatonin or a wind-down routine 30 min before bed."
        } else if hours < 7 {
            return "Below optimal. Sleep disruption is normal during withdrawal — it improves steadily. Exercise earlier in the day can help."
        }
        return "Good sleep supports recovery. Your brain does most of its neurochemical rebalancing during deep sleep."
    }

    // MARK: - Fitness Recovery Card

    var fitnessRecoveryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "figure.run.circle.fill").font(.system(size: 16)).foregroundColor(.rAccent)
                Text("FITNESS + RECOVERY").font(.sansRR(10, weight: .bold)).foregroundColor(.rAccent).tracking(1)
            }

            VStack(alignment: .leading, spacing: 8) {
                recoveryRow("heart.fill", "Resting heart rate improves within 48 hours of quitting")
                recoveryRow("lungs.fill", "Lung capacity increases 30% in 2-12 weeks")
                recoveryRow("figure.run", "Exercise capacity improves as CO leaves bloodstream")
                recoveryRow("brain.head.profile", "Cardio produces BDNF — accelerates brain healing from nicotine")
                recoveryRow("moon.fill", "Regular exercise improves quit-related sleep disruption")
            }

            Text("SOURCE: American Lung Association, NIDA, British Journal of Sports Medicine")
                .font(.sansRR(9)).foregroundColor(.rText3.opacity(0.5)).italic()
        }
        .padding(16)
        .background(Color.rAccent.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rAccent.opacity(0.12), lineWidth: 1))
    }

    func recoveryRow(_ icon: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(.rAccent).frame(width: 16)
                .padding(.top, 2)
            Text(text).font(.sansRR(12)).foregroundColor(.rText2).lineSpacing(2)
        }
    }
}
