import SwiftUI

struct SafePlaceBuilderView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var step = 0
    @State private var answers: [String] = ["", "", ""]
    @State private var isDone = false
    @State private var appear = false

    private let prompts: [(question: String, placeholder: String, icon: String)] = [
        ("Where is your safe place?", "A beach, a cabin, a room...", "house.fill"),
        ("What do you see there?", "Waves, trees, warm light...", "eye.fill"),
        ("What do you feel?", "Warm sand, soft blanket, breeze...", "hand.raised.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("YOUR SMOKE-FREE SANCTUARY")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Smoke-free sanctuary built." : "Build a place with no cigarettes")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("Step \(step + 1) of \(prompts.count)")
                        .font(.sansRR(11)).foregroundColor(.white.opacity(0.35))
                }
            }

            Spacer(minLength: 16)

            HStack(spacing: 4) {
                ForEach(0..<prompts.count, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Color.white.opacity(0.5) : Color.white.opacity(0.1))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 20)

            if isDone {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(prompts.enumerated()), id: \.offset) { i, p in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: p.icon)
                                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.4))
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(p.question).font(.sansRR(10)).foregroundColor(.white.opacity(0.35))
                                    Text(answers[i]).font(.sansRR(14)).foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 22)

                    Text("You can return here anytime a nicotine craving hits. This is your portable smoke-free space. When the urge strikes, close your eyes and come here.")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                }
            } else {
                let p = prompts[step]
                VStack(spacing: 16) {
                    Image(systemName: p.icon)
                        .font(.system(size: 36)).foregroundColor(.white.opacity(0.5))
                        .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.4), value: appear)

                    Text(p.question)
                        .font(.serif(20, weight: .bold)).foregroundColor(.white)
                        .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.4).delay(0.1), value: appear)

                    TextField(p.placeholder, text: $answers[step])
                        .font(.sansRR(16)).foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 22)
                        .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.4).delay(0.2), value: appear)
                }
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("My smoke-free space is ready \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            } else {
                Button {
                    guard !answers[step].trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    if step < prompts.count - 1 {
                        withAnimation { appear = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            step += 1
                            withAnimation { appear = true }
                        }
                    } else {
                        withAnimation { isDone = true }; audio.stop()
                    }
                } label: {
                    Text(step < prompts.count - 1 ? "Next \u{2192}" : "See my safe place")
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
