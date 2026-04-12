import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var hkManager: HealthKitManager
    @EnvironmentObject var gamification: GamificationState

    @State private var selectedTab = 0
    @State private var showCheckIn = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0: StatsQuoteView()
                case 1: SkillProgressView()
                case 2: HealthIntegrationView()
                default: StatsQuoteView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: selectedTab)

            VStack(spacing: 0) {
                Button {
                    showCheckIn = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "leaf.fill").font(.system(size: 12))
                        Text("Check In Again").font(.sansRR(12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.rAccent).clipShape(Capsule())
                    .shadow(color: Color.rAccent.opacity(0.4), radius: 8, y: 3)
                }
                .padding(.bottom, 6)

                ThreeTabBar(selected: $selectedTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $showCheckIn) {
            CheckInPickerWrapper(isPresented: $showCheckIn)
                .environmentObject(state)
                .environmentObject(gamification)
                .environmentObject(hkManager)
        }
    }
}

// MARK: - 3-Tab Bar

struct ThreeTabBar: View {
    @Binding var selected: Int

    private let tabs: [(icon: String, label: String)] = [
        ("chart.bar.fill",            "Stats"),
        ("sparkles",                   "Skills"),
        ("heart.text.square.fill",    "Health"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button {
                    withAnimation(.spring(response: 0.3)) { selected = i }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tabs[i].icon)
                            .font(.system(size: selected == i ? 22 : 20,
                                          weight: selected == i ? .semibold : .regular))
                            .foregroundColor(selected == i ? .rAccent : .rText3)

                        Text(tabs[i].label)
                            .font(.sansRR(10, weight: selected == i ? .bold : .medium))
                            .foregroundColor(selected == i ? .rAccent : .rText3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .scaleEffect(selected == i ? 1.0 : 0.92)
                    .animation(.spring(response: 0.3), value: selected)
                }
            }
        }
        .padding(.bottom, 6)
        .background(
            Color.white.opacity(0.95)
                .background(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 12, y: -2)
        )
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.rBg2), alignment: .top)
    }
}

// MARK: - Shared UI Components

struct RRCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 18

    init(padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color.white.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Text(icon).font(.system(size: 17))
            Text(title).font(.serif(17, weight: .bold)).foregroundColor(.rText)
        }
    }
}

struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.serif(17, weight: .bold)).foregroundColor(.white).monospacedDigit()
            Text(label).font(.sansRR(9, weight: .medium)).foregroundColor(.white.opacity(0.36))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

struct StatCard: View {
    let value: String; let label: String; let color: Color; let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.system(size: 20, weight: .semibold)).foregroundColor(color)
            Text(value).font(.serif(28, weight: .bold)).foregroundColor(.rText).monospacedDigit()
            Text(label).font(.sansRR(11)).foregroundColor(.rText3).lineLimit(2)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

// MARK: - Check-In Picker Wrapper

struct CheckInPickerWrapper: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    @EnvironmentObject var hkManager: HealthKitManager

    var body: some View {
        TreeLandingView(
            onCheckInComplete: { isPresented = false },
            onClose: { isPresented = false }
        )
            .environmentObject(state)
            .environmentObject(gamification)
            .environmentObject(hkManager)
    }
}

