import SwiftUI

struct VisualizationJourneyView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var sceneIdx = 0
    @State private var appear = false
    @State private var isDone = false

    private let scenes: [(title: String, desc: String, icon: String, color: Color)] = [
        ("Close your eyes", "Take three slow breaths. Let your shoulders drop. Let your jaw soften.", "eye.slash.fill", .white),
        ("A forest path", "You're walking on soft earth. Tall trees surround you. Sunlight filters through the leaves, warm on your skin.", "tree.fill", Color(red: 0.35, green: 0.65, blue: 0.35)),
        ("Let it go", "In a sunlit clearing, there is a small fire. Place your urge to smoke into the flame. Watch the craving burn away. You don't need it.", "flame.fill", Color(red: 0.85, green: 0.45, blue: 0.25)),
        ("Return", "Take a deep breath of this clean air. Feel it fill your lungs. When you're ready, slowly open your eyes.", "sparkles", Color(red: 0.65, green: 0.45, blue: 0.85)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("SMOKE-FREE VISUALIZATION")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "You returned." : "Your smoke-free sanctuary")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("Scene \(sceneIdx + 1) of \(scenes.count)")
                        .font(.sansRR(11)).foregroundColor(.white.opacity(0.35))
                }
            }

            Spacer(minLength: 20)

            HStack(spacing: 4) {
                ForEach(0..<scenes.count, id: \.self) { i in
                    Capsule()
                        .fill(i <= sceneIdx ? Color.white.opacity(0.5) : Color.white.opacity(0.1))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 24)

            if isDone {
                VStack(spacing: 16) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 48)).foregroundColor(.white.opacity(0.5))
                    Text("Your brain just practiced being calm without nicotine. Visualization builds the same neural pathways as real experience. You're training your brain that peace doesn't require a cigarette.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                }
            } else {
                let scene = scenes[sceneIdx]
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(scene.color.opacity(0.15))
                            .frame(width: 120, height: 120)
                        Image(systemName: scene.icon)
                            .font(.system(size: 40)).foregroundColor(scene.color.opacity(0.7))
                    }
                    .opacity(appear ? 1 : 0).scaleEffect(appear ? 1 : 0.8)
                    .animation(.easeOut(duration: 0.6), value: appear)

                    Text(scene.title)
                        .font(.serif(22, weight: .bold)).foregroundColor(.white)
                        .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.6).delay(0.1), value: appear)

                    Text(scene.desc)
                        .font(.sansRR(15)).foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center).lineSpacing(4).padding(.horizontal, 28)
                        .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.6).delay(0.2), value: appear)
                }
            }

            Spacer(minLength: 32)

            if isDone {
                Button(action: onComplete) {
                    Text("Peace without nicotine \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else {
                Button {
                    if sceneIdx < scenes.count - 1 {
                        withAnimation { appear = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            sceneIdx += 1
                            withAnimation { appear = true }
                        }
                    } else {
                        withAnimation { isDone = true }; audio.stop()
                    }
                } label: {
                    Text(sceneIdx < scenes.count - 1 ? "Continue \u{2192}" : "Open your eyes")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.urgeSurfing); withAnimation { appear = true } }
        .onDisappear { audio.stop() }
    }
}
