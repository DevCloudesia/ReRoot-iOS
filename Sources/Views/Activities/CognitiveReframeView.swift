import SwiftUI

struct CognitiveReframeView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var step = 0
    @State private var negativeThought = ""
    @State private var evidence = ""
    @State private var reframe = ""
    @State private var isDone = false
    @State private var appear = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text("QUIT-THOUGHT REFRAME")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                    Text(isDone ? "Quit thinking strengthened." : "Challenge the smoking thought")
                        .font(.serif(28, weight: .bold)).foregroundColor(.white)
                    Text("Step \(step + 1) of 3")
                        .font(.sansRR(12, weight: .semibold)).foregroundColor(.white.opacity(0.45))
                }
                .padding(.horizontal, 28)

                Spacer(minLength: 24)

                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Capsule()
                            .fill(i <= step ? Color.white.opacity(0.5) : Color.white.opacity(0.1))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 22)

                Spacer(minLength: 24)

                if isDone {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Old thought:").font(.sansRR(11)).foregroundColor(.white.opacity(0.4))
                            Text(negativeThought)
                                .font(.sansRR(14)).foregroundColor(.white.opacity(0.5))
                                .strikethrough()
                        }
                        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 12))

                        Image(systemName: "arrow.down")
                            .font(.system(size: 20)).foregroundColor(.white.opacity(0.3))

                        VStack(alignment: .leading, spacing: 10) {
                            Text("New thought:").font(.sansRR(11)).foregroundColor(.white.opacity(0.4))
                            Text(reframe)
                                .font(.sansRR(14, weight: .semibold)).foregroundColor(.white.opacity(0.8))
                        }
                        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.35, green: 0.65, blue: 0.45).opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 12))

                        Text("Each time you challenge a pro-smoking thought, the neural pathway connecting 'stress' to 'cigarette' gets weaker. You're literally rewiring your addiction.")
                            .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center).lineSpacing(3)
                    }
                    .padding(.horizontal, 22)
                } else {
                    VStack(spacing: 20) {
                        switch step {
                        case 0:
                            stepView(
                                title: "Step 1: The Thought",
                                prompt: "What negative thought keeps coming up?",
                                placeholder: "e.g. I'll never quit for good...",
                                text: $negativeThought
                            )
                        case 1:
                            stepView(
                                title: "Step 2: The Evidence",
                                prompt: "What evidence contradicts this thought?",
                                placeholder: "e.g. I've already gone X hours without smoking...",
                                text: $evidence
                            )
                        default:
                            stepView(
                                title: "Step 3: The Reframe",
                                prompt: "Rewrite the thought in a more balanced way.",
                                placeholder: "e.g. Quitting is hard, but I'm proving I can do it...",
                                text: $reframe
                            )
                        }
                    }
                    .padding(.horizontal, 22)
                }

                Spacer(minLength: 24)

                if isDone {
                    Button(action: onComplete) {
                        Text("My quit-thinking is stronger \u{2192}")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                } else {
                    Button {
                        let currentText = step == 0 ? negativeThought : (step == 1 ? evidence : reframe)
                        guard !currentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        if step < 2 {
                            withAnimation { step += 1 }
                        } else {
                            withAnimation { isDone = true }; audio.stop()
                        }
                    } label: {
                        Text(step < 2 ? "Next \u{2192}" : "See my reframe")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                }

                Spacer(minLength: 52)
            }
        }
        .onAppear { audio.play(.grounding) }
        .onDisappear { audio.stop() }
    }

    func stepView(title: String, prompt: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.sansRR(14, weight: .bold)).foregroundColor(.white)
            Text(prompt)
                .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            TextField(placeholder, text: text, axis: .vertical)
                .font(.sansRR(14)).foregroundColor(.white)
                .lineLimit(3)
                .padding(16)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 1))
        }
    }
}
