import SwiftUI

struct GratitudeGardenView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var items: [String] = []
    @State private var currentText = ""
    @State private var isDone = false

    private let flowerColors: [Color] = [
        Color(red: 0.85, green: 0.45, blue: 0.55),
        Color(red: 0.55, green: 0.75, blue: 0.45),
        Color(red: 0.45, green: 0.55, blue: 0.85),
        Color(red: 0.85, green: 0.72, blue: 0.25),
        Color(red: 0.65, green: 0.45, blue: 0.75),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("SMOKE-FREE GRATITUDE")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Your garden grew." : "Reasons you're grateful you quit")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("\(items.count) of 3 gratitudes planted")
                        .font(.sansRR(12, weight: .semibold)).foregroundColor(.white.opacity(0.45))
                }
            }

            Spacer(minLength: 16)

            ZStack {
                HStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                        VStack(spacing: 6) {
                            Circle()
                                .fill(flowerColors[i % flowerColors.count].opacity(0.4))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 18)).foregroundColor(flowerColors[i % flowerColors.count])
                                )
                            Text(item)
                                .font(.sansRR(10)).foregroundColor(.white.opacity(0.6))
                                .lineLimit(2).multilineTextAlignment(.center)
                                .frame(width: 60)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 16)

            Spacer(minLength: 16)

            if isDone {
                VStack(spacing: 16) {
                    Text("Gratitude journaling increases dopamine and serotonin naturally. You just gave your brain a reward without any substance.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
                    Button(action: onComplete) {
                        Text("My quit has real rewards \u{2192}")
                            .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                }
            } else {
                VStack(spacing: 12) {
                    TextField("", text: $currentText, prompt: Text("e.g. I can breathe deeper, food tastes better...").foregroundColor(.white.opacity(0.3)))
                        .font(.sansRR(14)).foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        .padding(.horizontal, 22)

                    Button {
                        let text = currentText.trimmingCharacters(in: .whitespaces)
                        guard !text.isEmpty else { return }
                        withAnimation(.spring(response: 0.35)) { items.append(text) }
                        currentText = ""
                        if items.count >= 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation { isDone = true }
                            }
                        }
                    } label: {
                        Text(items.count < 2 ? "Plant" : "Plant final gratitude")
                            .font(.sansRR(15, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                    .disabled(currentText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.creative) }
        .onDisappear { audio.stop() }
    }
}
