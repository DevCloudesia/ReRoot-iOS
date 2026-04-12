import SwiftUI

struct JoyMappingView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared
    @State private var joys: [JoyItem] = []
    @State private var currentText = ""
    @State private var currentRating: Int = 3
    @State private var isDone = false

    struct JoyItem: Identifiable {
        let id = UUID()
        let text: String
        let rating: Int
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            VStack(spacing: 6) {
                Text("SMOKE-FREE JOY MAP")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(isDone ? "Smoke-free joys mapped." : "Proof that life is better without cigarettes")
                    .font(.serif(28, weight: .bold)).foregroundColor(.white)
                if !isDone {
                    Text("\(joys.count) of 3 joys mapped")
                        .font(.sansRR(12, weight: .semibold)).foregroundColor(.white.opacity(0.45))
                }
            }

            Spacer(minLength: 16)

            if isDone {
                VStack(spacing: 12) {
                    ForEach(joys.sorted(by: { $0.rating > $1.rating })) { joy in
                        HStack(spacing: 10) {
                            HStack(spacing: 2) {
                                ForEach(0..<joy.rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10)).foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.25))
                                }
                            }
                            .frame(width: 60, alignment: .leading)
                            Text(joy.text)
                                .font(.sansRR(14)).foregroundColor(.white.opacity(0.7))
                            Spacer()
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Text("You have \(joys.count) sources of genuine joy that have nothing to do with nicotine. That's powerful evidence for your new life.")
                        .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center).lineSpacing(3)
                }
                .padding(.horizontal, 22)
            } else {
                VStack(spacing: 14) {
                    if !joys.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(joys) { joy in
                                    VStack(spacing: 4) {
                                        Text(joy.text)
                                            .font(.sansRR(11)).foregroundColor(.white.opacity(0.6))
                                            .lineLimit(1)
                                        HStack(spacing: 1) {
                                            ForEach(0..<joy.rating, id: \.self) { _ in
                                                Image(systemName: "star.fill").font(.system(size: 8))
                                                    .foregroundColor(Color(red: 0.85, green: 0.72, blue: 0.25))
                                            }
                                        }
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            .padding(.horizontal, 22)
                        }
                    }

                    TextField("", text: $currentText, prompt: Text("Something that brings you joy...").foregroundColor(.white.opacity(0.3)))
                        .font(.sansRR(14)).foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.15), lineWidth: 1))
                        .padding(.horizontal, 22)

                    HStack(spacing: 6) {
                        Text("Joy level:").font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                        ForEach(1...5, id: \.self) { i in
                            Button {
                                currentRating = i
                            } label: {
                                Image(systemName: i <= currentRating ? "star.fill" : "star")
                                    .font(.system(size: 18))
                                    .foregroundColor(i <= currentRating ? Color(red: 0.85, green: 0.72, blue: 0.25) : .white.opacity(0.2))
                            }
                        }
                    }

                    Button {
                        let text = currentText.trimmingCharacters(in: .whitespaces)
                        guard !text.isEmpty else { return }
                        withAnimation { joys.append(JoyItem(text: text, rating: currentRating)) }
                        currentText = ""
                        currentRating = 3
                        if joys.count >= 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation { isDone = true }
                            }
                        }
                    } label: {
                        Text(joys.count < 2 ? "Add to map" : "Add final joy")
                            .font(.sansRR(15, weight: .bold)).foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                    .disabled(currentText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Spacer(minLength: 24)

            if isDone {
                Button(action: onComplete) {
                    Text("My smoke-free life has real joy \u{2192}")
                        .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.creative) }
        .onDisappear { audio.stop() }
    }
}
