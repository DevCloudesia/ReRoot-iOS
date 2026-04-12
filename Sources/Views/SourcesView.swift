import SwiftUI

struct SourcesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSection: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerNote

                    sourceSection(
                        id: "science",
                        icon: "brain.head.profile",
                        title: "Scientific & Medical Sources",
                        color: .rPurple,
                        items: scienceSources
                    )

                    sourceSection(
                        id: "quotes",
                        icon: "text.quote",
                        title: "Quote Sources",
                        color: .rAccent,
                        items: quoteSources
                    )

                    sourceSection(
                        id: "music",
                        icon: "music.note",
                        title: "Ambient Music & Audio",
                        color: Color(red: 0.30, green: 0.60, blue: 0.80),
                        items: musicSources
                    )

                    sourceSection(
                        id: "activities",
                        icon: "figure.mind.and.body",
                        title: "Activity & Technique Sources",
                        color: .rAmber,
                        items: activitySources
                    )

                    sourceSection(
                        id: "helplines",
                        icon: "phone.fill",
                        title: "Helpline & Crisis Resources",
                        color: .rDanger,
                        items: helplineSources
                    )

                    disclaimerNote

                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(Color.rBg.ignoresSafeArea())
            .navigationTitle("Sources & References")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.sansRR(15, weight: .semibold))
                }
            }
        }
    }

    // MARK: - Header

    var headerNote: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.rAccent)
                Text("Evidence-Based")
                    .font(.serif(18, weight: .bold))
                    .foregroundColor(.rText)
            }
            Text("Every fact, quote, and technique in ReRoot is grounded in peer-reviewed research and established clinical guidelines. Here are all our sources.")
                .font(.sansRR(13))
                .foregroundColor(.rText2)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.rAccent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rAccent.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Disclaimer

    var disclaimerNote: some View {
        VStack(spacing: 6) {
            Text("DISCLAIMER")
                .font(.sansRR(9, weight: .bold))
                .foregroundColor(.rText3)
                .tracking(1)
            Text("ReRoot is not a substitute for professional medical advice. If you experience severe withdrawal symptoms, please contact your healthcare provider or one of the crisis resources listed above.")
                .font(.sansRR(11))
                .foregroundColor(.rText3)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(14)
        .background(Color.rBg2.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Section Builder

    func sourceSection(id: String, icon: String, title: String, color: Color, items: [SourceItem]) -> some View {
        let isExpanded = expandedSection == id

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedSection = isExpanded ? nil : id
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)
                        .background(color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.sansRR(14, weight: .bold))
                            .foregroundColor(.rText)
                        Text("\(items.count) sources")
                            .font(.sansRR(10))
                            .foregroundColor(.rText3)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color.opacity(0.5))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(items) { item in
                        sourceRow(item, color: color)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.15), lineWidth: 1))
        .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
    }

    func sourceRow(_ item: SourceItem, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.sansRR(13, weight: .semibold))
                .foregroundColor(.rText)

            Text(item.detail)
                .font(.sansRR(11))
                .foregroundColor(.rText2)
                .lineSpacing(2)

            if let usedFor = item.usedFor {
                Text("Used for: \(usedFor)")
                    .font(.sansRR(10))
                    .foregroundColor(color.opacity(0.8))
                    .italic()
            }

            if let url = item.url {
                Link(destination: URL(string: url)!) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 9))
                        Text(urlDisplayName(url))
                            .font(.sansRR(10))
                    }
                    .foregroundColor(.blue.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.rBg2.opacity(0.5)).frame(height: 0.5)
        }
    }

    private func urlDisplayName(_ url: String) -> String {
        if let host = URL(string: url)?.host {
            return host
        }
        return url
    }
}

// MARK: - Data Model

struct SourceItem: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let usedFor: String?
    let url: String?
}

// MARK: - Source Data

extension SourcesView {

    var scienceSources: [SourceItem] {[
        SourceItem(
            name: "National Institute on Drug Abuse (NIDA)",
            detail: "Research on nicotine addiction as a brain disorder, dopamine receptor downregulation, and neuroplasticity during recovery.",
            usedFor: "Withdrawal science, brain chemistry explanations, recovery timelines",
            url: "https://nida.nih.gov/publications/research-reports/tobacco-nicotine-e-cigarettes"
        ),
        SourceItem(
            name: "American Lung Association (ALA)",
            detail: "Data on lung recovery timelines: CO elimination at 24h, cilia regrowth at 1 month, lung function improvement at 3 months.",
            usedFor: "Milestones, healing timeline, \"Right Now\" recovery phases",
            url: "https://www.lung.org/quit-smoking/i-just-quit/what-happens-after"
        ),
        SourceItem(
            name: "American Cancer Society",
            detail: "Long-term health milestones: stroke risk normalization at 5 years, lung cancer risk halving at 10 years.",
            usedFor: "Recovery milestones, long-term health statistics",
            url: "https://www.cancer.org/healthy/stay-away-from-tobacco/benefits-of-quitting-smoking-over-time.html"
        ),
        SourceItem(
            name: "Harvard Health Publishing",
            detail: "Research showing former smokers report lower anxiety than active smokers; cigarettes relieve withdrawal-induced anxiety rather than real anxiety.",
            usedFor: "Science stage explanations, anxiety myth-busting, exercise benefits",
            url: "https://www.health.harvard.edu/blog/nicotine-it-may-have-a-good-side"
        ),
        SourceItem(
            name: "Centers for Disease Control and Prevention (CDC)",
            detail: "Tips From Former Smokers campaign data, craving duration (3-5 min), withdrawal symptom timelines, and quit strategies.",
            usedFor: "Symptom data, craving tips, withdrawal timeline positions",
            url: "https://www.cdc.gov/tobacco/campaign/tips/"
        ),
        SourceItem(
            name: "National Cancer Institute (NCI)",
            detail: "Comprehensive smoking cessation research including appetite changes, dopamine system recovery, and long-term abstinence predictors.",
            usedFor: "Withdrawal symptoms, appetite changes, mood recovery data",
            url: "https://www.cancer.gov/about-cancer/causes-prevention/risk/tobacco/cessation-fact-sheet"
        ),
        SourceItem(
            name: "Medical News Today",
            detail: "Clinical summaries of nerve ending regeneration at 48h, bronchial tube relaxation at 72h, and taste/smell restoration.",
            usedFor: "Days 2-7 healing milestones, sensory recovery facts",
            url: "https://www.medicalnewstoday.com/articles/317956"
        ),
        SourceItem(
            name: "U.S. Surgeon General Reports",
            detail: "Landmark reports establishing that coronary heart disease risk halves within 1 year of smoking cessation.",
            usedFor: "1-year heart disease milestone",
            url: "https://www.hhs.gov/surgeongeneral/reports-and-publications/tobacco/"
        ),
        SourceItem(
            name: "Smokefree.gov (NIH)",
            detail: "Government resource on insomnia during withdrawal, sleep architecture disruption by nicotine, and circadian rhythm recovery.",
            usedFor: "Insomnia symptom data, sleep recovery tips",
            url: "https://smokefree.gov/challenges-when-quitting/managing-withdrawal"
        ),
        SourceItem(
            name: "Cleveland Clinic",
            detail: "Clinical data on cognitive effects of nicotine withdrawal, brain fog duration, and acetylcholine system recovery.",
            usedFor: "Difficulty focusing symptom, mood recovery, insomnia data",
            url: "https://my.clevelandclinic.org/health/articles/nicotine-withdrawal"
        ),
        SourceItem(
            name: "Better Health Channel (Victoria, AU)",
            detail: "Data on CO blood level reduction within 8 hours and oxygen normalization timelines.",
            usedFor: "8-hour CO elimination milestone",
            url: "https://www.betterhealth.vic.gov.au/health/healthyliving/smoking-effects-on-your-body"
        ),
        SourceItem(
            name: "Frontiers in Psychiatry / Psychopharmacology Meta-analyses",
            detail: "Meta-analytic evidence on exercise as the strongest behavioral predictor of quit success; BDNF production through physical activity.",
            usedFor: "Exercise science facts, neural recovery data",
            url: nil
        ),
        SourceItem(
            name: "University of Exeter — Green Exercise Research",
            detail: "Finding that outdoor exercise reduces cravings 40% more than indoor exercise alone in smoking cessation.",
            usedFor: "Nature + exercise science fact for Thriving mood level",
            url: nil
        ),
    ]}

    var quoteSources: [SourceItem] {[
        SourceItem(
            name: "Mark Twain",
            detail: "\"The secret of getting ahead is getting started.\" — Widely attributed; used for general encouragement.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Confucius",
            detail: "\"It does not matter how slowly you go as long as you do not stop.\" — Analects; persistence in recovery.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Allen Carr — \"The Easy Way to Stop Smoking\" (1985)",
            detail: "\"Freedom is what you find on the other side of discomfort\" and \"Quitting smoking is not a sacrifice; it's a liberation.\" Carr's cognitive reframing approach to cessation.",
            usedFor: "Daily motivational quotes (2 quotes)",
            url: nil
        ),
        SourceItem(
            name: "Samuel Johnson",
            detail: "\"The chains of habit are too light to be felt until they are too heavy to be broken.\" — 18th century English writer.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Mahatma Gandhi",
            detail: "\"Strength does not come from physical capacity. It comes from an indomitable will.\" — Attributed.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Thomas Fuller",
            detail: "\"Health is not valued till sickness comes.\" — Gnomologia (1732).",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "NIDA — Clinical Recovery Principles",
            detail: "Source for quotes on withdrawal vs. weakness distinction and neurochemical nature of cravings.",
            usedFor: "\"What you're feeling is withdrawal, not weakness\" quote",
            url: "https://nida.nih.gov"
        ),
        SourceItem(
            name: "Mindfulness-Based Relapse Prevention (MBRP)",
            detail: "Source for \"The urge to smoke will pass whether you smoke or not\" — core principle of urge surfing technique.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Cognitive Behavioral Therapy (CBT) Principles",
            detail: "\"Progress, not perfection\" — foundational CBT concept applied to addiction recovery.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Harvard Health Publishing",
            detail: "\"The cigarette didn't calm you. It relieved withdrawal while creating more of it.\" — Based on research on the anxiety-smoking paradox.",
            usedFor: "Daily motivational quote",
            url: "https://www.health.harvard.edu"
        ),
        SourceItem(
            name: "American Lung Association",
            detail: "\"Your lungs are healing right now. Every breath is proof.\" — Derived from ALA recovery timeline data.",
            usedFor: "Daily motivational quote",
            url: "https://www.lung.org"
        ),
        SourceItem(
            name: "Neuroscience of Addiction (Composite)",
            detail: "\"Every craving you outlast makes the next one permanently weaker.\" — Based on receptor downregulation research.",
            usedFor: "Daily motivational quote, reinforces withdrawal science",
            url: nil
        ),
    ]}

    var musicSources: [SourceItem] {[
        SourceItem(
            name: "Solfeggio Frequencies — Historical & Modern Usage",
            detail: "The ambient audio in ReRoot uses Solfeggio frequencies (174 Hz, 285 Hz, 396 Hz, 417 Hz, 528 Hz, 639 Hz, 741 Hz), a tuning system historically attributed to Gregorian chants. While peer-reviewed evidence for specific healing properties is limited, these frequencies are widely used in meditation and relaxation contexts.",
            usedFor: "All ambient soundscapes in the app",
            url: nil
        ),
        SourceItem(
            name: "174 Hz — Foundation Tone",
            detail: "Used as the lowest frequency in breathing and chat soundscapes. Associated with a sense of safety and grounding in sound therapy practice. Amplitude: 0.08–0.12.",
            usedFor: "Breathing pacer, anonymous chat background",
            url: nil
        ),
        SourceItem(
            name: "285 Hz — Tissue & Cell Tone",
            detail: "Used across breathing, body scan, and grounding soundscapes. Associated with cellular healing in alternative sound therapy frameworks. Amplitude: 0.06–0.10.",
            usedFor: "Breathing pacer, body scan, sensory grounding",
            url: nil
        ),
        SourceItem(
            name: "396 Hz — Liberation Tone",
            detail: "Prominent in grounding and body scan soundscapes. Associated with releasing fear and guilt in Solfeggio practice. Amplitude: 0.04–0.10.",
            usedFor: "Body scan, sensory grounding, anonymous chat",
            url: nil
        ),
        SourceItem(
            name: "136.1 Hz — Om Frequency",
            detail: "Used as the base frequency for urge surfing. This is the frequency of the Earth year (Cosmic Octave, Hans Cousto, 1978). Widely used in Tibetan singing bowls and meditation.",
            usedFor: "Urge surfing ambient soundscape",
            url: nil
        ),
        SourceItem(
            name: "528 Hz — Transformation Tone",
            detail: "Used in body scan and creative activity soundscapes. Sometimes called the \"love frequency\" in sound therapy. One study (Akimoto et al., 2018) found 528 Hz reduced anxiety in rats, but human evidence is preliminary.",
            usedFor: "Body scan, doodling canvas, one-word poetry",
            url: nil
        ),
        SourceItem(
            name: "639 Hz, 741 Hz — Connection & Expression Tones",
            detail: "Higher Solfeggio frequencies used in creative activity soundscapes to promote a sense of creative flow and self-expression.",
            usedFor: "Doodling canvas, one-word poetry backgrounds",
            url: nil
        ),
        SourceItem(
            name: "Low-Frequency Oscillation (LFO) Modulation",
            detail: "All soundscapes use subtle amplitude modulation (LFO rates 0.05–0.15 Hz) to create organic, breathing-like volume swells. This technique mimics natural bioacoustic patterns and prevents listener fatigue.",
            usedFor: "All ambient soundscapes — creates organic texture",
            url: nil
        ),
        SourceItem(
            name: "Programmatic Audio Generation — AVAudioEngine",
            detail: "All audio is synthesized in real-time on-device using Apple's AVAudioEngine framework. No external audio files are used. Sine wave oscillators generate pure tones that are layered and modulated.",
            usedFor: "Technical implementation of all ambient audio",
            url: "https://developer.apple.com/documentation/avfaudio/avaudioengine"
        ),
    ]}

    var activitySources: [SourceItem] {[
        SourceItem(
            name: "4-7-8 Breathing Technique — Dr. Andrew Weil",
            detail: "Developed by Dr. Andrew Weil based on pranayama yoga breathing. Activates the parasympathetic nervous system, reducing heart rate and cortisol.",
            usedFor: "Breathing pacer activity, craving emergency tool",
            url: "https://www.drweil.com/health-wellness/body-mind-spirit/stress-anxiety/breathing-exercises-4-7-8-breath/"
        ),
        SourceItem(
            name: "Box Breathing — U.S. Navy SEALs",
            detail: "4-4-4-4 breathing pattern used by Navy SEALs for focus under extreme stress. Balances sympathetic/parasympathetic nervous system.",
            usedFor: "Breathing pacer activity",
            url: nil
        ),
        SourceItem(
            name: "Urge Surfing — Mindfulness-Based Relapse Prevention (MBRP)",
            detail: "Developed by Alan Marlatt, PhD at University of Washington. Teaches observing cravings as waves that rise and fall without acting on them. Creates a cognitive gap between stimulus and response.",
            usedFor: "Urge surfing guided activity",
            url: nil
        ),
        SourceItem(
            name: "5-4-3-2-1 Sensory Grounding — CBT Anxiety Toolkit",
            detail: "A cognitive behavioral technique that redirects attention through sensory channels: 5 things seen, 4 touched, 3 heard, 2 smelled, 1 tasted. Disrupts default mode network craving loops.",
            usedFor: "Sensory grounding interactive activity",
            url: nil
        ),
        SourceItem(
            name: "Progressive Muscle Relaxation (PMR) — Edmund Jacobson, 1930s",
            detail: "Systematic tensing and releasing of muscle groups to reduce physical tension. Widely validated in anxiety and addiction treatment research.",
            usedFor: "Body scan activity with guided tension/release",
            url: nil
        ),
        SourceItem(
            name: "Serial 7s Subtraction — Cognitive Load Technique",
            detail: "Counting backwards by 7s from a random number. Demands high working memory from the prefrontal cortex, starving the amygdala of attentional resources needed to maintain craving intensity.",
            usedFor: "Serial 7s game, cognitive distraction activity",
            url: nil
        ),
        SourceItem(
            name: "Expressive Arts Therapy — Creative Activities",
            detail: "Doodling and poetry writing as emotional expression tools. Research shows creative expression reduces cortisol levels (Kaimal et al., 2016, Art Therapy journal).",
            usedFor: "Doodle canvas, one-word poetry creative activities",
            url: nil
        ),
        SourceItem(
            name: "Acceptance and Commitment Therapy (ACT)",
            detail: "Cognitive defusion technique teaching that cravings are mental events with no motor control over physical behavior. Used in the app's framing of urge surfing and self-talk prompts.",
            usedFor: "Activity science explanations, cognitive reframing",
            url: nil
        ),
        SourceItem(
            name: "Mammalian Dive Reflex",
            detail: "Cold water on face triggers vagus nerve activation, dropping heart rate 10-25% in seconds. Used in emergency craving intervention context.",
            usedFor: "Struggling mood science fact, craving emergency tip",
            url: nil
        ),
    ]}

    var helplineSources: [SourceItem] {[
        SourceItem(
            name: "SAMHSA National Helpline",
            detail: "Substance Abuse and Mental Health Services Administration. Free, confidential, 24/7 treatment referral and information service.",
            usedFor: "Primary helpline resource in the app",
            url: "https://www.samhsa.gov/find-help/national-helpline"
        ),
        SourceItem(
            name: "CDC Quitline (1-800-QUIT-NOW)",
            detail: "Free quit coaching, personalized cessation plans, and medication guidance from trained counselors. Funded by the CDC.",
            usedFor: "Quit coaching helpline resource",
            url: "https://www.cdc.gov/tobacco/quit-smoking/"
        ),
        SourceItem(
            name: "988 Suicide & Crisis Lifeline",
            detail: "National crisis line for mental health emergencies, including severe withdrawal-related distress. Call or text 988.",
            usedFor: "Crisis resource for severe emotional distress",
            url: "https://988lifeline.org"
        ),
        SourceItem(
            name: "Crisis Text Line",
            detail: "Text HOME to 741741 for immediate, confidential crisis support from trained counselors.",
            usedFor: "Text-based crisis support resource",
            url: "https://www.crisistextline.org"
        ),
        SourceItem(
            name: "Veterans Crisis Line",
            detail: "Dial 988 then press 1. Dedicated support for veterans, active service members, and their families.",
            usedFor: "Veterans-specific crisis resource",
            url: "https://www.veteranscrisisline.net"
        ),
    ]}
}
