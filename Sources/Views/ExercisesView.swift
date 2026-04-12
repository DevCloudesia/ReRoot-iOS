import SwiftUI
import UIKit

// ════════════════════════════════════════════════════════
// MARK: - Exercise Activity Model
// ════════════════════════════════════════════════════════

struct ExActivity: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    let duration: String
    let why: String
    let intensity: String
    let type: String
    let category: String
    let steps: [String]
    let color: Color
}

// ════════════════════════════════════════════════════════
// MARK: - Activity Database — 30 activities, 5 mood pools
// ════════════════════════════════════════════════════════

enum ActivityDB {

    // ── Struggling (😣) — Immediate crisis interventions ──
    static let struggling: [ExActivity] = [
        ExActivity(icon: "snowflake", name: "Mammalian Dive Reflex — Cold Splash", duration: "3 min", why: "Splash ice-cold water on your face targeting eyes and cheekbones. Stimulates the trigeminal nerve → triggers the dive reflex → immediate bradycardia and parasympathetic activation.", intensity: "Low", type: "Cold Exposure", category: "Crisis Intervention", steps: ["Run to a sink — don't think, just move", "Run the coldest water available", "Splash face 10 times targeting eyes and cheekbones", "Hold ice-cold wrists under the stream for 30s", "The craving's intensity just dropped physiologically"], color: Color(red: 0.2, green: 0.5, blue: 0.7)),
        ExActivity(icon: "lungs.fill", name: "4-7-8 Autonomic Reset", duration: "5 min", why: "The extended exhalation phase directly stimulates the vagus nerve, which governs the parasympathetic nervous system. Immediately mitigates anxiety and chest tightness of acute nicotine deprivation.", intensity: "Low", type: "Breathing", category: "Immediate Relief", steps: ["Inhale through nose: 4 seconds", "Hold completely: 7 seconds", "Exhale forcefully through mouth: 8 seconds", "Repeat 4 cycles — feel the shift happen", "4 more cycles if the craving persists"], color: Color(red: 0.3, green: 0.6, blue: 0.8)),
        ExActivity(icon: "bolt.fill", name: "Burpee Protocol — Endorphin Flush", duration: "5 min", why: "15-20 burpees demand total physical and cognitive presence. Substitutes withdrawal pain with manageable physical exertion while flushing your system with endorphins.", intensity: "High", type: "HIIT", category: "Energy Release", steps: ["Stand up wherever you are", "Do 15 burpees as fast as safely possible", "Rest 30 seconds, gasping is fine", "15 more if you can — empty the tank", "Stand still — the craving is gone"], color: Color(red: 0.85, green: 0.3, blue: 0.2)),
        ExActivity(icon: "water.waves", name: "Urge Surfing — MBRP Visualization", duration: "5 min", why: "Rooted in Mindfulness-Based Relapse Prevention. Changes your relationship with the craving by observing it as a wave that peaks and subsides within 3-5 minutes.", intensity: "Low", type: "Mindfulness", category: "Mental", steps: ["Close your eyes and sit comfortably", "Notice where the craving lives in your body — chest? jaw?", "Visualize it as an ocean wave beginning to swell", "Watch the wave peak — don't fight it, observe it", "Watch it crest, dissolve, and fade. You outlasted it."], color: Color(red: 0.4, green: 0.6, blue: 0.8)),
        ExActivity(icon: "number", name: "Serial 7s — Math Distraction", duration: "3 min", why: "Count backward from 1000 by 7s. Serial subtraction demands high working memory, engaging the prefrontal cortex and starving the amygdala of attention needed to sustain the craving loop.", intensity: "Low", type: "Cognitive", category: "Mental", steps: ["Start at 1000", "993... 986... 979... keep going", "Don't stop — force your brain to compute", "If you lose track, start over from where you were", "2 minutes minimum — notice the craving weakened"], color: .rPurple),
        ExActivity(icon: "cloud.fill", name: "Guided Mental Escape", duration: "5 min", why: "Deep visualization shifts the brain's focus from the immediate stressor. Constructs a competing sensory experience that lowers heart rate and shields against intrusive tobacco thoughts.", intensity: "Low", type: "Visualization", category: "Mental", steps: ["Close your eyes in a comfortable position", "Picture your most calming place — beach, forest, mountain", "Focus on the sound of water or wind", "Feel the temperature on your skin", "Stay here for 5 minutes — you are safe, the craving is not"], color: Color(red: 0.3, green: 0.55, blue: 0.3)),
    ]

    // ── Tough (😟) — Hard but manageable, grounding ──
    static let tough: [ExActivity] = [
        ExActivity(icon: "figure.stand", name: "Isometric Wall Sit — 90 Seconds", duration: "5 min", why: "Hold a wall sit focusing entirely on the burning sensation in your quads and glutes. Continuous neuromuscular engagement diverts neural bandwidth from the craving.", intensity: "Moderate", type: "Isometric", category: "Distress Tolerance", steps: ["Find a wall — slide your back down to 90°", "Focus on the burning in your quads", "Hold for 60 seconds minimum, aim for 90", "Stand up slowly — feel the blood rush", "The craving lost your brain's attention"], color: Color(red: 0.5, green: 0.35, blue: 0.2)),
        ExActivity(icon: "bus.fill", name: "Passengers on the Bus — ACT", duration: "5 min", why: "ACT cognitive defusion exercise. You're the bus driver. Cravings are rowdy passengers yelling from the back seats. You acknowledge the noise but keep your hands on the steering wheel.", intensity: "Low", type: "ACT", category: "Mental", steps: ["Visualize yourself driving a large bus", "The bus represents your life and recovery", "Cravings are passengers yelling 'turn around!'", "Acknowledge their noise — they're loud but powerless", "Keep driving. You are the executive driver of your actions."], color: Color(red: 0.5, green: 0.4, blue: 0.7)),
        ExActivity(icon: "timer", name: "30-Minute Delay Commitment", duration: "30 min", why: "Cravings spike rapidly but lack structural integrity. By the time 30 minutes pass, dopaminergic urgency has almost universally subsided to manageable levels.", intensity: "Low", type: "Behavioral", category: "Delay Tactic", steps: ["Set a hard timer for 30 minutes right now", "Commit: NO action on the urge until it sounds", "Engage in any non-smoking distraction", "Check in at 15 min — notice the intensity dropped", "Timer done — the craving is manageable now"], color: .rAmber),
        ExActivity(icon: "hand.raised.fingers.spread", name: "Progressive Muscle Relaxation", duration: "8 min", why: "Tense each muscle group for 5 seconds, then release. The tension-release cycle physically drains agitation stored in your body from withdrawal. Clinically used in cessation programs.", intensity: "Low", type: "Relaxation", category: "Tension Release", steps: ["Clench both fists tight for 5 seconds → release", "Squeeze shoulders to ears for 5 seconds → drop", "Tense your entire face → release", "Tighten both legs and feet → release", "Full body: tense everything 7 seconds → completely melt"], color: Color(red: 0.6, green: 0.45, blue: 0.35)),
        ExActivity(icon: "ear.fill", name: "5-4-3-2-1 Sensory Grounding", duration: "5 min", why: "Rapid sensory indexing curtails the brain's default mode network from wandering into craving loops. Anchors you firmly in the safety of the present moment.", intensity: "Low", type: "Grounding", category: "Mental", steps: ["Name 5 things you can SEE around you", "Touch 4 different textures deliberately", "Listen for 3 distinct sounds", "Notice 2 things you can smell", "Taste 1 thing — water, gum, anything"], color: .rPurple),
        ExActivity(icon: "figure.walk", name: "Environment Change Walk", duration: "10 min", why: "Physically leaving the craving environment breaks cue-reactivity. The brain associates specific locations with smoking — removing the environmental cue disrupts the neural loop.", intensity: "Low", type: "Walking", category: "Craving Relief", steps: ["Put on shoes — don't think, just go", "Walk briskly to a place you've never smoked", "Stay there for at least 5 minutes", "Notice the craving is weaker in this new place", "The environmental trigger is behind you"], color: .rAccent),
    ]

    // ── Holding Steady (😐) — Maintenance and habit replacement ──
    static let steady: [ExActivity] = [
        ExActivity(icon: "figure.walk", name: "Brisk Environmental Walk", duration: "20 min", why: "Moderate aerobic activity increases BDNF synthesis and mild endorphin release, accelerating neural recovery. Physically leaving habitual environments disrupts cue-reactivity.", intensity: "Moderate", type: "Walking", category: "Cardio", steps: ["Start at normal pace for 3 minutes", "Increase to brisk — slight breathlessness", "Alternate: 3 min fast, 1 min recovery", "Push the pace for the last 3 minutes", "Cool down walk for 2 minutes"], color: .rAccent),
        ExActivity(icon: "figure.outdoor.cycle", name: "Rhythmic Aerobic Cycling", duration: "25 min", why: "Rhythmic bilateral movement facilitates bilateral brain stimulation for emotional regulation. Steady-state cardio promotes optimal tissue oxygenation recovering from carbon monoxide.", intensity: "Moderate", type: "Cycling", category: "Cardio", steps: ["5 minutes easy spinning to warm up", "10 minutes at moderate effort", "3 minutes higher effort", "5 minutes moderate", "2 minutes easy cool down"], color: Color(red: 0.2, green: 0.5, blue: 0.7)),
        ExActivity(icon: "figure.mind.and.body", name: "Restorative Yoga — Tension Release", duration: "15 min", why: "Withdrawal stores severe tension in trapezius, neck, and hips. Restorative stretching physically releases it while enforcing deep rhythmic breath control — blending activity with mindfulness.", intensity: "Low", type: "Yoga", category: "Mind-Body", steps: ["Child's Pose: sink back, forehead to floor, 2 min", "Cat-Cow: 10 slow breaths", "Supine twist: 1 minute each side", "Legs up the wall: 3 minutes", "Savasana: 2 minutes, scan for remaining tension"], color: Color(red: 0.5, green: 0.4, blue: 0.7)),
        ExActivity(icon: "pencil.line", name: "Gratitude Amplification Journal", duration: "10 min", why: "Inducing gratitude significantly reduces craving to smoke (Harvard T.H. Chan). Gratitude uniquely alters temporal discounting — making you less inclined toward immediate gratification.", intensity: "Low", type: "Journaling", category: "Mental", steps: ["Write 3 highly specific things you're grateful for", "For each one, write WHY you're grateful", "Describe one moment today that felt good", "Write one thing about your quit you're proud of", "Read it back — this shifts your neurobiology"], color: Color(red: 0.7, green: 0.55, blue: 0.3)),
        ExActivity(icon: "magnifyingglass", name: "Environmental Trigger Audit", duration: "10 min", why: "Log your emotional state, environment, and companions to identify hidden triggers. Transition from passive victim of cravings to active investigator who preemptively alters their environment.", intensity: "Low", type: "CBT", category: "Mental", steps: ["Write your current emotional state (1-10)", "Note your physical environment right now", "Who are you with? What just happened?", "Identify: does this setting trigger urges?", "Plan one change to reduce this trigger tomorrow"], color: Color(red: 0.4, green: 0.5, blue: 0.6)),
        ExActivity(icon: "fork.knife", name: "Post-Meal Routine Alteration", duration: "10 min", why: "After-meal smoking is one of the most deeply ingrained conditioning loops. Forcibly inserting a new routine into the post-meal window breaks the conditioned synaptic link.", intensity: "Low", type: "Behavioral", category: "Habit Replacement", steps: ["Immediately after eating: stand up", "Wash the dishes or wipe the counter", "Brush your teeth with mint toothpaste", "Chew sugarless gum for 5 minutes", "The post-meal craving window has passed"], color: Color(red: 0.5, green: 0.6, blue: 0.4)),
    ]

    // ── Doing Well (🙂) — Building momentum ──
    static let doingWell: [ExActivity] = [
        ExActivity(icon: "dumbbell.fill", name: "Compound Strength Training", duration: "30 min", why: "Smoking damages muscle oxygenation and suppresses metabolism. Heavy resistance training increases metabolic rate, regulates blood sugar, and provides tangible evidence of bodily healing.", intensity: "Moderate-High", type: "Strength", category: "Strength", steps: ["5 min dynamic warm-up", "Squats: 4 sets of 8-10", "Push-ups or bench: 4 sets of 8-12", "Rows or pull-ups: 4 sets of 8-10", "Planks: 3 x 45 seconds"], color: .rAmber),
        ExActivity(icon: "music.note", name: "Euphoric Dance — Auditory-Motor", duration: "15 min", why: "Preferred music releases dopamine in the striatum. Combined with vigorous cardio movement, this supercharges the brain's reward centers — massive natural mood elevation.", intensity: "Moderate", type: "Dance", category: "Joy", steps: ["Curate 4-5 high-tempo favorites", "Put them on LOUD", "Dance vigorously — no rules, just move", "Push the energy on the fastest song", "Cool down to a slower final track"], color: Color(red: 0.7, green: 0.3, blue: 0.5)),
        ExActivity(icon: "figure.outdoor.cycle", name: "Rhythmic Cycling — 20 Minutes", duration: "20 min", why: "Steady-state cycling promotes bilateral brain stimulation for emotional regulation. Optimal oxygenation for tissues recovering from years of CO exposure.", intensity: "Moderate", type: "Cycling", category: "Cardio", steps: ["5 min easy spinning warm-up", "10 min at moderate effort — conversational", "3 min push at 80% effort", "2 min easy cool down"], color: Color(red: 0.2, green: 0.5, blue: 0.7)),
        ExActivity(icon: "dollarsign.circle", name: "Experiential Reward Scheduling", duration: "10 min", why: "Calculate money saved by not buying tobacco. Book an experience with those funds. Shifting from consumptive to experiential rewards fulfills the brain's reward center while building a life incompatible with smoking.", intensity: "Low", type: "Planning", category: "Mental", steps: ["Calculate your total money saved so far", "Browse experiences: massage, concert, class, trip", "Pick one and book it — spend the saved money", "Tell someone about your reward plan", "This is what your quit has bought you"], color: Color(red: 0.3, green: 0.55, blue: 0.3)),
        ExActivity(icon: "person.fill", name: "Non-Smoker Identity Affirmation", duration: "10 min", why: "Research shows retaining an 'ex-smoker' identity preserves relapse vulnerability, while adopting 'non-smoker' identity severs the psychological tether to the drug completely.", intensity: "Low", type: "Identity", category: "Mental", steps: ["Write a paragraph about a future stressful scenario", "Visualize navigating it entirely as a non-smoker", "You don't even consider cigarettes — they're irrelevant", "Read it aloud to yourself", "This is who you are becoming"], color: Color(red: 0.5, green: 0.4, blue: 0.7)),
        ExActivity(icon: "figure.hiking", name: "Nature Trail Hike", duration: "30 min", why: "Nature exposure + exercise reduces cravings 40% more than indoor activity (University of Exeter). Trees release phytoncides that lower cortisol. A profound reminder that your lungs work.", intensity: "Moderate", type: "Hiking", category: "Nature", steps: ["Find a trail or park path", "Start at conversation pace for 10 min", "Pick up the pace on uphills", "Stop at a viewpoint — breathe deeply", "Push the pace on the return"], color: Color(red: 0.3, green: 0.55, blue: 0.3)),
    ]

    // ── Thriving (😊) — Peak positive, identity-locking ──
    static let thriving: [ExActivity] = [
        ExActivity(icon: "flame.fill", name: "HIIT Euphoria Protocol", duration: "20 min", why: "Maximum-effort bursts produce massive endorphins and endocannabinoids — the 'runner's high.' Flooding the brain's reward pathways via intense exertion retrains the neural circuitry hijacked by nicotine.", intensity: "High", type: "HIIT", category: "Intensity", steps: ["4 min warm-up jog", "30s sprint / 30s walk × 8 rounds", "2 min recovery walk", "30s sprint / 30s walk × 4 rounds", "4 min cool down — you just proved something"], color: Color(red: 0.85, green: 0.3, blue: 0.2)),
        ExActivity(icon: "figure.pool.swim", name: "Vigorous Lap Swimming", duration: "25 min", why: "Swimming demands regulated breathing against water resistance. For a former smoker, executing rigorous cardio without severe breathlessness is a profound physiological victory.", intensity: "High", type: "Swimming", category: "Full Body", steps: ["4 laps easy warm-up", "8 × 25m sprints with 20s rest", "4 laps easy recovery", "4 × 50m at 80% effort, 30s rest", "4 laps easy cool down"], color: Color(red: 0.15, green: 0.4, blue: 0.65)),
        ExActivity(icon: "figure.boxing", name: "Shadow Boxing Power", duration: "15 min", why: "Boxing channels withdrawal's residual agitation productively. Burns 400+ cal/hr, builds core strength, and provides an outlet for any lingering fight-or-flight energy.", intensity: "High", type: "Boxing", category: "Power", steps: ["2 min bouncing in stance, loose punches", "3 × 3 min rounds: jab-cross-hook combos", "1 min rest between rounds", "Final round: max speed combinations", "2 min cool down, shake it out"], color: Color(red: 0.7, green: 0.25, blue: 0.25)),
        ExActivity(icon: "message.fill", name: "Prosocial Support Sharing", duration: "10 min", why: "Sharing success leverages social accountability and prosocial reinforcement. Positive validation releases oxytocin and serotonin, consolidating your healthy identity within your social fabric.", intensity: "Low", type: "Social", category: "Mental", steps: ["Pick a specific milestone you've hit", "Text or post: 'X days smoke-free, here's what changed'", "Be specific about a physical improvement", "Ask someone how they noticed you've changed", "Receive the validation — you earned it"], color: Color(red: 0.3, green: 0.55, blue: 0.3)),
        ExActivity(icon: "target", name: "Future Goal Anchoring", duration: "10 min", why: "Review physical recovery timeline: lung function return, stroke risk normalization, cancer risk halving. Write which milestone excites you most. Transforms 'health' into a specific anticipated event.", intensity: "Low", type: "Planning", category: "Mental", steps: ["Review: 1 month = lung cilia regrow", "3 months = circulation improved 30%", "1 year = heart disease risk halved", "5 years = stroke risk equals non-smoker", "Write the milestone you're most excited for"], color: .rAccent),
        ExActivity(icon: "figure.run", name: "Tempo Run — Proof of Healing", duration: "30 min", why: "Running at 'comfortably hard' effort produces endocannabinoids. Builds cardiovascular capacity that smoking destroyed. Every kilometer is evidence your lungs are reborn.", intensity: "High", type: "Running", category: "Cardio", steps: ["5 min easy jog warm-up", "15 min at tempo pace (short phrases only)", "5 min easy jog recovery", "3 min push at near-race effort", "2 min cool down walk — that was impossible 6 months ago"], color: Color(red: 0.6, green: 0.4, blue: 0.2)),
    ]

    static func forMood(_ mood: Int) -> [ExActivity] {
        switch mood {
        case 0:  return struggling
        case 1:  return tough
        case 2:  return steady
        case 3:  return doingWell
        default: return thriving
        }
    }

    static func moodLabel(_ mood: Int) -> String {
        switch mood {
        case 0:  return "CRISIS INTERVENTION"
        case 1:  return "DISTRESS TOLERANCE"
        case 2:  return "MAINTENANCE PROTOCOL"
        case 3:  return "MOMENTUM BUILDING"
        default: return "PEAK PERFORMANCE"
        }
    }
}

// ════════════════════════════════════════════════════════
// MARK: - Exercises View
// ════════════════════════════════════════════════════════

struct ExercisesView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var gamification: GamificationState
    @EnvironmentObject var hkManager: HealthKitManager

    @State private var appear = false
    @State private var shuffledActivities: [ExActivity] = []
    @State private var expandedId: UUID? = nil
    @State private var loggedIds: Set<UUID> = []
    @State private var showConfetti: UUID? = nil
    @State private var savedToHealth: Set<UUID> = []

    private var mood: Int { state.lastCheckInMood ?? 2 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                headerCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5), value: appear)

                HStack {
                    Text(ActivityDB.moodLabel(mood))
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.rText3).tracking(1.2)
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            shuffledActivities = ActivityDB.forMood(mood).shuffled()
                            expandedId = nil
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "shuffle").font(.system(size: 11, weight: .bold))
                            Text("Shuffle").font(.sansRR(11, weight: .bold))
                        }
                        .foregroundColor(.rAccent)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.rAccent.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 4)
                .opacity(appear ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.06), value: appear)

                ForEach(Array(shuffledActivities.prefix(4).enumerated()), id: \.element.id) { idx, activity in
                    activityCard(activity, index: idx)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 14)
                        .animation(.easeOut(duration: 0.42).delay(0.1 + Double(idx) * 0.07), value: appear)
                }

                scienceCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.42), value: appear)

                progressCard
                    .opacity(appear ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.48), value: appear)

                if !gamification.exerciseLog.isEmpty {
                    recentLogSection
                        .opacity(appear ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.54), value: appear)
                }

                Color.clear.frame(height: 90)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(Color.rBg.ignoresSafeArea())
        .onAppear {
            if shuffledActivities.isEmpty {
                shuffledActivities = ActivityDB.forMood(mood).shuffled()
            }
            withAnimation { appear = true }
        }
    }

    // MARK: - Header

    var headerCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(moodGradient).frame(width: 50, height: 50)
                    Image(systemName: moodIcon)
                        .font(.system(size: 22, weight: .semibold)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(moodTitle)
                        .font(.serif(20, weight: .bold)).foregroundColor(.rText)
                    Text(moodSubtext)
                        .font(.sansRR(12)).foregroundColor(.rText3).lineSpacing(2)
                }
                Spacer()
            }

            HStack(spacing: 0) {
                headerStat("\(gamification.exerciseLog.count)", "sessions")
                Rectangle().fill(Color.rBg2).frame(width: 1, height: 24)
                headerStat("\(totalMinutes)", "minutes")
                Rectangle().fill(Color.rBg2).frame(width: 1, height: 24)
                headerStat(weekStreak, "this week")
            }
            .padding(.vertical, 10)
            .background(moodColor.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    func headerStat(_ val: String, _ lab: String) -> some View {
        VStack(spacing: 2) {
            Text(val).font(.serif(18, weight: .bold)).foregroundColor(.rText).monospacedDigit()
            Text(lab).font(.sansRR(9)).foregroundColor(.rText3)
        }
        .frame(maxWidth: .infinity)
    }

    var moodIcon: String {
        switch mood {
        case 0: return "exclamationmark.triangle.fill"
        case 1: return "leaf.fill"
        case 2: return "figure.walk"
        case 3: return "arrow.up.right"
        default: return "flame.fill"
        }
    }
    var moodTitle: String {
        switch mood {
        case 0: return "Emergency Relief"
        case 1: return "Grounding & Calm"
        case 2: return "Steady Maintenance"
        case 3: return "Building Momentum"
        default: return "Peak Performance"
        }
    }
    var moodSubtext: String {
        switch mood {
        case 0: return "Immediate crisis interventions to break the acute craving loop right now."
        case 1: return "Activities to ground yourself through a tough day and build distress tolerance."
        case 2: return "Moderate engagement to maintain your quit and restore natural dopamine."
        case 3: return "Challenge yourself and channel your growing energy into lasting gains."
        default: return "You're thriving — push hard, prove what your body can do, lock in your identity."
        }
    }
    var moodColor: Color {
        switch mood {
        case 0: return .rDanger
        case 1: return Color(red: 0.6, green: 0.45, blue: 0.35)
        case 2: return Color(red: 0.3, green: 0.5, blue: 0.7)
        case 3: return .rAccent
        default: return .rAmber
        }
    }
    var moodGradient: LinearGradient {
        switch mood {
        case 0:
            return LinearGradient(colors: [.rDanger, Color(red: 0.6, green: 0.2, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 1:
            return LinearGradient(colors: [Color(red: 0.6, green: 0.45, blue: 0.35), Color(red: 0.45, green: 0.3, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2:
            return LinearGradient(colors: [Color(red: 0.3, green: 0.5, blue: 0.7), Color(red: 0.2, green: 0.38, blue: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3:
            return LinearGradient(colors: [.rAccent, Color(red: 0.25, green: 0.45, blue: 0.28)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.rAmber, Color(red: 0.75, green: 0.38, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var totalMinutes: Int { gamification.exerciseLog.reduce(0) { $0 + $1.minutes } }
    var weekStreak: String {
        let thisWeek = gamification.exerciseLog.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
        return "\(thisWeek)"
    }

    // MARK: - Activity Card

    func activityCard(_ act: ExActivity, index: Int) -> some View {
        let isExpanded = expandedId == act.id
        let isLogged = loggedIds.contains(act.id)

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    expandedId = isExpanded ? nil : act.id
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(isLogged ? Color.rAccent.opacity(0.15) : act.color.opacity(0.12))
                            .frame(width: 46, height: 46)
                        Image(systemName: isLogged ? "checkmark" : act.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isLogged ? .rAccent : act.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(act.name)
                                .font(.sansRR(15, weight: .bold)).foregroundColor(isLogged ? .rText3 : .rText)
                                .strikethrough(isLogged).lineLimit(2).multilineTextAlignment(.leading)
                            Spacer()
                            Text(act.duration)
                                .font(.sansRR(11, weight: .bold)).foregroundColor(act.color)
                        }
                        HStack(spacing: 8) {
                            Label(act.intensity, systemImage: "flame")
                                .font(.sansRR(10, weight: .medium)).foregroundColor(.rText3)
                            Text("\u{00B7}").foregroundColor(.rText3)
                            Text(act.category)
                                .font(.sansRR(10, weight: .semibold)).foregroundColor(act.color.opacity(0.8))
                        }
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.rText3)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(act.why)
                        .font(.sansRR(12)).foregroundColor(.rText2).lineSpacing(3)
                        .padding(.horizontal, 14)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("HOW TO DO IT")
                            .font(.sansRR(9, weight: .bold)).foregroundColor(act.color).tracking(1)
                        ForEach(Array(act.steps.enumerated()), id: \.offset) { idx, step in
                            HStack(alignment: .top, spacing: 10) {
                                ZStack {
                                    Circle().fill(act.color.opacity(0.12)).frame(width: 22, height: 22)
                                    Text("\(idx + 1)")
                                        .font(.sansRR(10, weight: .bold)).foregroundColor(act.color)
                                }
                                Text(step)
                                    .font(.sansRR(12)).foregroundColor(.rText).lineSpacing(2)
                            }
                        }
                    }
                    .padding(12)
                    .background(act.color.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 14)

                    if isPhysicalExercise(act) {
                        Button {
                            openAppleFitness(for: act)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "figure.run").font(.system(size: 14))
                                Text("Open in Apple Fitness")
                            }
                            .font(.sansRR(13, weight: .bold))
                            .foregroundColor(Color(red: 0.65, green: 1.0, blue: 0.0))
                            .frame(maxWidth: .infinity).padding(.vertical, 11)
                            .background(Color.black)
                            .clipShape(Capsule())
                        }
                        .padding(.horizontal, 14)
                    }

                    HStack(spacing: 10) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                loggedIds.insert(act.id)
                                showConfetti = act.id
                            }
                            gamification.logExercise(type: act.type, minutes: parseDuration(act.duration))
                            if hkManager.authorized {
                                let wType = HealthKitManager.workoutType(for: act.name)
                                Task {
                                    let ok = await hkManager.saveWorkout(type: wType, minutes: parseDuration(act.duration))
                                    if ok { savedToHealth.insert(act.id) }
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation { showConfetti = nil }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isLogged {
                                    Image(systemName: "checkmark.circle.fill").font(.system(size: 16))
                                    Text(savedToHealth.contains(act.id) ? "Saved to Health!" : "Logged!")
                                } else if showConfetti == act.id {
                                    Text("Great job! +\(act.intensity == "High" ? "30" : "20") XP")
                                } else {
                                    Image(systemName: "heart.circle.fill").font(.system(size: 14))
                                    Text("Log + Save to Health")
                                }
                            }
                            .font(.sansRR(14, weight: .bold))
                            .foregroundColor(isLogged ? act.color : .white)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(isLogged ? act.color.opacity(0.1) : act.color)
                            .clipShape(Capsule())
                        }
                        .disabled(isLogged)
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(
                isExpanded ? act.color.opacity(0.3) : Color.rBg2.opacity(0.8), lineWidth: isExpanded ? 1.5 : 1
            )
        )
        .shadow(color: isExpanded ? act.color.opacity(0.08) : .black.opacity(0.03), radius: isExpanded ? 12 : 6, y: 3)
    }

    func parseDuration(_ s: String) -> Int {
        let nums = s.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
        return nums.first ?? 15
    }

    func isPhysicalExercise(_ act: ExActivity) -> Bool {
        let physical: Set<String> = ["HIIT", "Strength", "Walking", "Running", "Cycling", "Swimming", "Yoga", "Boxing", "Dance", "Hiking", "Isometric", "Cold Exposure"]
        return physical.contains(act.type)
    }

    func openAppleFitness(for act: ExActivity) {
        let schemes = ["fitness://workout", "fitnessapp://", "apple-health://browse"]
        for scheme in schemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
        if let url = URL(string: "x-apple-health://") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Science Card (mood-adaptive with 5 distinct sets)

    var scienceCard: some View {
        let facts = scienceFacts
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile").font(.system(size: 16)).foregroundColor(.rPurple)
                Text("THE SCIENCE")
                    .font(.sansRR(10, weight: .bold)).foregroundColor(.rPurple).tracking(1)
            }
            ForEach(facts.indices, id: \.self) { i in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(Color.rPurple.opacity(0.4)).frame(width: 5, height: 5).padding(.top, 6)
                    Text(facts[i]).font(.sansRR(12)).foregroundColor(.rText2).lineSpacing(2)
                }
            }
            Text("Sources: NIDA, ALA, Harvard Health, Psychopharmacology meta-analysis, Frontiers in Psychiatry")
                .font(.sansRR(9)).foregroundColor(.rText3.opacity(0.5)).italic().padding(.top, 4)
        }
        .padding(16)
        .background(Color.rPurple.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.rPurple.opacity(0.12), lineWidth: 1))
    }

    var scienceFacts: [String] {
        switch mood {
        case 0:
            return [
                "Cold water on face triggers the mammalian dive reflex — heart rate drops 10-25% in seconds, breaking the craving loop physiologically",
                "Serial subtraction demands high working memory from the prefrontal cortex, starving the amygdala of attention needed for cravings",
                "Urge surfing (MBRP) creates a cognitive gap between stimulus and response, allowing the neurochemical urge to decay in 3-5 minutes",
                "High-impact burpees flood the system with endorphins while demanding total cognitive presence",
            ]
        case 1:
            return [
                "Isometric holds require continuous neuromuscular engagement, actively diverting neural bandwidth from the craving centers",
                "The 30-minute delay exploits the temporal nature of cravings — dopaminergic urgency cannot sustain itself that long",
                "5-4-3-2-1 sensory grounding disrupts the default mode network's craving loops and anchors you in the present",
                "ACT's cognitive defusion teaches that cravings are noise with no motor control over your physical body",
            ]
        case 2:
            return [
                "Moderate exercise 3x/week is the strongest behavioral predictor of quit success across all cessation research",
                "Exercise produces BDNF — a protein that literally grows new neural connections to replace nicotine-damaged ones",
                "Gratitude uniquely alters temporal discounting, making you less inclined toward immediate gratification (Harvard)",
                "Environmental trigger auditing transitions you from passive victim to active investigator of your patterns",
            ]
        case 3:
            return [
                "Resistance training restores testosterone and growth hormone levels suppressed by chronic nicotine use",
                "Anticipating preferred music releases dopamine in the striatum — combined with cardio = supercharged reward",
                "Identity shift from 'ex-smoker' to 'non-smoker' is statistically the strongest predictor of long-term abstinence",
                "Nature + exercise reduces cravings 40% more than indoor exercise alone (University of Exeter)",
            ]
        default:
            return [
                "HIIT produces massive endorphins and endocannabinoids, retraining the neural circuitry hijacked by nicotine",
                "Lap swimming demands regulated breathing against resistance — a profound physiological victory for former smokers",
                "Sharing milestones leverages social accountability; positive validation releases oxytocin and serotonin",
                "Former smokers who exercise regularly report lower anxiety than when they smoked (Harvard Health)",
            ]
        }
    }

    // MARK: - Progress Card

    var progressCard: some View {
        let thisWeekCount = gamification.exerciseLog.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
        let goal = 5
        let pct = min(1.0, Double(thisWeekCount) / Double(goal))

        return VStack(spacing: 10) {
            HStack {
                Text("WEEKLY GOAL").font(.sansRR(10, weight: .bold)).foregroundColor(.rAccent).tracking(1)
                Spacer()
                Text("\(thisWeekCount)/\(goal) sessions").font(.sansRR(12, weight: .semibold)).foregroundColor(.rText)
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.rBg2).frame(height: 8)
                    Capsule().fill(Color.rAccent).frame(width: g.size.width * pct, height: 8)
                        .animation(.easeOut(duration: 0.6), value: pct)
                }
            }
            .frame(height: 8)

            if thisWeekCount >= goal {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(Color(red: 0.92, green: 0.76, blue: 0.22))
                    Text("Weekly goal hit! Your lungs and brain thank you.")
                        .font(.sansRR(12, weight: .semibold)).foregroundColor(.rAccent)
                }
            } else {
                Text("\(goal - thisWeekCount) more sessions this week to hit your goal")
                    .font(.sansRR(11)).foregroundColor(.rText3)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2.opacity(0.8), lineWidth: 1))
    }

    // MARK: - Recent Log

    var recentLogSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RECENT SESSIONS").font(.sansRR(10, weight: .bold)).foregroundColor(.rText3).tracking(1)
                .padding(.horizontal, 4)

            ForEach(gamification.exerciseLog.suffix(5).reversed()) { entry in
                HStack(spacing: 10) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 16)).foregroundColor(.rAccent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.type).font(.sansRR(13, weight: .semibold)).foregroundColor(.rText)
                        Text("\(entry.minutes) min \u{00B7} \(entry.date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.sansRR(10)).foregroundColor(.rText3)
                    }
                    Spacer()
                    Text("+\(entry.minutes > 30 ? 30 : 20) XP")
                        .font(.sansRR(10, weight: .bold)).foregroundColor(.rAccent)
                }
                .padding(10)
                .background(Color.white.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
