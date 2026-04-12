import SwiftUI

struct JournalView: View {
    @EnvironmentObject var state: AppState
    @State private var journalText = ""
    @State private var promptIdx = 0
    @FocusState private var isEditing: Bool

    private let moods: [(String, String)] = [
        ("😣","Struggling"),("😟","Tough"),("😐","Okay"),("🙂","Good"),("😊","Great")
    ]

    var currentPrompt: String {
        RecoveryData.journalPrompts[promptIdx % RecoveryData.journalPrompts.count]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // Science context
                    Text("Writing externalizes cravings and triggers, helping your brain process them instead of act on them. Harvard Health recommends reviewing past recovery efforts as a key step in building resilience.")
                        .font(.sansRR(12))
                        .foregroundColor(.rText2)
                        .lineSpacing(3)
                        .padding(12)
                        .background(Color.rPurple.opacity(0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    RRCard {
                        VStack(alignment: .leading, spacing: 14) {
                            // Prompt
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("TODAY'S PROMPT")
                                        .font(.sansRR(10, weight: .bold))
                                        .foregroundColor(.rPurple)
                                        .tracking(1)
                                    Spacer()
                                    Button {
                                        withAnimation { promptIdx += 1 }
                                    } label: {
                                        Label("New", systemImage: "arrow.clockwise")
                                            .font(.sansRR(11, weight: .semibold))
                                            .foregroundColor(.rPurple)
                                    }
                                }
                                Text("\"\(currentPrompt)\"")
                                    .font(.sansRR(14))
                                    .foregroundColor(.rText)
                                    .lineSpacing(3)
                                    .italic()
                            }
                            .padding(12)
                            .background(Color.rPurple.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            // Text editor
                            TextEditor(text: $journalText)
                                .font(.sansRR(14))
                                .foregroundColor(.rText)
                                .frame(minHeight: 120)
                                .focused($isEditing)
                                .scrollContentBackground(.hidden)
                                .background(Color.rBg)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.rBg2, lineWidth: 1))
                                .overlay(alignment: .topLeading) {
                                    if journalText.isEmpty {
                                        Text("What's on your mind...")
                                            .font(.sansRR(14))
                                            .foregroundColor(.rText3)
                                            .padding(12)
                                            .allowsHitTesting(false)
                                    }
                                }

                            Button {
                                state.saveJournal(text: journalText)
                                journalText = ""
                                isEditing = false
                            } label: {
                                Text("Save Entry")
                                    .font(.sansRR(15, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.rPurple)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.rPurple.opacity(0.3), radius: 8, y: 3)
                            }
                            .disabled(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity(journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                        }
                    }

                    // Past entries
                    if !state.journalEntries.isEmpty {
                        RRCard {
                            VStack(alignment: .leading, spacing: 0) {
                                SectionHeader(icon: "📖", title: "Past Entries")
                                    .padding(.bottom, 12)

                                ForEach(state.journalEntries) { entry in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text("Day \(entry.dayNum) · \(entry.time.formatted(.dateTime.month(.abbreviated).day().hour().minute()))")
                                                .font(.sansRR(11))
                                                .foregroundColor(.rText3)
                                            Spacer()
                                            if let mood = entry.mood {
                                                Text(moods[mood].0).font(.system(size: 16))
                                            }
                                        }
                                        Text(entry.text)
                                            .font(.sansRR(13))
                                            .foregroundColor(.rText2)
                                            .lineSpacing(3)
                                    }
                                    .padding(.vertical, 10)
                                    if entry.id != state.journalEntries.last?.id {
                                        Divider().background(Color.rBg2)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color.rBg.ignoresSafeArea())
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .onTapGesture { isEditing = false }
        }
    }
}
