import SwiftUI
import MapKit
import CoreLocation

struct StatsQuoteView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    @EnvironmentObject var hkManager: HealthKitManager

    @State private var appear = false
    @State private var showSources = false
    @State private var tick = false
    @State private var showNearbyHelp = false
    @StateObject private var nearbyManager = NearbyHelpLocationManager()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                heroCard
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 12)
                    .animation(.easeOut(duration: 0.5), value: appear)

                quoteCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.08), value: appear)

                statsGrid
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.14), value: appear)

                recoveryInsightCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.17), value: appear)

                rightNowCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.20), value: appear)

                emergencyHelpCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.23), value: appear)

                nearestCenterCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.25), value: appear)

                if let (ms, pct) = state.nextMilestone {
                    milestoneCard(ms, pct)
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.26), value: appear)
                }

                milestoneTimeline
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.30), value: appear)

                sourcesButton
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.34), value: appear)

                Color.clear.frame(height: 80)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(Color.rBg.ignoresSafeArea())
        .onAppear {
            withAnimation { appear = true }
            let status = nearbyManager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                nearbyManager.startLocating()
            }
        }
        .sheet(isPresented: $showSources) {
            SourcesView()
        }
        .sheet(isPresented: $showNearbyHelp) {
            NearbyHelpView(locManager: nearbyManager)
        }
    }

    // MARK: - Sources Button

    var sourcesButton: some View {
        Button { showSources = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.rAccent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sources & References")
                        .font(.sansRR(13, weight: .bold))
                        .foregroundColor(.rText)
                    Text("Scientific, quote, and activity citations")
                        .font(.sansRR(10))
                        .foregroundColor(.rText3)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.rText3)
            }
            .padding(14)
            .background(Color.white.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
            .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hero Timer Card

    var heroCard: some View {
        VStack(spacing: 6) {
            Text("SMOKE-FREE FOR")
                .font(.sansRR(9, weight: .bold))
                .foregroundColor(.white.opacity(0.4)).tracking(2)

            // Big primary number
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(timerBig)
                    .font(.serif(54, weight: .heavy)).foregroundColor(.white)
                    .monospacedDigit().contentTransition(.numericText())
                Text(timerUnit)
                    .font(.sansRR(18, weight: .medium)).foregroundColor(.white.opacity(0.5))
            }

            // Live ticking time breakdown
            let _ = tick
            Text(liveTimeString)
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.55))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: liveTimeString)
                .padding(.top, 2)

            weeklyCheckInRow
                .padding(.top, 8)

            // Pledge badge
            HStack(spacing: 8) {
                Image(systemName: gamification.pledgedToday ? "checkmark.seal.fill" : "hand.raised.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(gamification.pledgedToday
                        ? Color(red: 0.45, green: 0.78, blue: 0.45)
                        : .white.opacity(0.35))
                Text(gamification.pledgedToday
                    ? "Today's pledge: locked in"
                    : "Pledge during your next check-in")
                    .font(.sansRR(14, weight: .bold))
                    .foregroundColor(gamification.pledgedToday ? .white.opacity(0.8) : .white.opacity(0.4))
                if gamification.currentStreak > 0 {
                    Text("\(gamification.currentStreak)d")
                        .font(.sansRR(11, weight: .bold)).foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Color.white.opacity(0.10)).clipShape(Capsule())
                }
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            LinearGradient(
                colors: [Color.rDark, Color(red: 0.20, green: 0.18, blue: 0.16)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            withAnimation { tick.toggle() }
        }
    }

    // MARK: - Weekly Check-In Row

    private var weeklyCheckInRow: some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let sundayOffset = -(weekday - 1)
        let sunday = cal.date(byAdding: .day, value: sundayOffset, to: today)!

        let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]
        let checkedInDays: Set<Int> = {
            var set = Set<Int>()
            for offset in 0..<7 {
                let day = cal.date(byAdding: .day, value: offset, to: sunday)!
                let hasEntry = state.moodLog.contains { cal.isDate($0.time, inSameDayAs: day) }
                if hasEntry { set.insert(offset) }
            }
            return set
        }()
        let todayOffset = cal.dateComponents([.day], from: sunday, to: today).day ?? 0

        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                let isToday = i == todayOffset
                let checked = checkedInDays.contains(i)
                let isFuture = i > todayOffset

                VStack(spacing: 4) {
                    Text(dayLetters[i])
                        .font(.sansRR(9, weight: .bold))
                        .foregroundColor(isToday ? .white : .white.opacity(0.35))

                    ZStack {
                        Circle()
                            .fill(checked ? Color(red: 0.45, green: 0.78, blue: 0.45) :
                                    (isToday ? Color.white.opacity(0.15) : Color.white.opacity(0.06)))
                            .frame(width: 28, height: 28)

                        if isToday && !checked {
                            Circle()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                                .frame(width: 28, height: 28)
                        }

                        if checked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else if isFuture {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Daily Quote (25 quotes, mood-aware)

    var quoteCard: some View {
        let q = dailyQuote
        return VStack(spacing: 12) {
            Text("\u{201C}")
                .font(.serif(52, weight: .heavy)).foregroundColor(.rAccent.opacity(0.15))
                .frame(height: 24)
            Text(q.text)
                .font(.serif(16, weight: .semibold)).foregroundColor(.rText)
                .multilineTextAlignment(.center).lineSpacing(5)
            Text("— \(q.author)")
                .font(.sansRR(11)).foregroundColor(.rText3).italic()
            Text("Source: \(q.source)")
                .font(.sansRR(9)).foregroundColor(.rText3.opacity(0.5)).italic()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.rAccent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rAccent.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Stats Grid

    var statsGrid: some View {
        HStack(spacing: 10) {
            statTile("$\(String(format: "%.2f", state.moneySaved))", "Money Saved", "dollarsign.circle.fill", .rAccent)
            statTile("\(state.daysSinceLastLapse)", "Smoke-Free Days", "shield.fill", Color(red: 0.35, green: 0.75, blue: 0.45))
            statTile(formatStreakDays, "Streak", "bolt.fill", Color(red: 0.92, green: 0.60, blue: 0.15))
        }
    }

    func statTile(_ value: String, _ label: String, _ icon: String, _ color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold)).foregroundColor(color)
            Text(value)
                .font(.serif(20, weight: .bold)).foregroundColor(.rText).monospacedDigit()
            Text(label)
                .font(.sansRR(10)).foregroundColor(.rText3)
                .multilineTextAlignment(.center).lineLimit(2)
        }
        .padding(.vertical, 14).padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }

    var formatStreakDays: String {
        let s = gamification.currentStreak
        return s == 0 ? "Start today" : "\(s) days"
    }

    // MARK: - Right Now

    var rightNowCard: some View {
        let rn = state.rightNow
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle().fill(state.phaseColor).frame(width: 8, height: 8)
                    .shadow(color: state.phaseColor, radius: 4)
                Text("RIGHT NOW \u{00B7} HOUR \(Int(state.elapsed / 3600))")
                    .font(.sansRR(10, weight: .bold))
                    .foregroundColor(state.phaseColor).tracking(1)
            }
            Text(rn.title).font(.serif(18, weight: .bold)).foregroundColor(.rText)
            Text(rn.body).font(.sansRR(13)).foregroundColor(.rText2).lineSpacing(3)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(state.phaseColor.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(state.phaseColor.opacity(0.18), lineWidth: 1))
    }

    // MARK: - Recovery Insight

    var recoveryInsightCard: some View {
        Group {
            if let insight = gamification.recoveryInsight(for: state) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill").font(.system(size: 12)).foregroundColor(.rAmber)
                    Text(insight).font(.sansRR(12)).foregroundColor(.rText2).lineSpacing(3)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.rAmber.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rAmber.opacity(0.15), lineWidth: 1))
            }
        }
    }

    // MARK: - Milestone

    func milestoneCard(_ ms: Milestone, _ pct: Double) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle().stroke(Color.rBg2, lineWidth: 5).frame(width: 52, height: 52)
                Circle().trim(from: 0, to: pct)
                    .stroke(Color.rAccent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 52, height: 52).rotationEffect(.degrees(-90))
                Text("\(Int(pct * 100))%")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.rAccent)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("NEXT \u{00B7} \(ms.label)")
                    .font(.sansRR(9, weight: .bold)).foregroundColor(.rAccent).tracking(0.5)
                Text(ms.title).font(.sansRR(14, weight: .semibold)).foregroundColor(.rText)
                Text(ms.body).font(.sansRR(11)).foregroundColor(.rText2).lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    // MARK: - Milestone Timeline

    var milestoneTimeline: some View {
        let all = state.milestones
        let achieved = all.filter { $0.done }
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill").font(.system(size: 14))
                    .foregroundColor(Color(red: 0.92, green: 0.76, blue: 0.22))
                Text("RECOVERY MILESTONES")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.rText2).tracking(1)
                Spacer()
                Text("\(achieved.count)/\(all.count)")
                    .font(.sansRR(11, weight: .bold)).foregroundColor(.rText3)
            }

            ForEach(Array(all.enumerated()), id: \.offset) { idx, item in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(item.done ? Color.rAccent : Color.rBg2)
                            .frame(width: 28, height: 28)
                        if item.done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                        } else {
                            Text("\(Int(item.pct * 100))%")
                                .font(.sansRR(7, weight: .bold)).foregroundColor(.rText3)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(item.milestone.label)
                                .font(.sansRR(10, weight: .bold)).foregroundColor(item.done ? .rAccent : .rText3)
                            Text(item.milestone.title)
                                .font(.sansRR(12, weight: .semibold)).foregroundColor(item.done ? .rText : .rText3)
                        }
                        if item.done && idx == achieved.count - 1 {
                            Text("Most recent achievement")
                                .font(.sansRR(9, weight: .bold))
                                .foregroundColor(Color(red: 0.92, green: 0.76, blue: 0.22))
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    // MARK: - Emergency Help Card

    var emergencyHelpCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.red.opacity(0.12)).frame(width: 42, height: 42)
                    Image(systemName: "phone.arrow.up.right.fill")
                        .font(.system(size: 18)).foregroundColor(.red)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Need help right now?")
                        .font(.sansRR(14, weight: .bold)).foregroundColor(.rText)
                    Text("Free, confidential support 24/7")
                        .font(.sansRR(11)).foregroundColor(.rText3)
                }
                Spacer()
            }
            .padding(.bottom, 12)

            HStack(spacing: 8) {
                helpButton(
                    icon: "phone.fill",
                    title: "1-800-\nQUIT-NOW",
                    subtitle: "Quitline",
                    fg: .white, bg: Color.rAccent,
                    action: { if let u = URL(string: "tel://18007848669") { UIApplication.shared.open(u) } }
                )
                helpButton(
                    icon: "heart.fill",
                    title: "988",
                    subtitle: "Crisis Line",
                    fg: .white, bg: .red,
                    action: { if let u = URL(string: "tel://988") { UIApplication.shared.open(u) } }
                )
                helpButton(
                    icon: "message.fill",
                    title: "Text QUIT",
                    subtitle: "to 741741",
                    fg: .rText, bg: Color.rBg2,
                    action: { if let u = URL(string: "sms:741741&body=QUIT") { UIApplication.shared.open(u) } }
                )
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.15), lineWidth: 1))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }

    private func helpButton(icon: String, title: String, subtitle: String, fg: Color, bg: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 13))
                Text(title)
                    .font(.sansRR(11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(subtitle)
                    .font(.sansRR(9)).opacity(0.7)
            }
            .foregroundColor(fg)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(bg).clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Nearest Center Card

    var nearestCenterCard: some View {
        Group {
            if let place = nearbyManager.closestPlace {
                Button { showNearbyHelp = true } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 16)).foregroundColor(.blue)
                            Text("NEAREST SUPPORT")
                                .font(.sansRR(9, weight: .bold)).foregroundColor(.blue).tracking(1)
                            Spacer()
                            Text(place.distanceText)
                                .font(.sansRR(12, weight: .bold)).foregroundColor(.rAccent)
                        }

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(place.name)
                                    .font(.sansRR(14, weight: .bold)).foregroundColor(.rText)
                                    .lineLimit(1)
                                Text(place.address)
                                    .font(.sansRR(11)).foregroundColor(.rText3)
                                    .lineLimit(1)
                            }
                            Spacer()

                            if let route = nearbyManager.route {
                                VStack(spacing: 2) {
                                    Text("\(Int(route.expectedTravelTime / 60))")
                                        .font(.serif(20, weight: .bold)).foregroundColor(.blue)
                                    Text("min drive")
                                        .font(.sansRR(9)).foregroundColor(.rText3)
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            Button {
                                place.mapItem.openInMaps(launchOptions: [
                                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                                ])
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                        .font(.system(size: 10))
                                    Text("Directions")
                                        .font(.sansRR(11, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(Color.blue).clipShape(Capsule())
                            }

                            if let phone = place.phone, !phone.isEmpty {
                                Button {
                                    let cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
                                    if let url = URL(string: "tel://\(cleaned)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "phone.fill").font(.system(size: 10))
                                        Text("Call").font(.sansRR(11, weight: .semibold))
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(Color.blue.opacity(0.1)).clipShape(Capsule())
                                }
                            }

                            Spacer()

                            HStack(spacing: 4) {
                                Text("See all")
                                    .font(.sansRR(11, weight: .semibold)).foregroundColor(.rText3)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 9, weight: .bold)).foregroundColor(.rText3)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.blue.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.15), lineWidth: 1))
                    .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
                }
                .buttonStyle(.plain)
            } else if nearbyManager.isSearching {
                HStack(spacing: 10) {
                    ProgressView().tint(.blue)
                    Text("Finding support centers near you...")
                        .font(.sansRR(12)).foregroundColor(.rText3)
                    Spacer()
                }
                .padding(14)
                .background(Color.white.opacity(0.78))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else if nearbyManager.authorizationStatus == .notDetermined {
                Button {
                    nearbyManager.requestPermission()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 20)).foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Find support near you")
                                .font(.sansRR(13, weight: .bold)).foregroundColor(.rText)
                            Text("Tap to enable location and find nearby help centers")
                                .font(.sansRR(11)).foregroundColor(.rText3)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(.rText3)
                    }
                    .padding(14)
                    .background(Color.blue.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.blue.opacity(0.15), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Quote Pool (25 quotes)

    struct DailyQuote { let text: String; let author: String; let source: String }

    var dailyQuote: DailyQuote {
        let pool: [DailyQuote] = [
            .init(text: "The secret of getting ahead is getting started.", author: "Mark Twain", source: "Attributed, widely quoted"),
            .init(text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", source: "Analects of Confucius"),
            .init(text: "You are stronger than your strongest craving.", author: "Recovery Principle", source: "NIDA addiction recovery framework"),
            .init(text: "Every cigarette you don't smoke is a victory.", author: "ReRoot", source: "Based on CDC cessation milestones"),
            .init(text: "The best time to quit was years ago. The second best time is right now.", author: "Proverb", source: "Adapted from Chinese proverb"),
            .init(text: "Freedom is what you find on the other side of discomfort.", author: "Allen Carr", source: "The Easy Way to Stop Smoking, 1985"),
            .init(text: "What you're feeling is withdrawal, not weakness. Those are not the same thing.", author: "NIDA", source: "National Institute on Drug Abuse"),
            .init(text: "Your addiction is making its argument. Arguments end. You win by not leaving the room.", author: "Behavioral Therapy", source: "CBT relapse prevention principles"),
            .init(text: "The chains of habit are too light to be felt until they are too heavy to be broken.", author: "Samuel Johnson", source: "The Rambler, No. 134, 1751"),
            .init(text: "Quitting is not giving something up. It's getting everything back.", author: "Recovery Insight", source: "Allen Carr cognitive reframing approach"),
            .init(text: "You don't need willpower to quit smoking; you need understanding.", author: "Cognitive Reframing", source: "CBT-based cessation therapy"),
            .init(text: "I am not a smoker who is trying to quit. I am a non-smoker making a comeback.", author: "Identity Shift", source: "Self-determination theory (Deci & Ryan)"),
            .init(text: "Quitting smoking is not a sacrifice; it's a liberation.", author: "Allen Carr", source: "The Easy Way to Stop Smoking, 1985"),
            .init(text: "The urge to smoke will pass whether you smoke or not.", author: "MBRP", source: "Mindfulness-Based Relapse Prevention (Marlatt)"),
            .init(text: "Health is not valued till sickness comes.", author: "Thomas Fuller", source: "Gnomologia, 1732"),
            .init(text: "Progress, not perfection.", author: "CBT Principle", source: "Cognitive Behavioral Therapy foundations"),
            .init(text: "Quitting is hard. Staying addicted is harder.", author: "Consequence Reframing", source: "Motivational interviewing framework"),
            .init(text: "Strength does not come from physical capacity. It comes from an indomitable will.", author: "Mahatma Gandhi", source: "Attributed, widely quoted"),
            .init(text: "Freedom from nicotine addiction is the greatest gift you can give yourself.", author: "Intrinsic Reward", source: "Self-determination theory (Deci & Ryan)"),
            .init(text: "You're not giving up tobacco. You're gaining back your life.", author: "Positivity Offset", source: "Positive psychology (Seligman)"),
            .init(text: "The cigarette didn't calm you. It relieved withdrawal while creating more of it.", author: "Harvard Health", source: "Harvard Health Publishing — anxiety/smoking paradox"),
            .init(text: "Every craving you outlast makes the next one permanently weaker.", author: "Neuroscience", source: "Nicotinic receptor downregulation research (NIDA)"),
            .init(text: "One day or day one. You decide.", author: "Recovery Wisdom", source: "Common in addiction recovery communities"),
            .init(text: "Your lungs are healing right now. Every breath is proof.", author: "ALA", source: "American Lung Association recovery timeline"),
            .init(text: "Quitting smoking is not about giving up pleasure; it's about giving up poison.", author: "Aversive Conditioning", source: "Behavioral conditioning therapy principles"),
        ]
        let dayIdx = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return pool[dayIdx % pool.count]
    }

    // MARK: - Timer helpers

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

    private var liveTimeString: String {
        let total = Int(state.elapsed)
        let d = total / 86400
        let h = (total % 86400) / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if d > 0 {
            return String(format: "%dd  %02dh  %02dm  %02ds", d, h, m, s)
        } else if h > 0 {
            return String(format: "%dh  %02dm  %02ds", h, m, s)
        } else {
            return String(format: "%dm  %02ds", m, s)
        }
    }
}
