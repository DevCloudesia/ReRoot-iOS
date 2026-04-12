import SwiftUI

struct ClaudeChatView: View {
    let mood: Int
    let dayNum: Int
    let elapsed: TimeInterval
    let creativeOutput: String
    var reportedLapse: Bool = false
    var almostSlipped: Bool = false
    var lapseCount: Int = 0
    var lapseTriggers: [String] = []
    var almostStoppers: [String] = []
    var almostTriggers: [String] = []
    var cravingIntensity: Int = 0
    var userName: String = ""
    var quitMotivation: String = ""
    let onDone: (Int?) -> Void

    @StateObject private var audio = AmbientAudioManager.shared

    @State private var messages: [ChatMessage] = []
    @State private var userInput = ""
    @State private var isStreaming = false
    @State private var streamingText = ""
    @State private var appear = false
    @State private var chatStarted = false

    private let moodLabels = ["Struggling", "Hanging in", "Okay", "Good", "Great"]

    private var contextBlock: String {
        var lines: [String] = []
        let name = userName.isEmpty ? "This person" : userName
        lines.append("\(name) is on Day \(dayNum) of quitting smoking (\(Int(elapsed / 3600)) hours smoke-free).")
        lines.append("Self-reported mood: \(moodLabels[min(max(mood, 0), 4)]) (\(mood)/4).")
        lines.append("Craving intensity: \(cravingIntensity)/10.")

        if reportedLapse {
            lines.append("IMPORTANT: They honestly reported smoking \(lapseCount) cigarette\(lapseCount == 1 ? "" : "s") today.")
            if !lapseTriggers.isEmpty {
                lines.append("Their self-identified triggers: \(lapseTriggers.joined(separator: ", ")).")
            }
        } else if almostSlipped {
            lines.append("They almost smoked but held on.")
            if !almostStoppers.isEmpty {
                lines.append("What stopped them: \(almostStoppers.joined(separator: ", ")).")
            }
            if !almostTriggers.isEmpty {
                lines.append("What nearly triggered them: \(almostTriggers.joined(separator: ", ")).")
            }
        } else {
            lines.append("They stayed smoke-free since their last check-in.")
        }

        if !quitMotivation.isEmpty {
            lines.append("Their reason for quitting: \(quitMotivation).")
        }

        if !creativeOutput.isEmpty {
            lines.append("They just created something (drawing/poem/journal): \"\(creativeOutput)\"")
        }

        return lines.joined(separator: "\n")
    }

    private var systemPrompt: String {
        """
        You are a warm, caring anonymous support companion inside ReRoot, a tobacco cessation app. \
        Your only goal is to help this person stay away from tobacco.

        Here is everything you know about them right now:
        \(contextBlock)

        Your job:
        - Help them stay away from tobacco. That is your #1 priority. Everything you say should \
          serve that goal.
        - Be warm, genuine, and human. Talk like a kind friend, not a therapist or textbook.
        - Use their name if you have it. Make it personal.
        - If they slipped, do NOT shame them. Acknowledge their courage in being honest. Explore \
          the triggers they shared. Help them make a concrete plan for next time those triggers come up.
        - If they almost slipped, celebrate that they held on. Reinforce what worked. Discuss \
          the triggers so they're better prepared next time.
        - If they're craving hard (7+), be present and grounding. Remind them cravings pass in 3-5 \
          minutes. Give them one specific thing to do right now.
        - If they shared a voice memo transcript, respond to what they SAID, not the fact that it's \
          a voice memo. Treat it like they just told you those words directly.
        - If they shared a drawing or poem, briefly acknowledge it warmly, then move to what matters: \
          how they're doing with quitting.
        - If they have a quit motivation, weave it in when it would help them stay strong.
        - ALWAYS tie the conversation back to their quit journey. Don't get sidetracked into generic \
          wellness chat. This is about tobacco.
        - Keep responses short (2-4 sentences). This is a conversation, not a lecture.
        - Ask follow-up questions about their triggers, cravings, and strategies.
        - NEVER suggest smoking is okay. NEVER reveal you are AI.
        - Use natural, warm language. No em-dashes. No clinical jargon.
        - This chat is 100% anonymous and zero-trace. Reassure them if asked.

        IMPORTANT: If the user signals they want to stop (goodbye, thanks, "I'm good", etc.), \
        give a brief warm closing. Do NOT keep asking questions.

        In your VERY LAST message only, include a hidden mood assessment at the end:
        [MOOD_ASSESSMENT:X] where X is 0-4 (0=Struggling, 4=Great).
        Base this on the conversation tone, not just their words.
        """
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if !chatStarted {
                welcomeView
            } else {
                chatContent
                inputBar
            }
        }
        .onAppear {
            KeychainManager.ensureAnthropicKey()
            audio.play(.chat)
            withAnimation { appear = true }
        }
        .onDisappear { audio.stop() }
    }

    var headerBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 14)).foregroundColor(.white.opacity(0.5))
            Text("ANONYMOUS SUPPORT CHAT")
                .font(.sansRR(10, weight: .bold)).foregroundColor(.white.opacity(0.5)).tracking(1.2)
            Spacer()
            if chatStarted {
                Button {
                    endChat()
                } label: {
                    Text("End Chat")
                        .font(.sansRR(11, weight: .bold)).foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.white.opacity(0.08)).clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 10)
    }

    var welcomeView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.07)).frame(width: 80, height: 80)
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 32)).foregroundColor(.white.opacity(0.6))
                }

                VStack(spacing: 8) {
                    Text("Someone's here for you")
                        .font(.serif(26, weight: .bold)).foregroundColor(.white)
                    Text("This chat is 100% anonymous.\nNothing is stored. Nothing leaves this device.")
                        .font(.sansRR(13)).foregroundColor(.white.opacity(0.45))
                        .multilineTextAlignment(.center).lineSpacing(3)
                }

                VStack(spacing: 4) {
                    privacyRow(icon: "lock.fill", text: "End-to-end private. Nothing saved.")
                    privacyRow(icon: "person.fill.questionmark", text: "No names, no accounts, fully anonymous.")
                    privacyRow(icon: "heart.fill", text: "No judgment. Always on your side.")
                }
                .padding(.horizontal, 32)
            }
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.6), value: appear)

            Spacer()

            Button {
                withAnimation { chatStarted = true }
                sendInitialMessage()
            } label: {
                Text("Start chatting")
                    .font(.sansRR(16, weight: .bold)).foregroundColor(.black)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color.white).clipShape(Capsule())
            }
            .padding(.horizontal, 22).padding(.bottom, 52)
            .opacity(appear ? 1 : 0).animation(.easeOut(duration: 0.5).delay(0.3), value: appear)
        }
    }

    func privacyRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(.white.opacity(0.35))
                .frame(width: 20)
            Text(text).font(.sansRR(12)).foregroundColor(.white.opacity(0.4))
            Spacer()
        }
    }

    var chatContent: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { msg in
                        chatBubble(msg)
                    }
                    if isStreaming {
                        streamingBubble
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, 16).padding(.top, 8)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .onChange(of: streamingText) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    func chatBubble(_ msg: ChatMessage) -> some View {
        let isUser = msg.role == "user"
        var cleaned = msg.content.replacingOccurrences(
            of: "\\[MOOD_ASSESSMENT:\\d\\]",
            with: "",
            options: .regularExpression
        )
        if isUser && msg.id == messages.first?.id {
            cleaned = userFacingFirstMessage
        }
        let displayText = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        return HStack {
            if isUser { Spacer(minLength: 60) }
            Text(displayText)
                .font(.sansRR(14)).foregroundColor(isUser ? .white : .white.opacity(0.85))
                .lineSpacing(3).padding(.horizontal, 14).padding(.vertical, 10)
                .background(isUser ? Color(red: 0.25, green: 0.55, blue: 0.35) : Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if !isUser { Spacer(minLength: 60) }
        }
    }

    var streamingBubble: some View {
        HStack {
            HStack(spacing: 6) {
                if streamingText.isEmpty {
                    ForEach(0..<3) { i in
                        Circle().fill(Color.white.opacity(0.3)).frame(width: 6, height: 6)
                            .scaleEffect(isStreaming ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: isStreaming)
                    }
                } else {
                    Text(streamingText)
                        .font(.sansRR(14)).foregroundColor(.white.opacity(0.85))
                        .lineSpacing(3)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            Spacer(minLength: 60)
        }
    }

    var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Type a message...", text: $userInput, axis: .vertical)
                .font(.sansRR(14)).foregroundColor(.white)
                .lineLimit(4)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))

            Button {
                sendUserMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(userInput.trimmingCharacters(in: .whitespaces).isEmpty ? .white.opacity(0.15) : .white)
            }
            .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isStreaming)
        }
        .padding(.horizontal, 16).padding(.vertical, 10).padding(.bottom, 20)
    }

    private var userFacingFirstMessage: String {
        let name = userName.isEmpty ? "" : " I'm \(userName)."
        if reportedLapse {
            return "I had a cigarette today.\(name) Can we talk?"
        } else if almostSlipped {
            return "I almost smoked but held on.\(name) Can we talk?"
        } else {
            return "I stayed smoke-free today.\(name) Just wanted to chat."
        }
    }

    private var voiceTranscript: String {
        if creativeOutput.contains("[voice_transcript]"),
           let start = creativeOutput.range(of: "[voice_transcript]"),
           let end = creativeOutput.range(of: "[/voice_transcript]") {
            return String(creativeOutput[start.upperBound..<end.lowerBound])
        }
        return ""
    }

    private var displayCreativeOutput: String {
        if !voiceTranscript.isEmpty { return "Voice memo recorded" }
        return creativeOutput
    }

    func sendInitialMessage() {
        let hiddenContext = buildFullContext()
        messages.append(ChatMessage(role: "user", content: hiddenContext))
        streamResponse()
    }

    private func buildFullContext() -> String {
        var parts: [String] = []
        let name = userName.isEmpty ? "Hey" : "Hey, I'm \(userName)."
        parts.append(name)

        if reportedLapse {
            parts.append("I had \(lapseCount) cigarette\(lapseCount == 1 ? "" : "s") today.")
            if !lapseTriggers.isEmpty {
                parts.append("My triggers were: \(lapseTriggers.joined(separator: ", ")).")
            }
        } else if almostSlipped {
            parts.append("I almost smoked today but I held on.")
            if !almostStoppers.isEmpty {
                parts.append("What stopped me: \(almostStoppers.joined(separator: ", ")).")
            }
            if !almostTriggers.isEmpty {
                parts.append("What almost got me: \(almostTriggers.joined(separator: ", ")).")
            }
        } else {
            parts.append("I stayed smoke-free today.")
        }

        parts.append("I'm feeling \(moodLabels[min(max(mood, 0), 4)].lowercased()) right now.")
        parts.append("Craving level: \(cravingIntensity)/10.")

        if !voiceTranscript.isEmpty {
            parts.append("I just recorded a voice memo. Here's what I said: \"\(voiceTranscript)\"")
        } else if !creativeOutput.isEmpty && !creativeOutput.contains("skipped") {
            parts.append("I just created something: \(creativeOutput)")
        }

        parts.append("Can we talk?")
        return parts.joined(separator: " ")
    }

    func sendUserMessage() {
        let text = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(role: "user", content: text))
        userInput = ""
        streamResponse()
    }

    private let goodbyePatterns = [
        "bye", "goodbye", "good bye", "thanks", "thank you", "i'm good",
        "im good", "gotta go", "that's all", "thats all", "i'm done",
        "im done", "see you", "see ya", "later", "peace", "take care",
        "have a good", "good night", "goodnight", "i should go", "ttyl",
    ]

    func streamResponse() {
        isStreaming = true
        streamingText = ""

        let lastUserMsg = messages.last(where: { $0.role == "user" })?.content.lowercased() ?? ""
        let userWantsToLeave = goodbyePatterns.contains(where: { lastUserMsg.contains($0) })
        let prompt = userWantsToLeave
            ? systemPrompt + "\nThe user is saying goodbye. This is your final response. Include [MOOD_ASSESSMENT:X] at the end."
            : systemPrompt

        Task {
            let stream = await AnthropicService.shared.streamChat(
                messages: messages,
                systemPrompt: prompt
            )
            var full = ""
            for await chunk in stream {
                full += chunk
                await MainActor.run { streamingText = full }
            }
            await MainActor.run {
                if !full.isEmpty {
                    messages.append(ChatMessage(role: "assistant", content: full))
                }
                streamingText = ""
                isStreaming = false

                if let assessment = parseMoodAssessment(full) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        onDone(assessment)
                    }
                }
            }
        }
    }

    func endChat() {
        if !isStreaming {
            messages.append(ChatMessage(role: "user", content: "Thank you, I'm ready to move on now."))
            isStreaming = true
            streamingText = ""

            Task {
                let stream = await AnthropicService.shared.streamChat(
                    messages: messages,
                    systemPrompt: systemPrompt + "\nThis is the user's final message. Include [MOOD_ASSESSMENT:X] at the end."
                )
                var full = ""
                for await chunk in stream {
                    full += chunk
                    await MainActor.run { streamingText = full }
                }
                await MainActor.run {
                    if !full.isEmpty {
                        messages.append(ChatMessage(role: "assistant", content: full))
                    }
                    streamingText = ""
                    isStreaming = false

                    let reassessed = parseMoodAssessment(full)
                    onDone(reassessed)
                }
            }
        } else {
            onDone(nil)
        }
    }

    func parseMoodAssessment(_ text: String) -> Int? {
        guard let range = text.range(of: "\\[MOOD_ASSESSMENT:(\\d)\\]", options: .regularExpression),
              let digit = text[range].first(where: { $0.isNumber }),
              let val = Int(String(digit)),
              (0...4).contains(val)
        else { return nil }
        return val
    }
}
