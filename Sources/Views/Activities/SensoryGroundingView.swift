import SwiftUI

struct SensoryGroundingView: View {
    let onComplete: () -> Void

    @StateObject private var audio = AmbientAudioManager.shared

    @State private var currentSense = 0
    @State private var inputs: [[String]] = [
        ["", "", "", "", ""],
        ["", "", "", ""],
        ["", "", ""],
        ["", ""],
        [""],
    ]
    @State private var isDone = false
    @FocusState private var focusedField: Int?

    private let senses: [(icon: String, label: String, prompt: String, count: Int, color: Color, hint: String)] = [
        ("eye.fill",         "SEE",   "Name 5 things you can see right now", 5,
         Color(red: 0.45, green: 0.65, blue: 0.85),
         "Be specific. Not just 'a wall' but 'the crack in the white wall near the window.'"),
        ("hand.raised.fill", "TOUCH", "Name 4 textures you can feel",        4,
         Color(red: 0.55, green: 0.75, blue: 0.45),
         "Touch something right now. What does it actually feel like under your fingers?"),
        ("ear.fill",         "HEAR",  "Name 3 sounds you can hear",          3,
         Color(red: 0.75, green: 0.55, blue: 0.35),
         "Close your eyes for a moment. What sounds are actually there?"),
        ("nose.fill",        "SMELL", "Name 2 things you can smell",         2,
         Color(red: 0.65, green: 0.45, blue: 0.65),
         "Breathe in slowly. Even 'nothing' is an answer, but try."),
        ("mouth.fill",       "TASTE", "Name 1 thing you can taste",          1,
         Color(red: 0.80, green: 0.45, blue: 0.45),
         "What's the taste in your mouth right now?"),
    ]

    private var sense: (icon: String, label: String, prompt: String, count: Int, color: Color, hint: String) {
        senses[currentSense]
    }

    private var currentInputs: [String] { inputs[currentSense] }
    private var filledCount: Int {
        currentInputs.filter { $0.trimmingCharacters(in: .whitespaces).count >= 2 }.count
    }
    private var senseComplete: Bool { filledCount >= sense.count }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 16)

            if isDone {
                completionView
            } else {
                senseView
            }

            Spacer(minLength: 52)
        }
        .onAppear { audio.play(.grounding) }
        .onDisappear { audio.stop() }
    }

    var senseView: some View {
        VStack(spacing: 18) {
            VStack(spacing: 6) {
                Text("5-4-3-2-1 GROUNDING")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                HStack(spacing: 8) {
                    Image(systemName: sense.icon).font(.system(size: 22)).foregroundColor(sense.color)
                    Text(sense.label).font(.serif(30, weight: .bold)).foregroundColor(.white)
                }
                Text(sense.prompt)
                    .font(.sansRR(14)).foregroundColor(.white.opacity(0.55))
            }

            progressDots

            Text(sense.hint)
                .font(.sansRR(12)).foregroundColor(sense.color.opacity(0.7))
                .multilineTextAlignment(.center).lineSpacing(2)
                .padding(.horizontal, 32)

            VStack(spacing: 10) {
                ForEach(0..<sense.count, id: \.self) { i in
                    HStack(spacing: 10) {
                        let filled = inputs[currentSense][i].trimmingCharacters(in: .whitespaces).count >= 2
                        ZStack {
                            Circle()
                                .fill(filled ? sense.color : Color.white.opacity(0.08))
                                .frame(width: 28, height: 28)
                            if filled {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                            } else {
                                Text("\(i + 1)")
                                    .font(.sansRR(11, weight: .bold)).foregroundColor(.white.opacity(0.4))
                            }
                        }

                        TextField("", text: $inputs[currentSense][i], prompt:
                            Text(placeholders(for: currentSense)[i])
                                .foregroundColor(.white.opacity(0.2))
                        )
                        .font(.sansRR(14))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                            filled ? sense.color.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1
                        ))
                        .focused($focusedField, equals: i)
                        .submitLabel(i < sense.count - 1 ? .next : .done)
                        .onSubmit {
                            if i < sense.count - 1 {
                                focusedField = i + 1
                            } else {
                                focusedField = nil
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 22)

            Text("\(filledCount)/\(sense.count) named")
                .font(.sansRR(12)).foregroundColor(sense.color)

            if senseComplete {
                Button {
                    focusedField = nil
                    advanceSense()
                } label: {
                    HStack(spacing: 6) {
                        Text(currentSense < 4 ? "Next sense" : "I'm grounded")
                            .font(.sansRR(15, weight: .bold))
                        Image(systemName: "arrow.right").font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Color.white).clipShape(Capsule())
                }
                .padding(.horizontal, 22)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    func placeholders(for senseIdx: Int) -> [String] {
        switch senseIdx {
        case 0: return ["e.g. the pattern on the ceiling", "e.g. light coming through the window", "e.g. my phone screen", "e.g. the color of the wall", "e.g. a shadow on the floor"]
        case 1: return ["e.g. the smooth table surface", "e.g. the fabric on my shirt", "e.g. the cool metal of my phone", "e.g. the warmth of my own skin"]
        case 2: return ["e.g. the hum of the fridge", "e.g. cars outside", "e.g. my own breathing"]
        case 3: return ["e.g. fresh air from the window", "e.g. coffee from earlier"]
        default: return ["e.g. the taste of water"]
        }
    }

    var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(i < currentSense ? Color.white.opacity(0.6) : (i == currentSense ? senses[i].color : Color.white.opacity(0.15)))
                    .frame(width: i == currentSense ? 10 : 7, height: i == currentSense ? 10 : 7)
                    .animation(.spring(response: 0.3), value: currentSense)
            }
        }
    }

    var completionView: some View {
        VStack(spacing: 24) {
            Text("GROUNDED")
                .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
            Text("You're here.\nYou're present.\nYou're safe.")
                .font(.serif(26, weight: .bold)).foregroundColor(.white)
                .multilineTextAlignment(.center).lineSpacing(7)

            VStack(alignment: .leading, spacing: 8) {
                Text("You just named:")
                    .font(.sansRR(11, weight: .bold)).foregroundColor(.white.opacity(0.4))
                let allInputs = inputs.flatMap { $0 }.filter { $0.trimmingCharacters(in: .whitespaces).count >= 2 }
                ForEach(Array(allInputs.prefix(6).enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 6) {
                        Circle().fill(Color.white.opacity(0.3)).frame(width: 4, height: 4)
                        Text(item).font(.sansRR(13)).foregroundColor(.white.opacity(0.65))
                    }
                }
                if allInputs.count > 6 {
                    Text("...and \(allInputs.count - 6) more")
                        .font(.sansRR(11)).foregroundColor(.white.opacity(0.3))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 22)

            Text("Your brain processed \(inputs.flatMap { $0 }.filter { $0.trimmingCharacters(in: .whitespaces).count >= 2 }.count) real sensory inputs from YOUR environment. The craving loop had nowhere to run.")
                .font(.sansRR(13)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)

            Button(action: onComplete) {
                Text("I'm grounded")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22)
        }
    }

    func advanceSense() {
        withAnimation {
            if currentSense < 4 {
                currentSense += 1
                focusedField = 0
            } else {
                isDone = true
            }
        }
    }
}
