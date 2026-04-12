import SwiftUI

struct DoodleCanvasView: View {
    let prompt: String
    let onShuffle: (() -> Void)?
    let onComplete: (String) -> Void

    init(prompt: String, onShuffle: (() -> Void)? = nil, onComplete: @escaping (String) -> Void) {
        self.prompt = prompt
        self.onShuffle = onShuffle
        self.onComplete = onComplete
    }

    @StateObject private var audio = AmbientAudioManager.shared

    @State private var lines: [DoodleLine] = []
    @State private var currentLine: DoodleLine?
    @State private var selectedColor: Color = .white
    @State private var lineWidth: CGFloat = 4
    @State private var isDone = false

    private let palette: [Color] = [
        .white,
        Color(red: 0.35, green: 0.75, blue: 0.45),
        Color(red: 0.45, green: 0.65, blue: 0.85),
        Color(red: 0.85, green: 0.55, blue: 0.35),
        Color(red: 0.75, green: 0.45, blue: 0.65),
        Color(red: 0.92, green: 0.75, blue: 0.25),
    ]

    struct DoodleLine: Identifiable {
        let id = UUID()
        var points: [CGPoint]
        var color: Color
        var width: CGFloat
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("DOODLE")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.4)).tracking(1.8)
                Text(prompt)
                    .font(.serif(22, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).padding(.horizontal, 28)
                if let onShuffle {
                    Button {
                        onShuffle()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "shuffle")
                                .font(.system(size: 12, weight: .bold))
                            Text("New prompt")
                                .font(.sansRR(12, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.top, 16)

            Spacer(minLength: 12)

            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    guard let first = line.points.first else { continue }
                    path.move(to: first)
                    for point in line.points.dropFirst() { path.addLine(to: point) }
                    context.stroke(path, with: .color(line.color), style: StrokeStyle(lineWidth: line.width, lineCap: .round, lineJoin: .round))
                }
                if let cur = currentLine {
                    var path = Path()
                    guard let first = cur.points.first else { return }
                    path.move(to: first)
                    for point in cur.points.dropFirst() { path.addLine(to: point) }
                    context.stroke(path, with: .color(cur.color), style: StrokeStyle(lineWidth: cur.width, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 340)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        if currentLine == nil {
                            currentLine = DoodleLine(points: [val.location], color: selectedColor, width: lineWidth)
                        } else {
                            currentLine?.points.append(val.location)
                        }
                    }
                    .onEnded { _ in
                        if let line = currentLine { lines.append(line) }
                        currentLine = nil
                    }
            )
            .padding(.horizontal, 16)

            Spacer(minLength: 12)

            HStack(spacing: 12) {
                ForEach(palette.indices, id: \.self) { i in
                    Circle()
                        .fill(palette[i])
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.white, lineWidth: selectedColor == palette[i] ? 2.5 : 0))
                        .onTapGesture { selectedColor = palette[i] }
                }
                Spacer()
                Button {
                    if !lines.isEmpty { lines.removeLast() }
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white.opacity(0.5))
                        .frame(width: 36, height: 36).background(Color.white.opacity(0.1)).clipShape(Circle())
                }
                Button {
                    lines.removeAll()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .bold)).foregroundColor(.white.opacity(0.5))
                        .frame(width: 36, height: 36).background(Color.white.opacity(0.1)).clipShape(Circle())
                }
            }
            .padding(.horizontal, 22)

            Spacer(minLength: 16)

            Button {
                audio.stop()
                let desc = "User doodle on prompt: \(prompt). \(lines.count) strokes drawn."
                onComplete(desc)
            } label: {
                Text("Done drawing \u{2192}")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22).padding(.bottom, 52)
        }
        .onAppear { audio.play(.creative) }
        .onDisappear { audio.stop() }
    }
}
