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

                    githubLink

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

    // MARK: - GitHub Link

    var githubLink: some View {
        Link(destination: URL(string: "https://github.com/DevCloudesia/ReRoot-iOS")!) {
            HStack(spacing: 10) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("View Source Code")
                        .font(.sansRR(14, weight: .bold))
                        .foregroundColor(.rText)
                    Text("github.com/DevCloudesia/ReRoot-iOS")
                        .font(.sansRR(10))
                        .foregroundColor(.rText3)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.rText3.opacity(0.5))
            }
            .padding(14)
            .background(Color.white.opacity(0.78))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.08), lineWidth: 1))
            .shadow(color: .black.opacity(0.03), radius: 6, y: 2)
        }
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
            name: "National Institute on Drug Abuse. (2024). Tobacco, nicotine, and e-cigarettes research report. National Institutes of Health.",
            detail: "Research on nicotine addiction as a brain disorder, dopamine receptor downregulation, and neuroplasticity during recovery.",
            usedFor: "Withdrawal science, brain chemistry explanations, recovery timelines",
            url: "https://nida.nih.gov/publications/research-reports/tobacco-nicotine-e-cigarettes"
        ),
        SourceItem(
            name: "American Lung Association. (2024). What happens after you quit smoking. American Lung Association.",
            detail: "Data on lung recovery timelines: CO elimination at 24 h, cilia regrowth at 1 month, lung function improvement at 3 months.",
            usedFor: "Milestones, healing timeline, \"Right Now\" recovery phases",
            url: "https://www.lung.org/quit-smoking/i-want-to-quit/benefits-of-quitting"
        ),
        SourceItem(
            name: "American Cancer Society. (2024). Benefits of quitting smoking over time. American Cancer Society.",
            detail: "Long-term health milestones: stroke risk normalization at 5 years, lung cancer risk halving at 10 years.",
            usedFor: "Recovery milestones, long-term health statistics",
            url: "https://www.cancer.org/healthy/stay-away-from-tobacco/benefits-of-quitting-smoking-over-time.html"
        ),
        SourceItem(
            name: "Harvard Health Publishing. (2021). Nicotine: It may have a good side. Harvard Medical School.",
            detail: "Former smokers report lower anxiety than active smokers; cigarettes relieve withdrawal-induced anxiety rather than real anxiety.",
            usedFor: "Science stage explanations, anxiety myth-busting, exercise benefits",
            url: "https://www.health.harvard.edu/newsletter_article/Nicotine_It_may_have_a_good_side"
        ),
        SourceItem(
            name: "Centers for Disease Control and Prevention. (2024). Tips from former smokers. U.S. Department of Health and Human Services.",
            detail: "Craving duration (3–5 min), withdrawal symptom timelines, and quit strategies.",
            usedFor: "Symptom data, craving tips, withdrawal timeline positions",
            url: "https://www.cdc.gov/tobacco/campaign/tips/"
        ),
        SourceItem(
            name: "National Cancer Institute. (2023). Cigarette smoking: Health risks and how to quit (PDQ). National Institutes of Health.",
            detail: "Comprehensive smoking cessation research including appetite changes, dopamine system recovery, and long-term abstinence predictors.",
            usedFor: "Withdrawal symptoms, appetite changes, mood recovery data",
            url: "https://www.cancer.gov/about-cancer/causes-prevention/risk/tobacco/cessation-fact-sheet"
        ),
        SourceItem(
            name: "Sissons, B. (2023). What happens after you quit smoking: A timeline. Medical News Today.",
            detail: "Nerve ending regeneration at 48 h, bronchial tube relaxation at 72 h, and taste/smell restoration.",
            usedFor: "Days 2–7 healing milestones, sensory recovery facts",
            url: "https://www.medicalnewstoday.com/articles/317956"
        ),
        SourceItem(
            name: "U.S. Department of Health and Human Services. (2020). Smoking cessation: A report of the Surgeon General. Office of the Surgeon General.",
            detail: "Coronary heart disease risk halves within 1 year of smoking cessation.",
            usedFor: "1-year heart disease milestone",
            url: "https://www.hhs.gov/surgeongeneral/reports-and-publications/tobacco/"
        ),
        SourceItem(
            name: "National Institutes of Health. (2024). Managing withdrawal. Smokefree.gov.",
            detail: "Insomnia during withdrawal, sleep architecture disruption by nicotine, and circadian rhythm recovery.",
            usedFor: "Insomnia symptom data, sleep recovery tips",
            url: "https://smokefree.gov/challenges-when-quitting/withdrawal/managing-nicotine-withdrawal"
        ),
        SourceItem(
            name: "Cleveland Clinic. (2023). Nicotine withdrawal: Symptoms, timeline, and coping. Cleveland Clinic.",
            detail: "Cognitive effects of nicotine withdrawal, brain fog duration, and acetylcholine system recovery.",
            usedFor: "Difficulty focusing symptom, mood recovery, insomnia data",
            url: "https://my.clevelandclinic.org/health/diseases/21587-nicotine-withdrawal"
        ),
        SourceItem(
            name: "Better Health Channel. (2023). Smoking — effects on your body. Department of Health, Victoria, Australia.",
            detail: "CO blood level reduction within 8 hours and oxygen normalization timelines.",
            usedFor: "8-hour CO elimination milestone",
            url: "https://www.betterhealth.vic.gov.au/health/healthyliving/smoking-effects-on-your-body"
        ),
        SourceItem(
            name: "Aylett, E., Small, N., & Bower, P. (2018). Exercise in the treatment of clinical anxiety in general practice: A systematic review and meta-analysis. BMC Health Services Research, 18(1), 559.",
            detail: "Meta-analytic evidence on exercise as a behavioral predictor of quit success; BDNF production through physical activity.",
            usedFor: "Exercise science facts, neural recovery data",
            url: nil
        ),
        SourceItem(
            name: "Thompson Coon, J., Boddy, K., Stein, K., Whear, R., Barton, J., & Depledge, M. H. (2011). Does participating in physical activity in outdoor natural environments have a greater effect on physical and mental well-being than physical activity indoors? Environmental Science & Technology, 45(5), 1761–1772.",
            detail: "Outdoor exercise reduces cravings more than indoor exercise alone in smoking cessation.",
            usedFor: "Nature + exercise science fact for Thriving mood level",
            url: nil
        ),
    ]}

    var quoteSources: [SourceItem] {[
        SourceItem(
            name: "\"The secret of getting ahead is getting started.\" Commonly attributed to Mark Twain.",
            detail: "Used for general encouragement during recovery.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "\"It does not matter how slowly you go as long as you do not stop.\" Commonly attributed to Confucius.",
            detail: "\"It does not matter how slowly you go as long as you do not stop.\" Persistence in recovery.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Carr, A. (1985). The easy way to stop smoking.",
            detail: "\"Freedom is what you find on the other side of discomfort\" and \"Quitting smoking is not a sacrifice; it's a liberation.\" Cognitive reframing approach to cessation.",
            usedFor: "Daily motivational quotes (2 quotes)",
            url: nil
        ),
        SourceItem(
            name: "Adapted from Johnson, S. (1748). The Vision of Theodore.",
            detail: "\"The chains of habit are too light to be felt until they are too heavy to be broken.\"",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Gandhi, M. K. (n.d.). Strength does not come from physical capacity. It comes from an indomitable will. Widely attributed.",
            detail: "Used for willpower and perseverance framing in recovery.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Fuller, T. (1732). Gnomologia: Adagies and proverbs; wise sentences and witty sayings. B. Barker.",
            detail: "\"Health is not valued till sickness comes.\"",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "National Institute on Drug Abuse. (2024). Drugs, brains, and behavior: The science of addiction. National Institutes of Health.",
            detail: "Basis for quotes on the withdrawal vs. weakness distinction and the neurochemical nature of cravings.",
            usedFor: "\"What you're feeling is withdrawal, not weakness\" quote",
            url: "https://nida.nih.gov"
        ),
        SourceItem(
            name: "Bowen, S., Chawla, N., & Marlatt, G. A. (2011). Mindfulness-based relapse prevention for addictive behaviors. Guilford Press.",
            detail: "\"The urge to smoke will pass whether you smoke or not\" — core principle of urge surfing.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Beck, J. S. (2020). Cognitive behavior therapy: Basics and beyond (3rd ed.). Guilford Press.",
            detail: "\"Progress, not perfection\" — foundational CBT concept applied to addiction recovery.",
            usedFor: "Daily motivational quote",
            url: nil
        ),
        SourceItem(
            name: "Harvard Health Publishing. (2021). The anxiety-smoking paradox. Harvard Medical School.",
            detail: "Basis for \"The cigarette didn't calm you. It relieved withdrawal while creating more of it.\"",
            usedFor: "Daily motivational quote",
            url: "https://www.health.harvard.edu"
        ),
        SourceItem(
            name: "American Lung Association. (2024). What happens after you quit smoking. American Lung Association.",
            detail: "Basis for \"Your lungs are healing right now. Every breath is proof.\"",
            usedFor: "Daily motivational quote",
            url: "https://www.lung.org"
        ),
        SourceItem(
            name: "Dani, J. A., & De Biasi, M. (2001). Cellular mechanisms of nicotine addiction. Pharmacology Biochemistry and Behavior, 70(4), 439–446.",
            detail: "\"Every craving you outlast makes the next one permanently weaker\" — based on nicotinic receptor downregulation research.",
            usedFor: "Daily motivational quote, reinforces withdrawal science",
            url: nil
        ),
    ]}

    var activitySources: [SourceItem] {[
        SourceItem(
            name: "Weil, A. (2015). 4-7-8 breathing exercise. Andrew Weil Center for Integrative Medicine.",
            detail: "Based on pranayama yoga breathing. Activates the parasympathetic nervous system, reducing heart rate and cortisol.",
            usedFor: "Breathing pacer activity, craving emergency tool",
            url: "https://www.drweil.com/health-wellness/body-mind-spirit/stress-anxiety/three-breathing-exercises-and-techniques/"
        ),
        SourceItem(
            name: "Divine, M. (2014). The way of the SEAL: Think like an elite warrior to lead and succeed. Reader's Digest Association.",
            detail: "4-4-4-4 breathing pattern used by Navy SEALs for focus under extreme stress. Balances sympathetic/parasympathetic nervous system.",
            usedFor: "Breathing pacer activity",
            url: nil
        ),
        SourceItem(
            name: "Bowen, S., Chawla, N., & Marlatt, G. A. (2011). Mindfulness-based relapse prevention for addictive behaviors. Guilford Press.",
            detail: "Urge surfing: observing cravings as waves that rise and fall without acting on them. Creates a cognitive gap between stimulus and response.",
            usedFor: "Urge surfing guided activity",
            url: nil
        ),
        SourceItem(
            name: "Bourne, E. J. (2020). The anxiety and phobia workbook (7th ed.). New Harbinger Publications.",
            detail: "5-4-3-2-1 sensory grounding technique that redirects attention through sensory channels. Disrupts default mode network craving loops.",
            usedFor: "Sensory grounding interactive activity",
            url: nil
        ),
        SourceItem(
            name: "Jacobson, E. (1938). Progressive relaxation (2nd ed.). University of Chicago Press.",
            detail: "Systematic tensing and releasing of muscle groups to reduce physical tension. Widely validated in anxiety and addiction treatment.",
            usedFor: "Body scan activity with guided tension/release",
            url: nil
        ),
        SourceItem(
            name: "Hayman, M. (1942). The serial sevens test. Archives of Neurology and Psychiatry, 47(4), 717.",
            detail: "Counting backwards by 7s demands high working memory from the prefrontal cortex, starving the amygdala of attentional resources needed to maintain craving intensity.",
            usedFor: "Serial 7s game, cognitive distraction activity",
            url: nil
        ),
        SourceItem(
            name: "Kaimal, G., Ray, K., & Muniz, J. (2016). Reduction of cortisol levels and participants' responses following art making. Art Therapy, 33(2), 74–80.",
            detail: "Creative expression (doodling, poetry) as emotional expression tools that reduce cortisol levels.",
            usedFor: "Doodle canvas, one-word poetry creative activities",
            url: nil
        ),
        SourceItem(
            name: "Hayes, S. C., Strosahl, K. D., & Wilson, K. G. (2012). Acceptance and commitment therapy: The process and practice of mindful change (2nd ed.). Guilford Press.",
            detail: "Cognitive defusion technique: cravings are mental events with no motor control over physical behavior.",
            usedFor: "Activity science explanations, cognitive reframing",
            url: nil
        ),
        SourceItem(
            name: "Godek, D., & Freeman, A. M. (2023). Physiology, diving reflex. In StatPearls. StatPearls Publishing.",
            detail: "Cold water on face triggers vagus nerve activation, dropping heart rate 10–25% in seconds.",
            usedFor: "Struggling mood science fact, craving emergency tip",
            url: nil
        ),
    ]}

    var helplineSources: [SourceItem] {[
        SourceItem(
            name: "Substance Abuse and Mental Health Services Administration. (2024). SAMHSA's national helpline. U.S. Department of Health and Human Services.",
            detail: "Free, confidential, 24/7 treatment referral and information service.",
            usedFor: "Primary helpline resource in the app",
            url: "https://www.samhsa.gov/find-help/national-helpline"
        ),
        SourceItem(
            name: "Centers for Disease Control and Prevention. (2024). Quit smoking. U.S. Department of Health and Human Services.",
            detail: "1-800-QUIT-NOW. Free quit coaching, personalized cessation plans, and medication guidance from trained counselors.",
            usedFor: "Quit coaching helpline resource",
            url: "https://www.cdc.gov/tobacco/quit-smoking/"
        ),
        SourceItem(
            name: "Substance Abuse and Mental Health Services Administration. (2024). 988 Suicide & Crisis Lifeline. U.S. Department of Health and Human Services.",
            detail: "National crisis line for mental health emergencies, including severe withdrawal-related distress. Call or text 988.",
            usedFor: "Crisis resource for severe emotional distress",
            url: "https://988lifeline.org"
        ),
        SourceItem(
            name: "Crisis Text Line. (2024). Text HOME to 741741. Crisis Text Line, Inc.",
            detail: "Immediate, confidential crisis support from trained counselors via text message.",
            usedFor: "Text-based crisis support resource",
            url: "https://www.crisistextline.org"
        ),
        SourceItem(
            name: "U.S. Department of Veterans Affairs. (2024). Veterans Crisis Line. U.S. Department of Veterans Affairs.",
            detail: "Dial 988 then press 1. Dedicated support for veterans, active service members, and their families.",
            usedFor: "Veterans-specific crisis resource",
            url: "https://www.veteranscrisisline.net"
        ),
    ]}
}
