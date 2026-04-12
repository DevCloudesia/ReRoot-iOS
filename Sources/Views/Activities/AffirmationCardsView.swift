import SwiftUI

struct AffirmationCardsView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var cardIdx = 0
    @State private var appear = false
    @State private var isDone = false
    @State private var offset: CGFloat = 0

    private let cards: [(text: String, color: Color)] = [
        ("I am stronger than any craving.", Color(red: 0.35, green: 0.65, blue: 0.45)),
        ("Every smoke-free minute rewires my brain.", Color(red: 0.45, green: 0.55, blue: 0.85)),
        ("This craving will pass. I will not.", Color(red: 0.85, green: 0.55, blue: 0.35)),
        ("My body is healing right now.", Color(red: 0.35, green: 0.75, blue: 0.65)),
        ("Every day gets a little easier.", Color(red: 0.45, green: 0.65, blue: 0.75)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("QUIT AFFIRMATIONS")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Quit identity strengthened." : "Truths about your quit")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                Text("These are truths about your recovery from nicotine addiction.\nRead each one slowly. Let it land. Swipe when ready.")
                    .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center).lineSpacing(3)
            }

            Spacer(minLength: 24)

            if isDone {
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48)).foregroundColor(.white.opacity(0.5))
                    Text("Each time you read these, the neural pathway connecting your identity to 'non-smoker' gets stronger. You're literally rewiring your brain's self-concept.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                }
            } else {
                let card = cards[cardIdx]
                VStack(spacing: 20) {
                    Text(card.text)
                        .font(.serif(24, weight: .bold)).foregroundColor(.white)
                        .multilineTextAlignment(.center).lineSpacing(6)
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .background(card.color.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(card.color.opacity(0.4), lineWidth: 1.5))
                        .offset(x: offset)
                        .gesture(
                            DragGesture()
                                .onChanged { v in offset = v.translation.width }
                                .onEnded { v in
                                    if abs(v.translation.width) > 80 {
                                        withAnimation(.easeOut(duration: 0.2)) { offset = v.translation.width > 0 ? 400 : -400 }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            offset = 0
                                            if cardIdx < cards.count - 1 { cardIdx += 1 }
                                            else { withAnimation { isDone = true }; audio.stop() }
                                        }
                                    } else {
                                        withAnimation(.spring()) { offset = 0 }
                                    }
                                }
                        )
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5), value: appear)

                    Text("\(cardIdx + 1)/\(cards.count)")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.35))
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 32)

            if isDone {
                Button(action: onComplete) {
                    Text("I am a non-smoker \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.creative); withAnimation { appear = true } }
        .onDisappear { audio.stop() }
    }
}
