import SwiftUI
import Charts

struct WellnessView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var hkManager: HealthKitManager
    @EnvironmentObject var gamification: GamificationState

    @State private var showExerciseSheet = false
    @State private var showSupplementDetail: SupplementInfo?

    var relapseRisk: (score: Double, level: String, color: Color, factors: [String]) {
        computeRelapseRisk()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // ── Relapse Risk Score Card (JITAI Core) ──
                    RelapseRiskCard(risk: relapseRisk)

                    // ── HealthKit HRV Panel ──
                    if hkManager.authorized {
                        HRVPanel()
                            .environmentObject(hkManager)
                    } else {
                        HKAuthCard()
                            .environmentObject(hkManager)
                    }

                    // ── Sleep & Activity ──
                    if hkManager.authorized {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            BiometricCard(
                                icon: "moon.zzz.fill",
                                value: hkManager.sleepHoursLast.map { String(format: "%.1fh", $0) } ?? "—",
                                label: "Sleep Last Night",
                                sub: sleepQuality,
                                color: Color(red: 0.3, green: 0.3, blue: 0.7)
                            )
                            BiometricCard(
                                icon: "figure.walk",
                                value: "\(hkManager.stepsToday)",
                                label: "Steps Today",
                                sub: hkManager.stepsToday >= 8000 ? "Great" : "Keep moving",
                                color: .rAccent
                            )
                            BiometricCard(
                                icon: "bolt.heart.fill",
                                value: hkManager.restingHR.map { "\(Int($0)) bpm" } ?? "—",
                                label: "Resting Heart Rate",
                                sub: "From Apple Health",
                                color: Color(red: 0.8, green: 0.3, blue: 0.3)
                            )
                            BiometricCard(
                                icon: "figure.run",
                                value: "\(hkManager.activeMinutesToday) min",
                                label: "Active Today",
                                sub: hkManager.activeMinutesToday >= 30 ? "Goal reached ✓" : "\(30 - hkManager.activeMinutesToday)m to goal",
                                color: .rAmber
                            )
                        }
                    }

                    // ── Exercise Logging ──
                    RRCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                SectionHeader(icon: "🏃", title: "Exercise Recovery")
                                Spacer()
                                Button { showExerciseSheet = true } label: {
                                    Label("Log", systemImage: "plus.circle.fill")
                                        .font(.sansRR(12, weight: .semibold))
                                        .foregroundColor(.rAccent)
                                }
                            }

                            Text("Aerobic exercise is clinically proven to 'rewire' reward circuits, flood the brain with natural dopamine, and reduce withdrawal symptom severity — particularly anxiety and restlessness.")
                                .font(.sansRR(12))
                                .foregroundColor(.rText2)
                                .lineSpacing(3)

                            // Recent exercises
                            if gamification.exerciseLog.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "figure.run").foregroundColor(.rText3)
                                    Text("No sessions logged yet. Exercise is your best natural dopamine boost.")
                                        .font(.sansRR(12))
                                        .foregroundColor(.rText3)
                                }
                            } else {
                                ForEach(gamification.exerciseLog.suffix(3).reversed()) { entry in
                                    HStack {
                                        Text(exerciseIcon(entry.type)).font(.system(size: 16))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(entry.type).font(.sansRR(13, weight: .semibold)).foregroundColor(.rText)
                                            Text(entry.date.formatted(.relative(presentation: .named)))
                                                .font(.sansRR(11)).foregroundColor(.rText3)
                                        }
                                        Spacer()
                                        Text("\(entry.minutes) min")
                                            .font(.sansRR(12, weight: .bold)).foregroundColor(.rAccent)
                                        Text("+\(entry.minutes > 30 ? 30 : 20) XP")
                                            .font(.sansRR(10, weight: .bold)).foregroundColor(.rPurple)
                                    }
                                }
                            }

                            // Exercise types row
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(exerciseTypes, id: \.0) { type, benefit in
                                        Button { logExercise(type) } label: {
                                            VStack(spacing: 4) {
                                                Text(exerciseIcon(type)).font(.system(size: 18))
                                                Text(type).font(.sansRR(9, weight: .semibold)).foregroundColor(.rText)
                                                Text(benefit).font(.sansRR(8)).foregroundColor(.rText3)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding(10)
                                            .frame(width: 72)
                                            .background(Color.rBg2.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Supplement Tracker ──
                    RRCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(icon: "💊", title: "Wellness Tracker")
                            Text("These non-prescription supplements are tracked by some people in recovery. Research suggests potential benefits. Always consult a doctor before starting anything new.")
                                .font(.sansRR(11))
                                .foregroundColor(.rText3)
                                .lineSpacing(2)
                                .padding(.bottom, 2)

                            let takenToday = gamification.supplementsTakenToday()
                            ForEach(GamificationState.availableSupplements) { supp in
                                HStack(spacing: 12) {
                                    Image(systemName: supp.icon)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(supp.color)
                                        .frame(width: 26)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(supp.name)
                                            .font(.sansRR(13, weight: .semibold))
                                            .foregroundColor(.rText)
                                        Text(supp.shortDesc)
                                            .font(.sansRR(11))
                                            .foregroundColor(.rText3)
                                    }

                                    Spacer()

                                    // Info button
                                    Button { showSupplementDetail = supp } label: {
                                        Image(systemName: "info.circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.rText3)
                                    }

                                    // Check-in button
                                    Button {
                                        gamification.logSupplement(supp.id)
                                    } label: {
                                        Image(systemName: takenToday.contains(supp.id) ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 22))
                                            .foregroundColor(takenToday.contains(supp.id) ? supp.color : .rText3)
                                    }
                                    .disabled(takenToday.contains(supp.id))
                                }
                                if supp.id != GamificationState.availableSupplements.last?.id {
                                    Divider().background(Color.rBg2)
                                }
                            }
                        }
                    }

                    // ── Dopamine Recovery Nutrition ──
                    RRCard {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(icon: "🥗", title: "Dopamine Recovery Nutrition")
                            Text("Nicotine dysregulated your brain's dopamine system. Foods rich in Tyrosine — the amino acid precursor to dopamine — can support natural recovery.")
                                .font(.sansRR(12))
                                .foregroundColor(.rText2)
                                .lineSpacing(3)

                            let foods: [(emoji: String, name: String, benefit: String)] = [
                                ("🍗", "Turkey & Chicken",   "Highest Tyrosine source"),
                                ("🥚", "Eggs",               "Tyrosine + B12 + Choline"),
                                ("🫘", "Edamame & Soy",      "Plant-based Tyrosine"),
                                ("🐟", "Salmon",             "Omega-3 + mood support"),
                                ("🫐", "Blueberries",        "Antioxidants + BDNF"),
                                ("🌰", "Almonds",            "Magnesium + healthy fats"),
                            ]

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(foods, id: \.name) { food in
                                    HStack(spacing: 8) {
                                        Text(food.emoji).font(.system(size: 22))
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(food.name)
                                                .font(.sansRR(12, weight: .semibold))
                                                .foregroundColor(.rText)
                                            Text(food.benefit)
                                                .font(.sansRR(10))
                                                .foregroundColor(.rText3)
                                        }
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.rBg2.opacity(0.4))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
            .navigationTitle("Wellness")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showExerciseSheet) {
                ExerciseLogSheet(isPresented: $showExerciseSheet)
                    .environmentObject(gamification)
            }
            .sheet(item: $showSupplementDetail) { supp in
                SupplementDetailSheet(supplement: supp)
            }
        }
    }

    // MARK: - Helpers

    private var sleepQuality: String {
        guard let h = hkManager.sleepHoursLast else { return "No data" }
        if h >= 7.5 { return "Excellent ✓" }
        if h >= 6   { return "Adequate" }
        if h >= 5   { return "⚠ Low" }
        return "⚠ Very Low"
    }

    private func logExercise(_ type: String) {
        gamification.logExercise(type: type, minutes: 30)
        gamification.checkAchievements(elapsed: state.elapsed)
    }

    private let exerciseTypes: [(String, String)] = [
        ("Walk",     "Stress\nrelief"),
        ("Run",      "Dopamine\nboost"),
        ("Cycling",  "Lung\nrecovery"),
        ("Yoga",     "Calms\nANS"),
        ("HIIT",     "Endorphin\nreset"),
        ("Swim",     "Full\nbody"),
    ]

    private func exerciseIcon(_ type: String) -> String {
        switch type {
        case "Walk":    return "🚶"
        case "Run":     return "🏃"
        case "Cycling": return "🚴"
        case "Yoga":    return "🧘"
        case "HIIT":    return "⚡"
        case "Swim":    return "🏊"
        default:        return "💪"
        }
    }

    // MARK: - Relapse Risk Computation

    func computeRelapseRisk() -> (score: Double, level: String, color: Color, factors: [String]) {
        var score = 0.0
        var factors: [String] = []

        let days = state.elapsed / 86400

        // 1. Time-based withdrawal vulnerability
        if days < 1 {
            score += 0.30; factors.append("First 24 hours — peak difficulty")
        } else if days < 3 {
            score += 0.30; factors.append("Days 1–3 — peak withdrawal intensity")
        } else if days < 7 {
            score += 0.15; factors.append("First week — elevated risk period")
        }

        // 2. Recent low mood
        if let lastMood = state.moodLog.last, lastMood.mood < 2 {
            score += 0.20; factors.append("Low mood recently logged")
        }

        // 3. HealthKit biometrics
        if hkManager.stressSignalDetected {
            score += 0.20; factors.append("HRV stress signal detected from Apple Health")
        }
        if let sleep = hkManager.sleepHoursLast, sleep < 6 {
            score += 0.15; factors.append("Sleep under 6 hours last night")
        }
        if hkManager.activeMinutesToday < 10 && state.elapsed > 86400 {
            score += 0.08; factors.append("Low activity today")
        }

        // 4. No pledge today
        if !gamification.pledgedToday && state.elapsed > 3600 {
            score += 0.10; factors.append("Daily pledge not yet made")
        }

        // 5. No exercise recently
        if gamification.exerciseLog.isEmpty ||
           (Date().timeIntervalSince(gamification.exerciseLog.last?.date ?? Date.distantPast) > 3 * 86400) {
            score += 0.07; factors.append("No exercise in the last 3 days")
        }

        let final = min(score, 1.0)
        let level: String
        let color: Color
        switch final {
        case 0..<0.25: level = "Low"; color = .rAccent
        case 0.25..<0.5: level = "Moderate"; color = .rAmber
        case 0.5..<0.75: level = "High"; color = Color(red: 0.8, green: 0.4, blue: 0.1)
        default: level = "Critical"; color = .rDanger
        }

        return (final, level, color, factors)
    }
}

// MARK: - Relapse Risk Card

struct RelapseRiskCard: View {
    let risk: (score: Double, level: String, color: Color, factors: [String])
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                // Arc gauge
                ZStack {
                    Circle().trim(from: 0.15, to: 0.85)
                        .stroke(Color.rBg2, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(90 + 0.15 * 360))

                    Circle().trim(from: 0.15, to: 0.15 + 0.70 * risk.score)
                        .stroke(risk.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(90 + 0.15 * 360))
                        .animation(.easeOut(duration: 1.2), value: risk.score)

                    VStack(spacing: 0) {
                        Text("\(Int(risk.score * 100))%")
                            .font(.serif(14, weight: .bold))
                            .foregroundColor(risk.color)
                        Text("risk")
                            .font(.sansRR(9))
                            .foregroundColor(.rText3)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("RELAPSE RISK SCORE")
                            .font(.sansRR(9, weight: .bold))
                            .foregroundColor(.rText3)
                            .tracking(0.8)
                        Spacer()
                        Text(risk.level)
                            .font(.sansRR(11, weight: .bold))
                            .foregroundColor(risk.color)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(risk.color.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Text(riskMessage(risk.level))
                        .font(.sansRR(12))
                        .foregroundColor(.rText2)
                        .lineSpacing(2)
                }
            }

            if !risk.factors.isEmpty {
                Button { withAnimation(.spring(response: 0.3)) { expanded.toggle() } } label: {
                    HStack(spacing: 4) {
                        Text("Contributing factors (\(risk.factors.count))")
                            .font(.sansRR(11, weight: .semibold))
                            .foregroundColor(.rText3)
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.rText3)
                    }
                }

                if expanded {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(risk.factors, id: \.self) { f in
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(risk.color)
                                Text(f)
                                    .font(.sansRR(12))
                                    .foregroundColor(.rText2)
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .padding(16)
        .background(risk.color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(risk.color.opacity(0.2), lineWidth: 1))
    }

    func riskMessage(_ level: String) -> String {
        switch level {
        case "Low":      return "You're in a stable window. Maintain your routine and keep that streak alive."
        case "Moderate": return "Some risk factors present. Consider a breathing exercise or quick check-in."
        case "High":     return "Multiple risk factors active. Your app is nudging you to take action now."
        default:         return "Critical factors detected. Use the SOS button or call SAMHSA: 1-800-662-4357."
        }
    }
}

// MARK: - HRV Panel

struct HRVPanel: View {
    @EnvironmentObject var hkManager: HealthKitManager

    var body: some View {
        RRCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionHeader(icon: "❤️", title: "Heart Rate Variability")
                    Spacer()
                    if hkManager.stressSignalDetected {
                        Label("Stress signal", systemImage: "exclamationmark.triangle.fill")
                            .font(.sansRR(10, weight: .bold))
                            .foregroundColor(.rDanger)
                    } else {
                        HStack(spacing: 4) {
                            Circle().fill(Color.rAccent).frame(width: 6, height: 6)
                            Text("Normal").font(.sansRR(10, weight: .bold)).foregroundColor(.rAccent)
                        }
                    }
                }

                Text("HRV (SDNN) measures autonomic nervous system balance. A sudden drop often signals a physiological stress response — which frequently precedes a craving.")
                    .font(.sansRR(12))
                    .foregroundColor(.rText2)
                    .lineSpacing(3)

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("CURRENT").font(.sansRR(9, weight: .bold)).foregroundColor(.rText3).tracking(0.8)
                        Text(hkManager.latestHRV.map { "\(Int($0)) ms" } ?? "—")
                            .font(.serif(28, weight: .bold))
                            .foregroundColor(hkManager.stressSignalDetected ? .rDanger : .rAccent)
                    }
                    Divider().frame(height: 36)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("7-DAY AVG").font(.sansRR(9, weight: .bold)).foregroundColor(.rText3).tracking(0.8)
                        Text(hkManager.avgHRV7d.map { "\(Int($0)) ms" } ?? "—")
                            .font(.serif(28, weight: .bold))
                            .foregroundColor(.rText)
                    }
                    Divider().frame(height: 36)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("TREND").font(.sansRR(9, weight: .bold)).foregroundColor(.rText3).tracking(0.8)
                        HStack(spacing: 4) {
                            Image(systemName: trendIcon)
                            Text(trendLabel)
                        }
                        .font(.sansRR(13, weight: .semibold))
                        .foregroundColor(trendColor)
                    }
                }

                // Mini chart
                if hkManager.recentHRV.count > 2 {
                    Chart(hkManager.recentHRV.suffix(14).reversed()) { sample in
                        LineMark(
                            x: .value("Time", sample.date),
                            y: .value("HRV", sample.value)
                        )
                        .foregroundStyle(Color.rAccent.gradient)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Time", sample.date),
                            y: .value("HRV", sample.value)
                        )
                        .foregroundStyle(Color.rAccent.opacity(0.08).gradient)
                        .interpolationMethod(.catmullRom)
                    }
                    .frame(height: 80)
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) {
                            AxisGridLine(stroke: StrokeStyle(dash: [3])).foregroundStyle(Color.rBg2)
                            AxisValueLabel().font(.sansRR(9)).foregroundStyle(Color.rText3)
                        }
                    }
                }

                if hkManager.stressSignalDetected {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.rDanger)
                        Text("Stress signal detected — your HRV is below your 7-day baseline. Consider a breathing exercise now.")
                            .font(.sansRR(12))
                            .foregroundColor(.rDanger)
                    }
                    .padding(10)
                    .background(Color.rDanger.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    var trendIcon: String {
        switch hkManager.hrvTrend {
        case .rising:   return "arrow.up.right"
        case .dropping: return "arrow.down.right"
        case .stable:   return "arrow.right"
        }
    }
    var trendLabel: String {
        switch hkManager.hrvTrend {
        case .rising:   return "Improving"
        case .dropping: return "Declining"
        case .stable:   return "Stable"
        }
    }
    var trendColor: Color {
        switch hkManager.hrvTrend {
        case .rising:   return .rAccent
        case .dropping: return .rDanger
        case .stable:   return .rAmber
        }
    }
}

// MARK: - HKAuth Card

struct HKAuthCard: View {
    @EnvironmentObject var hkManager: HealthKitManager

    var body: some View {
        RRCard {
            VStack(spacing: 14) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color(red: 0.85, green: 0.2, blue: 0.2))

                VStack(spacing: 6) {
                    Text("Connect Apple Health")
                        .font(.sansRR(17, weight: .bold)).foregroundColor(.rText)
                    Text("ReRoot reads your HRV (Heart Rate Variability) and sleep data to detect stress signals before cravings escalate — a technique called a Just-In-Time Adaptive Intervention (JITAI).")
                        .font(.sansRR(13)).foregroundColor(.rText2)
                        .multilineTextAlignment(.center).lineSpacing(3)
                }

                Button {
                    Task { await hkManager.requestAuthorization() }
                } label: {
                    Label("Connect Apple Health", systemImage: "heart.fill")
                        .font(.sansRR(15, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(Color(red: 0.85, green: 0.2, blue: 0.2))
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0.85, green: 0.2, blue: 0.2).opacity(0.3), radius: 8, y: 3)
                }

                Text("All health data is processed on-device only. ReRoot never uploads your biometrics.")
                    .font(.sansRR(10)).foregroundColor(.rText3)
                    .multilineTextAlignment(.center).italic()
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Biometric Card

struct BiometricCard: View {
    let icon: String; let value: String; let label: String; let sub: String; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundColor(color)
            Text(value).font(.serif(22, weight: .bold)).foregroundColor(.rText).monospacedDigit()
            Text(label).font(.sansRR(11)).foregroundColor(.rText3)
            Text(sub).font(.sansRR(10, weight: .semibold)).foregroundColor(color)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

// MARK: - Exercise Log Sheet

struct ExerciseLogSheet: View {
    @EnvironmentObject var gamification: GamificationState
    @Binding var isPresented: Bool
    @State private var selectedType = "Walk"
    @State private var minutes = 30
    @State private var notes = ""

    private let types = ["Walk", "Run", "Cycling", "Yoga", "HIIT", "Swim", "Strength", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { Text($0) }
                    }.pickerStyle(.menu)
                }
                Section("Duration") {
                    Stepper("\(minutes) minutes", value: $minutes, in: 5...180, step: 5)
                }
                Section("Notes (optional)") {
                    TextField("How did it feel?", text: $notes)
                }
                Section {
                    Text("+\(minutes > 30 ? 30 : 20) XP")
                        .font(.sansRR(14, weight: .bold))
                        .foregroundColor(.rPurple)
                }
            }
            .navigationTitle("Log Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        gamification.logExercise(type: selectedType, minutes: minutes, notes: notes)
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Supplement Detail Sheet

struct SupplementDetailSheet: View {
    let supplement: SupplementInfo
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Capsule().fill(Color.rText3.opacity(0.3)).frame(width: 40, height: 4)
                    .frame(maxWidth: .infinity).padding(.top, 14)

                HStack(spacing: 14) {
                    Image(systemName: supplement.icon)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(supplement.color)
                        .frame(width: 52, height: 52)
                        .background(supplement.color.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(supplement.name)
                            .font(.serif(24, weight: .bold)).foregroundColor(.rText)
                        Text(supplement.category)
                            .font(.sansRR(11, weight: .bold))
                            .foregroundColor(supplement.color)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(supplement.color.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("RESEARCH NOTES")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.rText3).tracking(1)
                    Text(supplement.research)
                        .font(.sansRR(13)).foregroundColor(.rText).lineSpacing(4)
                }
                .padding(14)
                .background(Color.rBg2.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.rAmber)
                    Text("This is general wellness information, not medical advice. Consult your doctor before starting any supplement, especially if taking prescription medications for cessation.")
                        .font(.sansRR(11)).foregroundColor(.rText2).lineSpacing(3)
                }
                .padding(12)
                .background(Color.rAmber.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.rBg.ignoresSafeArea())
    }
}
