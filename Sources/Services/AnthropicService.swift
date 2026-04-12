import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: String
    var content: String
}

actor AnthropicService {
    static let shared = AnthropicService()
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-haiku-4-5-20251001"

    func streamChat(
        messages: [ChatMessage],
        systemPrompt: String
    ) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                guard let apiKey = KeychainManager.anthropicKey else {
                    continuation.yield("[Error: No API key found]")
                    continuation.finish()
                    return
                }

                var request = URLRequest(url: endpoint)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

                let body: [String: Any] = [
                    "model": model,
                    "max_tokens": 1024,
                    "stream": true,
                    "system": systemPrompt,
                    "messages": messages.map { ["role": $0.role, "content": $0.content] }
                ]

                guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
                    continuation.yield("[Error: Failed to encode request]")
                    continuation.finish()
                    return
                }
                request.httpBody = jsonData

                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                        let httpResp = response as? HTTPURLResponse
                        continuation.yield("[Error: HTTP \(httpResp?.statusCode ?? 0)]")
                        continuation.finish()
                        return
                    }

                    for try await line in bytes.lines {
                        if line.hasPrefix("data: ") {
                            let jsonStr = String(line.dropFirst(6))
                            if jsonStr == "[DONE]" { break }
                            if let data = jsonStr.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                let eventType = json["type"] as? String ?? ""
                                if eventType == "content_block_delta",
                                   let delta = json["delta"] as? [String: Any],
                                   let text = delta["text"] as? String {
                                    continuation.yield(text)
                                }
                                if eventType == "message_stop" { break }
                            }
                        }
                    }
                } catch {
                    continuation.yield("[Connection error: \(error.localizedDescription)]")
                }
                continuation.finish()
            }
        }
    }
}
