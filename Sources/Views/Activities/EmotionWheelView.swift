import SwiftUI

struct EmotionWheelView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var selectedCore: Int? = nil
    @State private var selectedSub: String? = nil
    @State private var isDone = false
    @State private var appear = false

    private let coreEmotions: [(name: String, color: Color, subs: [String])] = [
        ("Anger", Color(red: 0.85, green: 0.30, blue: 0.25), ["Frustrated", "Irritated", "Resentful", "Bitter"]),
        ("Fear", Color(red: 0.65, green: 0.45, blue: 0.75), ["Anxious", "Worried", "Panicked", "Insecure"]),
        ("Sadness", Color(red: 0.35, green: 0.50, blue: 0.75), ["Lonely", "Disappointed", "Hopeless", "Grieving"]),
        ("Joy", Color(red: 0.35, green: 0.75, blue: 0.45), ["Grateful", "Proud", "Content", "Excited"]),
        ("Surprise", Color(red: 0.85, green: 0.65, blue: 0.25), ["Confused", "Amazed", "Startled", "Overwhelmed"]),
        ("Disgust", Color(red: 0.60, green: 0.55, blue: 0.45), ["Ashamed", "Guilty", "Embarrassed", "Repulsed"]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("NAME THE WITHDRAWAL FEELING")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Withdrawal feeling identified." : "What is withdrawal doing to your mood?")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                Text("Nicotine withdrawal causes mood swings, irritability, and anxiety.\nNaming what you feel reduces its power by up to 50%.")
                    .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 20)

            if isDone, let core = selectedCore, let sub = selectedSub {
                VStack(spacing: 20) {
                    Circle().fill(coreEmotions[core].color.opacity(0.3)).frame(width: 100, height: 100)
                        .overlay(Text(sub).font(.serif(18, weight: .bold)).foregroundColor(.white).multilineTextAlignment(.center))

                    Text("You're feeling \(sub.lowercased()), and that's completely valid.")
                        .font(.sansRR(15)).foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center).padding(.horizontal, 28)
                    Text("You named what nicotine withdrawal is doing to your mood. Research shows this alone reduces the feeling's intensity. The withdrawal caused this emotion, not you.")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center).padding(.horizontal, 32)
                }
            } else if let core = selectedCore {
                VStack(spacing: 12) {
                    Text("More specifically:")
                        .font(.sansRR(14)).foregroundColor(.white.opacity(0.5))
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(coreEmotions[core].subs, id: \.self) { sub in
                            Button {
                                selectedSub = sub
                                withAnimation(.easeOut(duration: 0.5)) { isDone = true }
                            } label: {
                                Text(sub)
                                    .font(.sansRR(14, weight: .semibold)).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                                    .background(coreEmotions[core].color.opacity(0.25))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(coreEmotions[core].color.opacity(0.4), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 22)
                }
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Array(coreEmotions.enumerated()), id: \.offset) { i, em in
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedCore = i }
                        } label: {
                            VStack(spacing: 8) {
                                Circle().fill(em.color.opacity(0.3)).frame(width: 56, height: 56)
                                    .overlay(Circle().stroke(em.color.opacity(0.5), lineWidth: 2))
                                Text(em.name)
                                    .font(.sansRR(12, weight: .semibold)).foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("I see through the withdrawal \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.grounding) }
        .onDisappear { audio.stop() }
    }
}
