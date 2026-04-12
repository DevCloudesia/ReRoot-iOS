import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var state: AppState
    @State private var step = 0
    @State private var name = ""
    @State private var selectedTriggers: Set<String> = []
    @State private var selectedMotivation: String? = nil
    @State private var mode: Mode = .now
    @State private var pastDays: Int = 0
    @State private var pastHours: Int = 0
    @State private var appear = false

    enum Mode { case now, past }

    private let triggers = [
        ("bolt.fill",        "Stress"),
        ("person.2.fill",    "Social situations"),
        ("clock.fill",       "Morning routine"),
        ("fork.knife",       "After meals"),
        ("cloud.rain.fill",  "Boredom"),
        ("wineglass.fill",   "Alcohol"),
        ("heart.slash.fill", "Emotional pain"),
        ("moon.fill",        "Poor sleep"),
        ("car.fill",         "Driving"),
        ("cup.and.saucer.fill", "Coffee/breaks"),
    ]

    private let motivations = [
        ("heart.fill",     "My health"),
        ("figure.2.and.child.holdinghands", "My family"),
        ("dollarsign.circle.fill", "Saving money"),
        ("bird.fill",      "Freedom"),
        ("lungs.fill",     "Breathing better"),
        ("brain.head.profile", "Mental clarity"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.118, green: 0.110, blue: 0.098),
                         Color(red: 0.176, green: 0.165, blue: 0.149),
                         Color(red: 0.239, green: 0.220, blue: 0.196)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            Circle().fill(Color.rAccent.opacity(0.06))
                .frame(width: 400, height: 400).offset(x: -120, y: 180)
            Circle().fill(Color.rAmber.opacity(0.05))
                .frame(width: 300, height: 300).offset(x: 140, y: -200)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 50)

                    if step == 0 {
                        welcomeStep
                    } else if step == 1 {
                        nameStep
                    } else if step == 2 {
                        triggerStep
                    } else if step == 3 {
                        motivationStep
                    } else {
                        quitDateStep
                    }

                    Spacer(minLength: 48)
                }
            }
        }
        .onAppear { withAnimation { appear = true } }
    }

    // MARK: - Step 0: Welcome

    var welcomeStep: some View {
        VStack(spacing: 0) {
            Text("🌿").font(.system(size: 60))
            Spacer(minLength: 14)
            Text("ReRoot")
                .font(.serif(56, weight: .heavy))
                .foregroundColor(Color(red: 0.969, green: 0.953, blue: 0.933))
                .tracking(-1.5)
            Text("NICOTINE RECOVERY")
                .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.32)).tracking(3)
                .padding(.top, 6).padding(.bottom, 22)

            Text("Track your body healing in real time.\nBuilt on research from CDC, NIH, SAMHSA, American Lung Association & Mayo Clinic.")
                .font(.sansRR(14)).foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center).lineSpacing(4).padding(.horizontal, 32)
                .padding(.bottom, 36)

            Button { withAnimation { step = 1 } } label: {
                Text("Let's begin")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(Color.rAccent).clipShape(Capsule())
                    .shadow(color: Color.rAccent.opacity(0.4), radius: 16, y: 6)
            }
            .padding(.horizontal, 24)
        }
        .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5), value: appear)
    }

    // MARK: - Step 1: Name

    var nameStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("PERSONALIZE")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.35)).tracking(2)
                Text("What should we\ncall you?")
                    .font(.serif(30, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("Just a first name. This keeps things personal.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
            }

            TextField("", text: $name, prompt:
                Text("Your first name").foregroundColor(.white.opacity(0.2))
            )
            .font(.serif(22, weight: .bold)).foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(16)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1)))
            .padding(.horizontal, 40)

            Button { withAnimation { step = 2 } } label: {
                Text(name.trimmingCharacters(in: .whitespaces).isEmpty ? "Skip" : "Continue")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(Color.rAccent).clipShape(Capsule())
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 2: Triggers

    var triggerStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("YOUR TRIGGERS")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.35)).tracking(2)
                Text("When do you usually\nreach for a cigarette?")
                    .font(.serif(26, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("Pick up to 3. This helps us give you the right tools at the right time.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
                    .multilineTextAlignment(.center).padding(.horizontal, 24)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(triggers, id: \.1) { icon, label in
                    let sel = selectedTriggers.contains(label)
                    Button {
                        withAnimation(.spring(response: 0.25)) {
                            if sel {
                                selectedTriggers.remove(label)
                            } else if selectedTriggers.count < 3 {
                                selectedTriggers.insert(label)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: icon).font(.system(size: 14))
                                .foregroundColor(sel ? .white : .white.opacity(0.45))
                            Text(label).font(.sansRR(12, weight: .semibold))
                                .foregroundColor(sel ? .white : .white.opacity(0.6))
                            Spacer()
                            if sel {
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(12)
                        .background(sel ? Color.rAccent.opacity(0.3) : Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                            sel ? Color.rAccent.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1
                        ))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 22)

            Text("\(selectedTriggers.count)/3 selected")
                .font(.sansRR(11)).foregroundColor(.white.opacity(0.3))

            Button { withAnimation { step = 3 } } label: {
                Text(selectedTriggers.isEmpty ? "Skip" : "Continue")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(Color.rAccent).clipShape(Capsule())
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 3: Motivation

    var motivationStep: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("YOUR WHY")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.35)).tracking(2)
                Text("What matters most\nabout quitting?")
                    .font(.serif(26, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineSpacing(5)
                Text("We'll remind you of this when things get hard.")
                    .font(.sansRR(13)).foregroundColor(.white.opacity(0.38))
            }

            VStack(spacing: 10) {
                ForEach(motivations, id: \.1) { icon, label in
                    let sel = selectedMotivation == label
                    Button {
                        withAnimation(.spring(response: 0.25)) { selectedMotivation = label }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: icon).font(.system(size: 18))
                                .foregroundColor(sel ? .white : .white.opacity(0.5))
                            Text(label).font(.sansRR(15, weight: .semibold))
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

            Button { withAnimation { step = 4 } } label: {
                Text(selectedMotivation == nil ? "Skip" : "Continue")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(Color.rAccent).clipShape(Capsule())
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 4: Quit Date

    var quitDateStep: some View {
        VStack(spacing: 0) {
            Text("🌿").font(.system(size: 48)).padding(.bottom, 10)

            Text("Ready to ReRoot")
                .font(.serif(30, weight: .bold))
                .foregroundColor(Color(red: 0.969, green: 0.953, blue: 0.933))
                .padding(.bottom, 22)

            HStack(spacing: 0) {
                ForEach([("I'm quitting now", Mode.now),
                         ("I already quit", Mode.past)], id: \.0) { label, m in
                    Button { withAnimation(.spring(response: 0.3)) { mode = m } } label: {
                        Text(label)
                            .font(.sansRR(13, weight: .semibold))
                            .foregroundColor(mode == m ? .white : .white.opacity(0.45))
                            .padding(.vertical, 11).frame(maxWidth: .infinity)
                            .background(mode == m ? Color.rAccent : Color.clear)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.07)).clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 24).padding(.bottom, 16)

            if mode == .past {
                VStack(spacing: 12) {
                    Text("HOW LONG AGO DID YOU QUIT?")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.5)
                    HStack(spacing: 12) {
                        OffsetField(label: "DAYS", value: $pastDays, max: 365)
                        OffsetField(label: "HOURS", value: $pastHours, max: 23)
                    }
                }
                .padding(18)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1)))
                .padding(.horizontal, 24).padding(.bottom, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Button {
                let trimName = name.trimmingCharacters(in: .whitespaces)
                if !trimName.isEmpty {
                    state.userName = trimName
                    UserDefaults.standard.set(trimName, forKey: "userName")
                }
                state.userTriggers = Array(selectedTriggers)
                UserDefaults.standard.set(Array(selectedTriggers), forKey: "userTriggers")
                if let mot = selectedMotivation {
                    state.quitMotivation = mot
                    UserDefaults.standard.set(mot, forKey: "quitMotivation")
                }
                let offset = TimeInterval(pastDays * 86400 + pastHours * 3600)
                state.startQuit(offsetSeconds: offset)
            } label: {
                Text(mode == .now ? "I'm Quitting Now" : "Start Tracking")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 17)
                    .background(Color.rAccent).clipShape(Capsule())
                    .shadow(color: Color.rAccent.opacity(0.4), radius: 16, y: 6)
            }
            .padding(.horizontal, 24).padding(.bottom, 10)

            Text("Team: Try { Quit } Catch { Relapse }")
                .font(.sansRR(10)).foregroundColor(.white.opacity(0.18)).tracking(0.8)
                .padding(.top, 28).padding(.bottom, 48)
        }
    }
}

struct OffsetField: View {
    let label: String
    @Binding var value: Int
    let max: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.sansRR(9, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1)
            HStack(spacing: 0) {
                Button { if value > 0 { value -= 1 } } label: {
                    Image(systemName: "minus")
                        .font(.sansRR(14, weight: .bold)).foregroundColor(.white.opacity(0.5))
                        .frame(width: 36, height: 44)
                }
                Text("\(value)")
                    .font(.serif(22, weight: .bold)).foregroundColor(.white).frame(minWidth: 44)
                Button { if value < max { value += 1 } } label: {
                    Image(systemName: "plus")
                        .font(.sansRR(14, weight: .bold)).foregroundColor(.white.opacity(0.5))
                        .frame(width: 36, height: 44)
                }
            }
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity)
    }
}
