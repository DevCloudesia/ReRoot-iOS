import SwiftUI
import AVFoundation
import Speech

struct VoiceMemoView: View {
    let onComplete: (String) -> Void

    @State private var isRecording = false
    @State private var isPaused = false
    @State private var isDone = false
    @State private var elapsed: Int = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var waveAmplitudes: [CGFloat] = Array(repeating: 0.1, count: 40)
    @State private var permissionDenied = false
    @State private var promptIndex: Int = 0
    @State private var appear = false
    @State private var transcript: String = ""
    @State private var isTranscribing = false

    private let accent = Color(red: 0.85, green: 0.45, blue: 0.45)
    private let maxDuration = 60

    private let prompts = [
        "Say out loud what you're feeling right now.",
        "Talk to your future self. What do they need to hear?",
        "Describe your day without filtering anything.",
        "What would you say to someone going through the same thing?",
        "Name three things you're grateful for, out loud.",
        "Talk about what quitting means to you.",
        "Say something kind to yourself.",
        "Describe what you want your life to look like in one year.",
    ]

    private var fileURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("reroot_voice_memo.m4a")
    }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.05, blue: 0.05).ignoresSafeArea()
            RadialGradient(
                colors: [accent.opacity(isRecording ? 0.10 : 0.04), .clear],
                center: .center, startRadius: 20, endRadius: 350
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("VOICE MEMO")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(accent.opacity(0.6)).tracking(1.8)

                    if isDone {
                        Text("Recorded.")
                            .font(.serif(26, weight: .bold)).foregroundColor(.white)
                    } else {
                        Text(prompts[promptIndex % prompts.count])
                            .font(.serif(22, weight: .bold)).foregroundColor(.white)
                            .multilineTextAlignment(.center).lineSpacing(4)
                            .padding(.horizontal, 28)
                            .opacity(appear ? 1 : 0)
                            .animation(.easeOut(duration: 0.5), value: appear)
                    }

                    if !isDone && !isRecording {
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
                }
                .padding(.top, 20)

                Spacer(minLength: 24)

                if permissionDenied {
                    permissionView
                } else if isDone {
                    playbackView
                } else {
                    recordingView
                }

                Spacer(minLength: 24)

                if isDone {
                    VStack(spacing: 10) {
                        Button {
                            if transcript.isEmpty && !isTranscribing {
                                isTranscribing = true
                                transcribeAudio { text in
                                    transcript = text
                                    isTranscribing = false
                                    let output = text.isEmpty
                                        ? "Voice memo recorded (\(elapsed)s)"
                                        : "[voice_transcript]\(text)[/voice_transcript]"
                                    onComplete(output)
                                }
                            } else if !isTranscribing {
                                let output = transcript.isEmpty
                                    ? "Voice memo recorded (\(elapsed)s)"
                                    : "[voice_transcript]\(transcript)[/voice_transcript]"
                                onComplete(output)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isTranscribing {
                                    ProgressView().tint(.black).scaleEffect(0.8)
                                    Text("Processing...").font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                                } else {
                                    Text("Done \u{2192}").font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(Color.white).clipShape(Capsule())
                        }
                        .disabled(isTranscribing)
                        .padding(.horizontal, 22)

                        Button {
                            isDone = false
                            elapsed = 0
                            transcript = ""
                            waveAmplitudes = Array(repeating: 0.1, count: 40)
                        } label: {
                            Text("Record again").font(.sansRR(12)).foregroundColor(.white.opacity(0.35))
                        }
                        .disabled(isTranscribing)
                    }
                } else if !isRecording {
                    VStack(spacing: 12) {
                        Button { startRecording() } label: {
                            HStack(spacing: 8) {
                                Circle().fill(accent).frame(width: 12, height: 12)
                                Text("Start recording").font(.sansRR(16, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(
                                LinearGradient(colors: [accent, accent.opacity(0.7)],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(Capsule())
                            .shadow(color: accent.opacity(0.3), radius: 12, y: 4)
                        }
                        .padding(.horizontal, 22)

                        Button {
                            onComplete("Voice memo skipped")
                        } label: {
                            Text("Skip \u{2192}").font(.sansRR(12)).foregroundColor(.white.opacity(0.35))
                        }
                    }
                } else {
                    Button { stopRecording() } label: {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.white).frame(width: 14, height: 14)
                            Text("Stop recording").font(.sansRR(16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color.white).clipShape(Capsule())
                    }
                    .padding(.horizontal, 22)
                }

                Spacer(minLength: 52)
            }
        }
        .onAppear {
            promptIndex = Int.random(in: 0..<prompts.count)
            withAnimation { appear = true }
        }
        .onDisappear {
            timerTask?.cancel()
            audioRecorder?.stop()
            audioPlayer?.stop()
        }
    }

    var recordingView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(accent.opacity(isRecording ? 0.15 : 0.05))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isRecording)

                Circle()
                    .stroke(accent.opacity(0.2), lineWidth: 2)
                    .frame(width: 140, height: 140)

                if isRecording {
                    Circle()
                        .trim(from: 0, to: CGFloat(elapsed) / CGFloat(maxDuration))
                        .stroke(accent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: elapsed)
                }

                VStack(spacing: 6) {
                    if isRecording {
                        Circle().fill(accent).frame(width: 12, height: 12)
                        Text(timeString(elapsed))
                            .font(.sansRR(28, weight: .bold)).foregroundColor(.white).monospacedDigit()
                        Text("of \(maxDuration)s")
                            .font(.sansRR(10)).foregroundColor(accent.opacity(0.5))
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 36)).foregroundColor(accent.opacity(0.5))
                        Text("Ready")
                            .font(.sansRR(11, weight: .bold)).foregroundColor(accent.opacity(0.5))
                    }
                }
            }

            if isRecording {
                waveformView
            }
        }
    }

    var waveformView: some View {
        HStack(spacing: 2) {
            ForEach(0..<waveAmplitudes.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(accent.opacity(0.5))
                    .frame(width: 3, height: max(4, waveAmplitudes[i] * 50))
                    .animation(.easeOut(duration: 0.15), value: waveAmplitudes[i])
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 32)
    }

    var playbackView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.1))
                    .frame(width: 160, height: 160)

                Circle()
                    .stroke(accent.opacity(0.3), lineWidth: 2)
                    .frame(width: 120, height: 120)

                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40)).foregroundColor(accent)
                    Text(timeString(elapsed))
                        .font(.sansRR(18, weight: .bold)).foregroundColor(.white).monospacedDigit()
                }
            }

            Button {
                togglePlayback()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 12))
                    Text(isPlaying ? "Pause" : "Play back")
                        .font(.sansRR(13, weight: .semibold))
                }
                .foregroundColor(accent)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(accent.opacity(0.1)).clipShape(Capsule())
            }

            Text("Speaking your feelings out loud activates different neural pathways than thinking them. Your brain processes emotions more effectively through voice.")
                .font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 28)
        }
    }

    var permissionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 48)).foregroundColor(accent.opacity(0.5))
            Text("Microphone access is needed to record.")
                .font(.sansRR(14)).foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            Button {
                onComplete("Voice memo skipped (no mic access)")
            } label: {
                Text("Skip \u{2192}")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white.opacity(0.4)).clipShape(Capsule())
            }
            .padding(.horizontal, 22)
        }
    }

    func timeString(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    func startRecording() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted { beginRecording() } else { permissionDenied = true }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted { beginRecording() } else { permissionDenied = true }
                }
            }
        }
    }

    func beginRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try? session.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        audioRecorder = try? AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
        isRecording = true
        elapsed = 0

        timerTask = Task {
            while elapsed < maxDuration && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    audioRecorder?.updateMeters()
                    let power = audioRecorder?.averagePower(forChannel: 0) ?? -60
                    let normalized = max(0, (power + 50) / 50)
                    waveAmplitudes.removeFirst()
                    waveAmplitudes.append(CGFloat(normalized))
                }
                try? await Task.sleep(nanoseconds: 750_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { elapsed += 1 }
            }
            await MainActor.run { stopRecording() }
        }
    }

    func stopRecording() {
        timerTask?.cancel()
        audioRecorder?.stop()
        isRecording = false
        isDone = true
    }

    func togglePlayback() {
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
        } else {
            audioPlayer = try? AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
            isPlaying = true
        }
    }

    func transcribeAudio(completion: @escaping (String) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async { completion("") }
                return
            }
            guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
                DispatchQueue.main.async { completion("") }
                return
            }
            let request = SFSpeechURLRecognitionRequest(url: fileURL)
            request.shouldReportPartialResults = false
            recognizer.recognitionTask(with: request) { result, error in
                let text = result?.bestTranscription.formattedString ?? ""
                DispatchQueue.main.async { completion(text) }
            }
        }
    }
}
