import SwiftUI

struct JournalEntryView: View {
    let onComplete: (String) -> Void

    @State private var text = ""
    @State private var promptIndex: Int = 0
    @State private var appear = false
    @FocusState private var isFocused: Bool

    private let accent = Color(red: 0.55, green: 0.70, blue: 0.45)

    private let prompts = [
        "What is on your mind right now?",
        "How does your body feel in this moment?",
        "What would you tell yourself a year from now?",
        "What is one thing you're proud of today?",
        "What triggered your last craving, and how did you handle it?",
        "Describe a moment today when you felt strong.",
        "What are you afraid of about quitting? Be honest.",
        "What do you want your smoke-free life to look like?",
    ]

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.05).ignoresSafeArea()
            RadialGradient(
                colors: [accent.opacity(0.06), .clear],
                center: .top, startRadius: 20, endRadius: 400
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("JOURNAL")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(accent.opacity(0.6)).tracking(1.8)

                    Text(prompts[promptIndex % prompts.count])
                        .font(.serif(22, weight: .bold)).foregroundColor(.white)
                        .multilineTextAlignment(.center).lineSpacing(4)
                        .padding(.horizontal, 28)
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5), value: appear)

                    Button {
                        withAnimation { appear = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            promptIndex = (promptIndex + 1) % prompts.count
                            withAnimation { appear = true }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "shuffle").font(.system(size: 11, weight: .bold))
                            Text("Different prompt").font(.sansRR(11, weight: .semibold))
                        }
                        .foregroundColor(accent.opacity(0.6))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(accent.opacity(0.08)).clipShape(Capsule())
                    }
                }
                .padding(.top, 20)

                Spacer(minLength: 16)

                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Write freely. This is your space...")
                            .font(.sansRR(15))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.horizontal, 20).padding(.top, 18)
                    }

                    TextEditor(text: $text)
                        .font(.sansRR(15))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .focused($isFocused)
                        .padding(.horizontal, 16).padding(.vertical, 14)
                }
                .frame(maxHeight: 280)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFocused ? accent.opacity(0.3) : Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 18)

                HStack {
                    Spacer()
                    Text("\(text.count) characters")
                        .font(.sansRR(10)).foregroundColor(.white.opacity(0.25))
                        .padding(.trailing, 22).padding(.top, 6)
                }

                Spacer(minLength: 20)

                Button {
                    let entry = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    onComplete(entry.isEmpty ? "Journal skipped" : "Journal entry: \(entry)")
                } label: {
                    Text(hasText ? "Done writing \u{2192}" : "Skip \u{2192}")
                        .font(.sansRR(16, weight: .bold))
                        .foregroundColor(hasText ? .black : .black.opacity(0.5))
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(hasText ? accent : Color.white.opacity(0.4))
                        .clipShape(Capsule())
                        .shadow(color: hasText ? accent.opacity(0.3) : .clear, radius: 12, y: 4)
                }
                .padding(.horizontal, 22).padding(.bottom, 52)
            }
        }
        .onAppear {
            promptIndex = Int.random(in: 0..<prompts.count)
            withAnimation { appear = true }
        }
    }
}
