import SwiftUI

// MARK: - Data Structures

struct Milestone: Identifiable {
    let id = UUID()
    let time: TimeInterval      // seconds
    let label: String
    let title: String
    let body: String
    let source: String
}

struct Symptom: Identifiable {
    let id: String
    let name: String
    let icon: String
    let onset: String
    let peak: String
    let duration: String
    let why: String
    let tips: [String]
    let source: String
    let intensityFn: (TimeInterval) -> Double
}

struct BreathExercise: Identifiable {
    let id = UUID()
    let name: String
    let inhale: Int
    let hold: Int
    let exhale: Int
    let holdAfter: Int
    let desc: String
    let color: Color
}

struct HelpResource: Identifiable {
    let id = UUID()
    let name: String
    let number: String       // display format
    let dialString: String   // tel:// format
    let desc: String
    let icon: String
    let color: Color
    let available: String
}

struct CravingMission: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let category: String
}

// MARK: - Static Data

enum RecoveryData {

    static let milestones: [Milestone] = [
        .init(time: 20*60,         label: "20 min",  title: "Heart Stabilizing",        body: "Heart rate drops and blood pressure becomes more stable.",                    source: "American Lung Association"),
        .init(time: 8*3600,        label: "8 hrs",   title: "Oxygen Returning",         body: "CO levels drop by half. Oxygen reaches normal levels in your blood.",         source: "Better Health Channel"),
        .init(time: 24*3600,       label: "24 hrs",  title: "Lungs Clearing",           body: "CO fully eliminated. Lungs begin pushing out mucus and debris.",              source: "American Lung Association"),
        .init(time: 48*3600,       label: "48 hrs",  title: "Senses Awakening",         body: "Nerve endings begin regrowing. Taste & smell dramatically improve.",          source: "Medical News Today"),
        .init(time: 72*3600,       label: "72 hrs",  title: "Breathing Easier",         body: "Bronchial tubes relax. Lung capacity noticeably increases. Energy up.",        source: "Medical News Today"),
        .init(time: 14*86400,      label: "2 wks",   title: "Circulation Improving",    body: "Lung function begins improving. Walking and exercise become noticeably easier.", source: "American Lung Association"),
        .init(time: 30*86400,      label: "1 mo",    title: "Cilia Regrowing",          body: "Coughing decreases. Cilia in lungs regrow, reducing infection risk.",         source: "American Cancer Society"),
        .init(time: 90*86400,      label: "3 mo",    title: "Lung Function Up",         body: "Circulation substantially better. Lung capacity significantly improved.",      source: "American Lung Association"),
        .init(time: 270*86400,     label: "9 mo",    title: "Major Lung Recovery",      body: "Lung function up 10%. Fatigue and shortness of breath greatly reduced.",       source: "American Cancer Society"),
        .init(time: 365*86400,     label: "1 yr",    title: "Heart Disease Risk Halved", body: "Coronary heart disease risk is now half that of an active smoker.",           source: "Surgeon General Report"),
        .init(time: 5*365*86400,   label: "5 yrs",   title: "Stroke Risk Normalized",   body: "Stroke risk equals that of a lifelong non-smoker.",                           source: "American Cancer Society"),
        .init(time: 10*365*86400,  label: "10 yrs",  title: "Lung Cancer Risk Halved",  body: "Lung cancer death risk cut in half vs. continuing smokers.",                  source: "American Cancer Society"),
    ]

    static let symptoms: [Symptom] = [
        .init(
            id: "cravings", name: "Cravings", icon: "🔥",
            onset: "Within 1–2 hours", peak: "Day 2–3", duration: "2–4 weeks",
            why: "Nicotine binds receptors that release dopamine. Without it, those receptors fire urgency signals demanding more. Crucially, each craving lasts only 3–5 minutes — riding it out literally rewires the receptor. As the CDC notes, urges rapidly fade if you distract yourself rather than fight or give in.",
            tips: [
                "Ride the wave — 3 to 5 minutes and it passes completely (CDC)",
                "Drink a full glass of ice-cold water slowly",
                "Do the 4-7-8 breathing exercise right now",
                "Change your physical location immediately",
                "Use a safe substitute: toothpick, crunchy snack, or gum (CDC)",
                "Talk back to the urge: 'I'm stressed, so I deserve a break to breathe — not a cigarette' (CDC)"
            ],
            source: "CDC Tips From Former Smokers / NCI",
            intensityFn: { sec in
                let h = sec/3600, d = sec/86400
                if h < 1 { return 0 }
                if d <= 3 { return min(1.0, (d + 0.1) / 3.0) }
                return max(0.05, 1.0 - (d - 3) / 25.0)
            }
        ),
        .init(
            id: "irritability", name: "Irritability", icon: "😤",
            onset: "Within 24 hours", peak: "Day 3–5", duration: "2–4 weeks",
            why: "Nicotine modulated your brain's norepinephrine system, buffering emotional responses. Without it, small frustrations feel amplified. This is neurochemical, not a character flaw — NIDA confirms substance use disorders involve real changes in brain circuitry.",
            tips: [
                "5 slow deep breaths before responding to anything",
                "Light exercise flushes stress hormones immediately",
                "Tell people around you what you're going through",
                "Cut caffeine — it worsens norepinephrine spikes",
                "Remind yourself: this is withdrawal, not your baseline reality"
            ],
            source: "CDC / NIDA",
            intensityFn: { sec in
                let h = sec/3600, d = sec/86400
                if h < 12 { return 0 }
                if d <= 4 { return min(1.0, (d - 0.5) / 3.5) }
                return max(0, 1.0 - (d - 4) / 24.0)
            }
        ),
        .init(
            id: "anxiety", name: "Anxiety", icon: "😰",
            onset: "Within 24 hours", peak: "Day 3", duration: "2–4 weeks",
            why: "Smoking created the anxiety cycle — each cigarette relieved withdrawal-induced anxiety, not real anxiety. Harvard Health confirms former smokers report significantly lower anxiety levels after recovery. You're breaking an illusion.",
            tips: [
                "Box breathing: 4 in → 4 hold → 4 out → 4 hold (Navy SEAL technique)",
                "Reduce caffeine during withdrawal week",
                "Progressive muscle relaxation: tense and release each muscle group",
                "Remind yourself: smoking caused this anxiety loop, not quitting",
                "10 minutes of physical activity cuts anxiety immediately"
            ],
            source: "CDC / Harvard Health / NIH",
            intensityFn: { sec in
                let h = sec/3600, d = sec/86400
                if h < 12 { return 0 }
                if d <= 3 { return min(0.95, (d - 0.5) / 2.5) }
                return max(0, 0.95 - (d - 3) / 25.0)
            }
        ),
        .init(
            id: "focus", name: "Difficulty Focusing", icon: "🧠",
            onset: "Within 24 hours", peak: "Day 3–5", duration: "1–2 weeks",
            why: "Nicotine upregulated acetylcholine and dopamine systems involved in attention. Your brain is rebuilding natural attention circuits. NIDA research shows these brain changes are real and treatable — they reverse with time and support.",
            tips: [
                "Break tasks into 15-minute sprints with breaks",
                "Drink more water — dehydration worsens brain fog significantly",
                "Single-task only: do one thing at a time",
                "Short walks between tasks reset focus circuits",
                "Dopamine receptors normalize within 1–2 weeks"
            ],
            source: "NIDA / Cleveland Clinic",
            intensityFn: { sec in
                let h = sec/3600, d = sec/86400
                if h < 12 { return 0 }
                if d <= 4 { return min(0.9, (d - 0.5) / 3.5) }
                return max(0, 0.9 - (d - 4) / 10.0)
            }
        ),
        .init(
            id: "insomnia", name: "Insomnia", icon: "🌙",
            onset: "Day 1–3", peak: "First week", duration: "2–4 weeks",
            why: "Nicotine disrupted your natural circadian rhythm and REM architecture. Your brain is recalibrating its sleep system. Many ex-smokers report dramatically better sleep after the first 2 weeks than when they smoked.",
            tips: [
                "No screens 1 hour before bed — do breathing exercises instead",
                "No caffeine after 2 PM",
                "Strict sleep schedule: same time in and out daily",
                "4-7-8 breathing lowers heart rate and induces sleep naturally",
                "Daytime exercise significantly improves sleep onset speed"
            ],
            source: "Smokefree.gov / Cleveland Clinic",
            intensityFn: { sec in
                let d = sec/86400
                if d < 1 { return 0 }
                if d <= 6 { return min(0.85, (d - 1) / 5.0 * 0.85) }
                return max(0, 0.85 - (d - 6) / 22.0)
            }
        ),
        .init(
            id: "appetite", name: "Increased Appetite", icon: "🍽️",
            onset: "Within 24 hours", peak: "Week 1–2", duration: "Several weeks",
            why: "Nicotine suppressed appetite via serotonin and dopamine. Food also tastes dramatically better as taste receptors recover — a concrete sign of healing. Harvard Health's 5-step guide recommends environmental changes: remove temptation and stock healthy options.",
            tips: [
                "Stock crunchy healthy snacks: carrots, apple slices, celery",
                "Drink a full glass of water before each meal",
                "Chew sugar-free gum to satisfy the oral habit",
                "Eat mindfully and slowly — your taste buds are literally healing",
                "Light exercise regulates appetite hormones naturally"
            ],
            source: "Harvard Health / NCI / WebMD",
            intensityFn: { sec in
                let d = sec/86400
                if d < 1 { return 0 }
                if d <= 14 { return min(0.8, (d - 1) / 13.0 * 0.8) }
                return max(0.05, 0.8 - (d - 14) / 28.0 * 0.75)
            }
        ),
        .init(
            id: "mood", name: "Low Mood", icon: "😔",
            onset: "Day 1–3", peak: "First 2 weeks", duration: "Under 1 month",
            why: "Nicotine triggered dopamine in reward circuits. Your brain's reward system is temporarily below baseline as it recalibrates. Critical fact: studies show former smokers have significantly lower depression rates than active smokers after recovery. This phase ends.",
            tips: [
                "Physical activity — even 10 minutes — triggers natural dopamine",
                "Morning sunlight resets serotonin production",
                "Connect with someone who supports your quit",
                "Track your progress — seeing how far you've come is powerful",
                "Seek professional support if low mood persists past 2 weeks (Mayo Clinic)"
            ],
            source: "NCI / Mayo Clinic / Cleveland Clinic",
            intensityFn: { sec in
                let d = sec/86400
                if d < 1 { return 0 }
                if d <= 7 { return min(0.8, (d - 1) / 6.0 * 0.8) }
                return max(0, 0.8 - (d - 7) / 21.0)
            }
        ),
        .init(
            id: "restlessness", name: "Restlessness", icon: "⚡",
            onset: "Day 1–3", peak: "First week", duration: "2–4 weeks",
            why: "Your nervous system is recalibrating without nicotine's stimulant-then-sedative cycle. The CDC recommends channeling this energy physically rather than suppressing it — this is your body's natural vitality returning.",
            tips: [
                "Physical activity is the single best outlet",
                "Fidget tools, stress balls, or doodling redirect physical energy",
                "Get up and walk for 3–5 minutes every hour",
                "Channel into a hands-on hobby or creative project",
                "This is your natural energy returning — not a problem"
            ],
            source: "CDC / Smokefree.gov",
            intensityFn: { sec in
                let d = sec/86400
                if d < 1 { return 0 }
                if d <= 5 { return min(0.85, (d - 1) / 4.0 * 0.85) }
                return max(0, 0.85 - (d - 5) / 23.0)
            }
        ),
    ]

    static let breathingExercises: [BreathExercise] = [
        .init(name: "4-7-8 Calm",      inhale: 4, hold: 7, exhale: 8, holdAfter: 0, desc: "Activates the parasympathetic nervous system. Best for intense cravings and anxiety spikes.", color: .rAccent),
        .init(name: "Box Breathing",    inhale: 4, hold: 4, exhale: 4, holdAfter: 4, desc: "Used by Navy SEALs for focus under stress. Perfect for irritability and racing thoughts.", color: .rPurple),
        .init(name: "2-4 Quick Reset",  inhale: 2, hold: 0, exhale: 4, holdAfter: 0, desc: "Fast craving relief when you can't step away. Works in under 60 seconds.", color: .rAmber),
    ]

    // Sourced from SAMHSA, CDC, NIDA, 988 Lifeline
    static let helpResources: [HelpResource] = [
        .init(
            name: "SAMHSA National Helpline",
            number: "1-800-662-4357",
            dialString: "tel://18006624357",
            desc: "Free, confidential treatment referral and information service for substance use disorders. Available in English and Spanish.",
            icon: "phone.fill",
            color: .rAccent,
            available: "24/7 · Free · Confidential"
        ),
        .init(
            name: "CDC Quitline",
            number: "1-800-784-8669",
            dialString: "tel://18007848669",
            desc: "1-800-QUIT-NOW. Free quit coaching, cessation medications, and personalized quit plans from trained counselors.",
            icon: "heart.fill",
            color: Color(red: 0.8, green: 0.3, blue: 0.3),
            available: "Free · Multiple languages"
        ),
        .init(
            name: "988 Crisis Lifeline",
            number: "988",
            dialString: "tel://988",
            desc: "Call or text 988 for mental health crises. Also supports people experiencing severe withdrawal-related distress.",
            icon: "exclamationmark.triangle.fill",
            color: .rDanger,
            available: "24/7 · Call or Text 988"
        ),
        .init(
            name: "Crisis Text Line",
            number: "Text HOME to 741741",
            dialString: "sms://741741",
            desc: "Text-based crisis support. Type HOME to 741741 for immediate confidential help from a trained crisis counselor.",
            icon: "message.fill",
            color: .rPurple,
            available: "24/7 · Text-based"
        ),
        .init(
            name: "Veterans Crisis Line",
            number: "988 · Press 1",
            dialString: "tel://988",
            desc: "Dedicated support for veterans. Call 988 and press 1. Also serves active service members and their families.",
            icon: "shield.fill",
            color: Color(red: 0.1, green: 0.3, blue: 0.6),
            available: "24/7 · Veterans & Military"
        ),
        .init(
            name: "Emergency Services",
            number: "911",
            dialString: "tel://911",
            desc: "For severe withdrawal emergencies. Alcohol and benzodiazepine withdrawal can be life-threatening. Don't wait.",
            icon: "cross.fill",
            color: Color(red: 0.85, green: 0.15, blue: 0.15),
            available: "Emergency Only"
        ),
    ]

    static let cravingMissions: [CravingMission] = [
        .init(icon: "figure.walk", text: "Walk for 5 minutes — cravings peak in 3 min then pass", category: "Move"),
        .init(icon: "drop.fill",   text: "Drink a full glass of ice-cold water, slowly", category: "Physical"),
        .init(icon: "carrot",      text: "Eat something crunchy: carrots, apple, or celery", category: "Physical"),
        .init(icon: "phone.fill",  text: "Call or text someone who supports your quit", category: "Connect"),
        .init(icon: "music.note",  text: "Play the one song that makes you feel powerful", category: "Emotional"),
        .init(icon: "bolt.fill",   text: "Do 20 jumping jacks — flush the craving with endorphins", category: "Move"),
        .init(icon: "pencil",      text: "Write 3 specific reasons you are quitting right now", category: "Mental"),
        .init(icon: "lungs.fill",  text: "Do one 4-7-8 breathing cycle right now", category: "Breathe"),
        .init(icon: "faceid",      text: "Brush your teeth — the clean feeling disrupts the craving loop", category: "Physical"),
        .init(icon: "brain",       text: "Count backwards from 100 by 7s — forces full brain focus", category: "Mental"),
    ]

    static let journalPrompts: [String] = [
        "What triggered a craving today, and what did I do instead?",
        "What physical improvement have I noticed since quitting?",
        "How am I feeling emotionally right now — be honest.",
        "What would I tell a friend who is thinking about quitting?",
        "What am I most proud of in my recovery so far?",
        "What healthy habit is replacing my old smoking habit?",
        "Describe a moment today when I felt genuinely free.",
        "What's the hardest part right now, and what is helping?",
        "How has quitting changed how I feel about myself?",
        "What will my life look like in one year smoke-free?",
        "The CDC says to 'ride the wave' of cravings. How did I ride mine today?",
        "What environment changes have I made to remove smoking triggers?",
    ]
}
