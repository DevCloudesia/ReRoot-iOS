import SwiftUI

struct CreativeActivityStage: View {
    let mood: Int
    let onComplete: (String) -> Void

    @State private var chosen: ActivityType?
    @State private var doodlePromptIndex: Int = 0

    enum ActivityType: String, CaseIterable {
        case doodle, poetry, journal, voiceMemo

        var label: String {
            switch self {
            case .doodle: return "Free Doodle"
            case .poetry: return "One-Line Poetry"
            case .journal: return "Journal"
            case .voiceMemo: return "Voice Memo"
            }
        }
        var icon: String {
            switch self {
            case .doodle: return "paintbrush.pointed.fill"
            case .poetry: return "text.quote"
            case .journal: return "book.fill"
            case .voiceMemo: return "mic.fill"
            }
        }
        var description: String {
            switch self {
            case .doodle: return "Draw whatever comes to mind. No rules, no judgment."
            case .poetry: return "Write one line on a theme. Express what words can hold."
            case .journal: return "Write freely about what you're feeling. Your private space."
            case .voiceMemo: return "Record your thoughts out loud. Sometimes voice says more."
            }
        }
        var accent: Color {
            switch self {
            case .doodle: return Color(red: 0.85, green: 0.55, blue: 0.35)
            case .poetry: return Color(red: 0.55, green: 0.55, blue: 0.85)
            case .journal: return Color(red: 0.55, green: 0.70, blue: 0.45)
            case .voiceMemo: return Color(red: 0.85, green: 0.45, blue: 0.45)
            }
        }
    }

    private var doodlePrompts: [String] {
        switch mood {
        case 0: return [
            "Draw what your craving looks like",
            "Scribble until the tension leaves your hand",
            "Draw a door and you walking through it",
            "Sketch the shape of the feeling in your chest",
            "Draw a storm, then draw what comes after",
            "Let your hand move without thinking for 60 seconds",
            "Draw a wall, then draw yourself breaking it",
            "Create an abstract pattern using only circles",
        ]
        case 1: return [
            "Draw the weather inside you right now",
            "Doodle a shield that protects you",
            "Draw what calm looks like",
            "Sketch a mountain you are climbing",
            "Draw a river carrying away your stress",
            "Make a pattern with zigzag lines",
            "Draw an animal that represents your strength",
            "Sketch a bridge from here to where you want to be",
        ]
        case 2: return [
            "Draw your day as a landscape",
            "Sketch something that made you smile",
            "Draw roots growing deeper",
            "Doodle a map of your favorite place",
            "Draw a tree and give it details",
            "Create a mandala using any shapes",
            "Sketch a wave on a calm ocean",
            "Draw a sunrise from memory",
        ]
        case 3: return [
            "Draw what freedom feels like",
            "Sketch your happiest moment today",
            "Draw a gift you would give yourself",
            "Doodle a garden you are planting",
            "Draw the view from your dream window",
            "Sketch your favorite season",
            "Create an abstract joy explosion",
            "Draw a constellation and name it",
        ]
        default: return [
            "Draw your future self",
            "Sketch the world you are building",
            "Draw what thriving looks like",
            "Doodle a crown for yourself",
            "Draw the best thing about today",
            "Sketch a landscape you want to visit",
            "Create an abstract celebration",
            "Draw what your clean lungs feel like",
        ]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let act = chosen {
                switch act {
                case .doodle:
                    DoodleCanvasView(
                        prompt: doodlePrompts[doodlePromptIndex % doodlePrompts.count],
                        onShuffle: {
                            doodlePromptIndex = (doodlePromptIndex + 1) % doodlePrompts.count
                        },
                        onComplete: onComplete
                    )
                case .poetry:
                    OneWordPoetryView(onComplete: onComplete)
                case .journal:
                    JournalEntryView(onComplete: onComplete)
                case .voiceMemo:
                    VoiceMemoView(onComplete: onComplete)
                }
            } else {
                pickerView
            }
        }
        .onAppear {
            doodlePromptIndex = Int.random(in: 0..<doodlePrompts.count)
        }
    }

    var pickerView: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

            VStack(spacing: 8) {
                Text("CREATIVE MOMENT")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text("Express yourself")
                    .font(.serif(30, weight: .bold)).foregroundColor(.white)
                Text("Pick one. Creative expression interrupts craving loops\nand reveals what's really going on inside.")
                    .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 30)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(ActivityType.allCases, id: \.rawValue) { act in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { chosen = act }
                    } label: {
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(act.accent.opacity(0.12))
                                    .frame(height: 70)
                                Image(systemName: act.icon)
                                    .font(.system(size: 26)).foregroundColor(act.accent)
                            }
                            VStack(spacing: 3) {
                                Text(act.label)
                                    .font(.sansRR(14, weight: .bold)).foregroundColor(.white)
                                Text(act.description)
                                    .font(.sansRR(10)).foregroundColor(.white.opacity(0.4))
                                    .lineLimit(2).multilineTextAlignment(.center)
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(act.accent.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 52)
        }
    }
}
