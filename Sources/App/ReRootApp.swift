import SwiftUI

@main
struct ReRootApp: App {
    @StateObject private var state           = AppState()
    @StateObject private var hkManager       = HealthKitManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var gamification    = GamificationState()
    @StateObject private var nudgeEngine     = NudgeEngine()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if !state.hasStarted {
                        OnboardingView()
                            .environmentObject(state)
                    } else if !state.checkedInToday {
                        TreeLandingView()
                            .environmentObject(state)
                            .environmentObject(hkManager)
                            .environmentObject(gamification)
                            .environmentObject(locationManager)
                            .environmentObject(nudgeEngine)
                            .onAppear {
                                Task { await hkManager.requestAuthorization() }
                            }
                    } else {
                        MainTabView()
                            .environmentObject(state)
                            .environmentObject(hkManager)
                            .environmentObject(gamification)
                            .environmentObject(locationManager)
                            .environmentObject(nudgeEngine)
                            .onAppear {
                                gamification.checkAchievements(elapsed: state.elapsed)
                            }
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: state.hasStarted)
                .animation(.easeInOut(duration: 0.4), value: state.checkedInToday)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}

// MARK: - Splash Screen

struct SplashView: View {
    @State private var appear = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.rAccent.ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulse ? 1.1 : 1.0)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-15))
                }

                VStack(spacing: 6) {
                    Text("ReRoot")
                        .font(.serif(36, weight: .bold))
                        .foregroundColor(.white)

                    Text("BY: try {quit} catch {retreat}")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.9)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appear = true }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Design Tokens
extension Color {
    static let rBg      = Color(red: 0.969, green: 0.953, blue: 0.933)
    static let rBg2     = Color(red: 0.929, green: 0.910, blue: 0.878)
    static let rAccent  = Color(red: 0.357, green: 0.549, blue: 0.353)
    static let rAmber   = Color(red: 0.757, green: 0.486, blue: 0.306)
    static let rText    = Color(red: 0.176, green: 0.165, blue: 0.149)
    static let rText2   = Color(red: 0.420, green: 0.396, blue: 0.376)
    static let rText3   = Color(red: 0.620, green: 0.588, blue: 0.565)
    static let rDanger  = Color(red: 0.757, green: 0.353, blue: 0.306)
    static let rPurple  = Color(red: 0.482, green: 0.420, blue: 0.553)
    static let rDark    = Color(red: 0.118, green: 0.110, blue: 0.098)
}

extension Font {
    static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    static func sansRR(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
