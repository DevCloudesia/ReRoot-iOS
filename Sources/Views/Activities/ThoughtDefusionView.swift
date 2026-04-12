import SwiftUI

struct ThoughtDefusionView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var thought = ""
    @State private var floatingThoughts: [FloatingThought] = []
    @State private var isDone = false

    private let maxThoughts = 3

    struct FloatingThought: Identifiable {
        let id = UUID()
        let text: String
        var opacity: Double = 1.0
        var yOffset: CGFloat = 0
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("QUIT-THOUGHT DEFUSION")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Smoking thoughts are just clouds." : "Let smoking thoughts float away")
                    .font(.serif(26, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("\(floatingThoughts.count) of \(maxThoughts) thoughts released")
                        .font(.sansRR(12, weight: .semibold)).foregroundColor(.white.opacity(0.45))
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 16)

            ZStack {
                ForEach(floatingThoughts) { ft in
                    Text(ft.text)
                        .font(.sansRR(14)).foregroundColor(.white.opacity(ft.opacity))
                        .offset(y: ft.yOffset)
                        .transition(.opacity)
                }
            }
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)

            Spacer(minLength: 16)

            if isDone {
                VStack(spacing: 16) {
                    Text("You watched \(floatingThoughts.count) smoking thoughts come and go.\nNone of them made you light up.")
                        .font(.sansRR(14)).foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center).lineSpacing(3)
                    Button(action: onComplete) {
                        Text("My quit is stronger \u{2192}")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                }
            } else {
                HStack(spacing: 10) {
                    TextField("", text: $thought, prompt:
                        Text("e.g. I'll never quit, just one won't hurt...")
                            .foregroundColor(.white.opacity(0.3))
                    )
                        .font(.sansRR(14)).foregroundColor(.white)
                        .lineLimit(2)
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))

                    Button { releaseTh() } label: {
                        Text("Release")
                            .font(.sansRR(13, weight: .bold)).foregroundColor(.black)
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .disabled(thought.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16)
            }

            Spacer(minLength: 52)
        }
    }

    func releaseTh() {
        let text = thought.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        let ft = FloatingThought(text: text)
        floatingThoughts.append(ft)
        thought = ""

        if let idx = floatingThoughts.firstIndex(where: { $0.id == ft.id }) {
            withAnimation(.easeOut(duration: 4)) {
                floatingThoughts[idx].yOffset = -200
                floatingThoughts[idx].opacity = 0
            }
        }

        if floatingThoughts.count >= maxThoughts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { isDone = true }
            }
        }
    }
}
