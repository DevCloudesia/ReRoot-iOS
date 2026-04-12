# ReRoot — Complete Content Map

> This document reflects the actual content and flow in the Swift codebase.
> After editing, tell me "update the code from CONTENT_MAP.md" and I'll sync all the Swift files to match.

---

## App Flow Overview

```
Onboarding → Tree Landing (emotion select) → Guided Check-In → 3-Tab Main View
```

### Three-Tab Main View (MainTabView)

| Tab | Icon | View |
|-----|------|------|
| Stats | chart.bar.fill | StatsQuoteView — timer, quotes, stats, milestones, "Right Now" science, emergency help, nearby support |
| Skills | sparkles | SkillProgressView — 6 skill units, 25 total anti-nicotine skills with mastery tracking |
| Health | heart.text.square.fill | HealthIntegrationView — Apple Health data (HRV, sleep, steps, active minutes, goals) |

A floating "Check In Again" button above the tab bar re-opens the Tree Landing at any time.

### Guided Check-In Sequences (by mood)

The flow always starts with **Honest Lapse → Craving Check**, then diverges:

- **😣 Struggling (0):** (Lapse Debrief if lapsed) → Acknowledgement → Science → Five-Minute Boost → Action → Creative Activity → Claude Chat → Micro Commit → Pledge → End Quote → Complete
- **😟 Tough (1):** (Lapse Debrief if lapsed) → Acknowledgement → Science → Action → Creative Activity → Claude Chat → Micro Commit → Pledge → End Quote → Complete
- **😐 Steady (2):** (Lapse Debrief if lapsed) → Acknowledgement → Science → Action → Creative Activity → Claude Chat → Micro Commit → Pledge → End Quote → Complete
- **🙂 Good (3):** (Lapse Debrief if lapsed) → Acknowledgement → Future Self → Action → Creative Activity → Claude Chat → Micro Commit → Pledge → End Quote → Complete
- **😊 Thriving (4):** (Lapse Debrief if lapsed) → Acknowledgement → Future Self → Action → Creative Activity → Claude Chat → Micro Commit → Pledge → End Quote → Complete

If mood was pre-selected from the Tree Landing, the Emotion Select stage is skipped.

---

## 1. Tree Landing — Emotion Selector

The Tree Landing shows a growing tree (canopy/trunk/blossoms scale with days quit and tree health), a time-of-day greeting, day counter, honest streak badge, and mood selector using SF Symbol icons.

### Emotion Options

| Mood Index | SF Symbol | Label | Color |
|------------|-----------|-------|-------|
| 0 | bolt.heart.fill | Struggling | Red |
| 1 | cloud.rain.fill | Tough | Amber |
| 2 | minus.circle | Steady | Steel blue |
| 3 | sun.max.fill | Good | Green |
| 4 | sparkles | Thriving | Teal |

### Confirmation Overlay Text

| Index | Heading | Subtext |
|-------|---------|---------|
| 0 (Struggling) | Feeling struggling today? | It's okay to have hard days. We're here for you, and we have some things that might help. |
| 1 (Tough) | Feeling tough today? | Tough moments don't last forever. Let's take a few minutes together. |
| 2 (Steady) | Feeling steady today? | Steady is strong. Let's keep this going, one step at a time. |
| 3 (Good) | Feeling good today? | You're doing so well. Let's take a moment to appreciate that. |
| 4 (Thriving) | Feeling thriving today? | What a good day. Let's make the most of this feeling. |

For Struggling (0), an extra "Find support nearby" button opens the NearbyHelpView.

---

## 2. Honest Lapse Stage

The first stage of every check-in. Asks the user honestly whether they smoked, with options to report:
- Whether they smoked (yes/no)
- Whether they almost slipped
- How many cigarettes (if lapsed)
- What triggered the lapse
- What stopped them (if almost slipped)

Includes the user's honest-streak count and day number. No-judgment framing throughout.

---

## 3. Craving Check Stage

Immediately follows Honest Lapse. Asks the user to rate their craving intensity (0–10 scale). Adapts messaging based on whether a lapse was reported.

---

## 4. Lapse Debrief Stage

Only shown if the user reported smoking. Guides them through selecting a trigger and making a plan, then logs the lapse. Framing is compassionate — "a slip is not the end."

---

## 5. Emotion Select Stage

Shown when mood wasn't pre-selected from the Tree Landing. Five options with emoji, label, and description:

| Emoji | Label | Description |
|-------|-------|-------------|
| 😣 | Struggling | It's been really hard today |
| 😟 | Hanging in | Tough, but I'm still here |
| 😐 | Okay | Not great, not terrible |
| 🙂 | Good | Feeling more like myself |
| 😊 | Great | Genuinely feeling free today |

Context text adapts to lapse/craving status reported in prior stages.

---

## 6. Acknowledgement Stage — Content by Mood

Personalizes with userName, dayNum, elapsed time, money saved, cigarettes avoided. Shows the user's quit motivation if set. Surfaces a "future self message" for struggling users.

### Headlines (personalized with name)

| Mood | Headline |
|------|----------|
| 😣 Struggling | I see you, {name}. This is hard. |
| 😟 Tough | You're still here, {name}. That takes strength. |
| 😐 Steady | Steady and present, {name}. |
| 🙂 Good | Look at you, {name}. You're doing this. |
| 😊 Thriving | You're really doing it, {name}. |
| (If lapsed) | You came back, {name}. That's what matters. |

### Subheadlines

| Mood | Subheadline |
|------|-------------|
| 😣 | Day {X}. What you're going through right now is temporary, even though it doesn't feel like it. You don't have to do this alone. |
| 😟 | Day {X}. Tough days are part of getting free. The discomfort is your body adjusting to life without nicotine. |
| 😐 | Day {X}. Quiet days like this are where real change happens. You're building something, even when it feels ordinary. |
| 🙂 | Day {X}. Notice how this feels. This calm, this clarity. This is your natural state coming back. |
| 😊 | Day {X}. This lightness you're feeling? That's who you really are without nicotine. |
| (If lapsed) | Day {X}. A slip doesn't undo your progress. The fact that you're being honest about it shows real strength. |

### Body Text

| Mood | Body |
|------|------|
| 😣 | When it feels this hard, remember: cravings peak and then they pass. Usually within just a few minutes. You don't have to feel ready or strong. You just have to get through this moment. And we're right here with you. |
| 😟 | The restlessness, the irritability, the foggy thinking. These are signs your body is healing, not signs you're failing. Every uncomfortable moment is your brain learning to work without nicotine. It gets easier. |
| 😐 | Days like today might not feel like progress, but they are. Every ordinary smoke-free day rewires your brain a little more. You're quietly becoming someone who doesn't need cigarettes. |
| 🙂 | Can you feel it? The deeper breaths, the clearer thinking. That's your body thanking you. After {X} days, real physical healing is happening. You deserve to feel this good. |
| 😊 | This is what freedom feels like. Not just from cravings, but from the cycle of needing something just to feel normal. You've earned this. Take a moment to really feel proud of yourself. |
| (If lapsed) | A slip is not the end. It's a moment, not a direction. Be gentle with yourself. The progress you've made over {X} days is still real. Your body is still healing. And you're here, which means you haven't given up. |

### CTA Buttons

| Mood | Button Text |
|------|-------------|
| 😣 | Help me through this |
| 😟 | I could use some support |
| 😐 | Let's keep going |
| 🙂 | Let's build on this |
| 😊 | Let's celebrate this |
| (If lapsed) | I'm ready to keep going |

---

## 7. Science Stage — Content by Time Elapsed

| Time Since Quit | Phase Label | Headline | Body | Source |
|-----------------|-------------|----------|------|--------|
| < 1 hour | FIRST HOUR | Your Brain Is Sounding an Alarm | Nicotine binds to receptors that trigger dopamine release. Without it, those receptors are now firing distress signals — this feels urgent because your brain has been trained to treat it as an emergency. It isn't. It's just chemistry asking for something you've decided to stop giving it. | NIDA |
| 1–8 hours | HOUR {X} | Carbon Monoxide Is Leaving Your Blood | CO levels in your blood are dropping by half right now. Oxygen is reaching your tissues more efficiently than it has in years. Your heart, lungs, and brain are receiving cleaner fuel with every single breath you take. | American Lung Association |
| 8–24 hours | HOUR {X} | Dopamine Drought — Not Your Baseline | Nicotine hijacked your dopamine system. Your baseline is temporarily below normal — this is why things feel gray or irritable. This is neurochemical, not character. Research confirms it fully reverses within 2–4 weeks. You are not broken. You are recalibrating. | NIDA · Harvard Health |
| Day 2–3 | DAY {X} | This Is Peak Withdrawal | Days 2–3 are clinically the hardest phase. Your nicotinic receptors are downregulating — literally reducing in number to match a nicotine-free reality. Each hour you hold, fewer receptors demand attention. You are not failing. You are detoxing. | CDC · NIH |
| Day 3–7 | DAY {X} | Nerve Endings Are Regrowing | At 48 hours, damaged nerve endings begin regenerating — which is why your senses are sharpening. At 72 hours, bronchial tubes relax and breathing becomes physically easier. You can feel what is happening in your body right now. | Medical News Today · ALA |
| Day 7–14 | DAY {X} | Circulation Has Already Improved | Lung function is measurably improving. Walking and activity feel different — not because of fitness, but because your cardiovascular system is working better. That is a direct, documented result of not smoking. | American Lung Association |
| Day 14+ | DAY {X} | Your Brain Chemistry Has Shifted | Former smokers report significantly lower anxiety and depression than active smokers after recovery — the opposite of what most expect. The cigarettes didn't calm you. They relieved withdrawal while creating more of it. That loop is now broken. | Harvard Health · NCI |

Includes a visual withdrawal timeline bar showing the user's position within the 4-week withdrawal window.

CTA: "I understand — give me a boost →" (struggling/tough) or "Got it →" (steady+)

---

## 8. Five-Minute Boost — Activity Picker (Struggling only)

Instead of rotating messages, the user picks one of three interactive activities:

| Icon | Title | Description | Activity |
|------|-------|-------------|----------|
| lungs.fill | 4-7-8 Breathing | Guided animated pacer. Extended exhale activates your vagus nerve. | BreathingPacerView |
| water.waves | Urge Surfing | Ride a 3-minute animated wave. Watch the craving peak and dissolve. | UrgeSurfingView |
| number | Serial 7s | Count down from 1000 by 7s. Starve the craving of brain bandwidth. | Serial7sGameView |

---

## 9. Action Stage

Displays mood-adapted exercises from the ActivityDB (see section 17). Shown as expandable cards with steps, "why" science, and HealthKit logging.

---

## 10. Creative Activity Stage

User chooses one of four creative expression modes:

| Icon | Activity | Description |
|------|----------|-------------|
| paintbrush.pointed.fill | Free Doodle | Draw whatever comes to mind. No rules, no judgment. |
| text.quote | One-Line Poetry | Write one line on a theme. Express what words can hold. |
| book.fill | Journal | Write freely about what you're feeling. Your private space. |
| mic.fill | Voice Memo | Record your thoughts out loud. Sometimes voice says more. |

Doodle prompts are mood-specific (8 per mood level). Poetry themes and journal prompts also adapt to mood.

---

## 11. Claude AI Chat Stage

Powered by the Anthropic API. Provides personalized conversational support. The AI receives full context: day number, mood, craving intensity, lapse status, triggers, what stopped them, creative output, user name, and quit motivation. Includes ambient audio controls.

After the chat, the AI can reassess the user's mood (optional), which updates exercise/content recommendations downstream.

---

## 12. Micro Commitment Stage

The user picks a skill to practice tomorrow from the Quit Toolkit. Shows yesterday's commitment and whether they followed through. Builds accountability loops.

---

## 13. Future Self Stage (Good/Thriving moods only)

The user writes a message to their future self. These messages are surfaced later during struggling/tough check-ins via the Acknowledgement stage's "future message card."

---

## 14. Pledge Stage

Daily pledge to stay smoke-free. Tracks total pledges, current streak, and awards XP. If already pledged today, shows confirmation and skip option.

---

## 15. End Quotes — by Mood

### 😣😟 Struggling/Tough (pool of 4, rotates by day)

| Quote | Attribution |
|-------|-------------|
| The cigarette would end the craving. It would also restart everything — the withdrawals, the wiring, the whole cycle. You are minutes away from being stronger. | Recovery principle |
| Every craving you outlast makes the next one permanently weaker. You are not white-knuckling through this. You are rewiring your brain. | Neuroscience of addiction |
| What you're feeling is withdrawal making its final argument. Arguments end. You win by staying in the room. | Behavioral therapy |
| Don't quit quitting. The cigarette doesn't make you feel better — it makes withdrawal temporarily stop. There is a profound difference. | Allen Carr |

### 😐 Holding Steady (pool of 2)

| Quote | Attribution |
|-------|-------------|
| Not every day is dramatic. Some days you just don't smoke. That quiet stubbornness is how most long-term quits are won. | Recovery principle |
| Ordinary days aren't setbacks. They're proof that not smoking has become your default. That's the whole point. | Cognitive behavioral therapy |

### 🙂😊 Doing Well / Thriving (pool of 3)

| Quote | Attribution |
|-------|-------------|
| You didn't just quit smoking. You proved to your brain that you make the decisions — not the craving. | NIDA |
| This clarity, this control — this is what freedom actually feels like. Not temporary relief. Freedom. | Recovery insight |
| Days like this are why you quit. Your hard days are fighting for them. Don't let the hard days win. | Motivational interviewing |

---

## 16. Daily Quotes (Stats Tab — pool of 25, rotates by day-of-year)

| # | Quote | Author | Source |
|---|-------|--------|--------|
| 1 | The secret of getting ahead is getting started. | Mark Twain | Attributed, widely quoted |
| 2 | It does not matter how slowly you go as long as you do not stop. | Confucius | Analects of Confucius |
| 3 | You are stronger than your strongest craving. | Recovery Principle | NIDA addiction recovery framework |
| 4 | Every cigarette you don't smoke is a victory. | ReRoot | Based on CDC cessation milestones |
| 5 | The best time to quit was years ago. The second best time is right now. | Proverb | Adapted from Chinese proverb |
| 6 | Freedom is what you find on the other side of discomfort. | Allen Carr | The Easy Way to Stop Smoking, 1985 |
| 7 | What you're feeling is withdrawal, not weakness. Those are not the same thing. | NIDA | National Institute on Drug Abuse |
| 8 | Your addiction is making its argument. Arguments end. You win by not leaving the room. | Behavioral Therapy | CBT relapse prevention principles |
| 9 | The chains of habit are too light to be felt until they are too heavy to be broken. | Samuel Johnson | The Rambler, No. 134, 1751 |
| 10 | Quitting is not giving something up. It's getting everything back. | Recovery Insight | Allen Carr cognitive reframing approach |
| 11 | You don't need willpower to quit smoking; you need understanding. | Cognitive Reframing | CBT-based cessation therapy |
| 12 | I am not a smoker who is trying to quit. I am a non-smoker making a comeback. | Identity Shift | Self-determination theory (Deci & Ryan) |
| 13 | Quitting smoking is not a sacrifice; it's a liberation. | Allen Carr | The Easy Way to Stop Smoking, 1985 |
| 14 | The urge to smoke will pass whether you smoke or not. | MBRP | Mindfulness-Based Relapse Prevention (Marlatt) |
| 15 | Health is not valued till sickness comes. | Thomas Fuller | Gnomologia, 1732 |
| 16 | Progress, not perfection. | CBT Principle | Cognitive Behavioral Therapy foundations |
| 17 | Quitting is hard. Staying addicted is harder. | Consequence Reframing | Motivational interviewing framework |
| 18 | Strength does not come from physical capacity. It comes from an indomitable will. | Mahatma Gandhi | Attributed, widely quoted |
| 19 | Freedom from nicotine addiction is the greatest gift you can give yourself. | Intrinsic Reward | Self-determination theory (Deci & Ryan) |
| 20 | You're not giving up tobacco. You're gaining back your life. | Positivity Offset | Positive psychology (Seligman) |
| 21 | The cigarette didn't calm you. It relieved withdrawal while creating more of it. | Harvard Health | Harvard Health Publishing — anxiety/smoking paradox |
| 22 | Every craving you outlast makes the next one permanently weaker. | Neuroscience | Nicotinic receptor downregulation research (NIDA) |
| 23 | One day or day one. You decide. | Recovery Wisdom | Common in addiction recovery communities |
| 24 | Your lungs are healing right now. Every breath is proof. | ALA | American Lung Association recovery timeline |
| 25 | Quitting smoking is not about giving up pleasure; it's about giving up poison. | Aversive Conditioning | Behavioral conditioning therapy principles |

---

## 17. Exercises Tab — 30 Activities, 5 Mood Pools (ExercisesView / ActivityDB)

Each pool has 6 activities. Four are shown at a time (shuffled). Each has an icon, name, duration, intensity, category, "why" science explanation, and step-by-step instructions. Activities can be logged for XP and saved to Apple Health.

### 😣 Struggling — Crisis Intervention (6)

| Icon | Name | Duration | Intensity | Type | Category |
|------|------|----------|-----------|------|----------|
| snowflake | Mammalian Dive Reflex — Cold Splash | 3 min | Low | Cold Exposure | Crisis Intervention |
| lungs.fill | 4-7-8 Autonomic Reset | 5 min | Low | Breathing | Immediate Relief |
| bolt.fill | Burpee Protocol — Endorphin Flush | 5 min | High | HIIT | Energy Release |
| water.waves | Urge Surfing — MBRP Visualization | 5 min | Low | Mindfulness | Mental |
| number | Serial 7s — Math Distraction | 3 min | Low | Cognitive | Mental |
| cloud.fill | Guided Mental Escape | 5 min | Low | Visualization | Mental |

### 😟 Tough — Distress Tolerance (6)

| Icon | Name | Duration | Intensity | Type | Category |
|------|------|----------|-----------|------|----------|
| figure.stand | Isometric Wall Sit — 90 Seconds | 5 min | Moderate | Isometric | Distress Tolerance |
| bus.fill | Passengers on the Bus — ACT | 5 min | Low | ACT | Mental |
| timer | 30-Minute Delay Commitment | 30 min | Low | Behavioral | Delay Tactic |
| hand.raised.fingers.spread | Progressive Muscle Relaxation | 8 min | Low | Relaxation | Tension Release |
| ear.fill | 5-4-3-2-1 Sensory Grounding | 5 min | Low | Grounding | Mental |
| figure.walk | Environment Change Walk | 10 min | Low | Walking | Craving Relief |

### 😐 Steady — Maintenance Protocol (6)

| Icon | Name | Duration | Intensity | Type | Category |
|------|------|----------|-----------|------|----------|
| figure.walk | Brisk Environmental Walk | 20 min | Moderate | Walking | Cardio |
| figure.outdoor.cycle | Rhythmic Aerobic Cycling | 25 min | Moderate | Cycling | Cardio |
| figure.mind.and.body | Restorative Yoga — Tension Release | 15 min | Low | Yoga | Mind-Body |
| pencil.line | Gratitude Amplification Journal | 10 min | Low | Journaling | Mental |
| magnifyingglass | Environmental Trigger Audit | 10 min | Low | CBT | Mental |
| fork.knife | Post-Meal Routine Alteration | 10 min | Low | Behavioral | Habit Replacement |

### 🙂 Doing Well — Momentum Building (6)

| Icon | Name | Duration | Intensity | Type | Category |
|------|------|----------|-----------|------|----------|
| dumbbell.fill | Compound Strength Training | 30 min | Moderate-High | Strength | Strength |
| music.note | Euphoric Dance — Auditory-Motor | 15 min | Moderate | Dance | Joy |
| figure.outdoor.cycle | Rhythmic Cycling — 20 Minutes | 20 min | Moderate | Cycling | Cardio |
| dollarsign.circle | Experiential Reward Scheduling | 10 min | Low | Planning | Mental |
| person.fill | Non-Smoker Identity Affirmation | 10 min | Low | Identity | Mental |
| figure.hiking | Nature Trail Hike | 30 min | Moderate | Hiking | Nature |

### 😊 Thriving — Peak Performance (6)

| Icon | Name | Duration | Intensity | Type | Category |
|------|------|----------|-----------|------|----------|
| flame.fill | HIIT Euphoria Protocol | 20 min | High | HIIT | Intensity |
| figure.pool.swim | Vigorous Lap Swimming | 25 min | High | Swimming | Full Body |
| figure.boxing | Shadow Boxing Power | 15 min | High | Boxing | Power |
| message.fill | Prosocial Support Sharing | 10 min | Low | Social | Mental |
| target | Future Goal Anchoring | 10 min | Low | Planning | Mental |
| figure.run | Tempo Run — Proof of Healing | 30 min | High | Running | Cardio |

### Exercise Science Bullets (per-mood, shown below cards)

**Struggling (0):**
- Cold water on face triggers the mammalian dive reflex — heart rate drops 10-25% in seconds
- Serial subtraction demands high working memory from the prefrontal cortex, starving the amygdala
- Urge surfing (MBRP) creates a cognitive gap between stimulus and response
- High-impact burpees flood the system with endorphins while demanding total cognitive presence

**Tough (1):**
- Isometric holds require continuous neuromuscular engagement, diverting neural bandwidth from cravings
- The 30-minute delay exploits the temporal nature of cravings — dopaminergic urgency cannot sustain itself
- 5-4-3-2-1 sensory grounding disrupts the default mode network's craving loops
- ACT's cognitive defusion teaches that cravings are noise with no motor control over your body

**Steady (2):**
- Moderate exercise 3x/week is the strongest behavioral predictor of quit success
- Exercise produces BDNF — a protein that grows new neural connections to replace nicotine-damaged ones
- Gratitude uniquely alters temporal discounting, reducing inclination toward immediate gratification
- Environmental trigger auditing transitions you from passive victim to active investigator

**Good (3):**
- Resistance training restores testosterone and growth hormone levels suppressed by nicotine
- Anticipating preferred music releases dopamine in the striatum — combined with cardio = supercharged reward
- Identity shift from 'ex-smoker' to 'non-smoker' is statistically the strongest predictor of long-term abstinence
- Nature + exercise reduces cravings 40% more than indoor exercise alone (University of Exeter)

**Thriving (4):**
- HIIT produces massive endorphins and endocannabinoids, retraining nicotine-hijacked neural circuitry
- Lap swimming demands regulated breathing against resistance — a profound physiological victory
- Sharing milestones leverages social accountability; positive validation releases oxytocin and serotonin
- Former smokers who exercise regularly report lower anxiety than when they smoked (Harvard Health)

---

## 18. Quit Toolkit — Skills Tab (SkillProgressView)

6 skill units with 25 total skills. Each skill tracks practice count and mastery level (new → learning → practiced → mastered).

### Unit 1: Craving Emergency Kit (flame.fill)
| Skill ID | Name |
|----------|------|
| breathing-fourSevenEight | 4-7-8 Anti-Craving Breath |
| breathing-boxBreathing | Box Breathing for Urges |
| breathing-physiologicalSigh | Physiological Sigh |
| urgeSurf | Nicotine Urge Surfing |
| iceDive | Craving Emergency Reset |

### Unit 2: Fighting Smoking Thoughts (brain.head.profile)
| Skill ID | Name |
|----------|------|
| thoughtDefusion | Quit-Thought Defusion |
| cognitiveReframe | Smoking Thought Reframe |
| serial7s | Craving Bandwidth Steal |

### Unit 3: Withdrawal Body Tools (figure.mind.and.body)
| Skill ID | Name |
|----------|------|
| bodyScan | Withdrawal Tension Release |
| sensory | 5-4-3-2-1 Grounding |
| squareTrace | Craving Calm Trace |
| butterflyTap | Craving Calm Tap |
| fingerTap | Craving Redirect |

### Unit 4: Non-Smoker Identity (heart.fill)
| Skill ID | Name |
|----------|------|
| gratitudeGarden | Smoke-Free Gratitude |
| affirmationCards | Quit Affirmations |
| lovingKindness | Self-Compassion for Quitters |
| visualization | Smoke-Free Visualization |

### Unit 5: Withdrawal Awareness (leaf.fill)
| Skill ID | Name |
|----------|------|
| emotionWheel | Withdrawal Feeling ID |
| colorBreathing | Clean Air Breathing |
| mindfulListening | Craving Interrupt |

### Unit 6: Life Without Nicotine (sparkles)
| Skill ID | Name |
|----------|------|
| wordScramble | Quit Word Scramble |
| safePlaceBuilder | Smoke-Free Sanctuary |
| joyMapping | Smoke-Free Joy Map |
| patternMemory | Impulse Control Training |
| celebrationBreath | Celebrate Your Quit |

Each skill has a dedicated SwiftUI view in `Sources/Views/Activities/`.

---

## 19. Withdrawal Symptoms (SymptomsView / RecoveryData)

8 symptoms, each with icon, onset, peak, duration, science explanation, tips, source, and a dynamic intensity curve based on elapsed time.

| Icon | Symptom | Onset | Peak | Duration | Source |
|------|---------|-------|------|----------|--------|
| 🔥 | Cravings | Within 1–2 hours | Day 2–3 | 2–4 weeks | CDC / NCI |
| 😤 | Irritability | Within 24 hours | Day 3–5 | 2–4 weeks | CDC / NIDA |
| 😰 | Anxiety | Within 24 hours | Day 3 | 2–4 weeks | CDC / Harvard Health / NIH |
| 🧠 | Difficulty Focusing | Within 24 hours | Day 3–5 | 1–2 weeks | NIDA / Cleveland Clinic |
| 🌙 | Insomnia | Day 1–3 | First week | 2–4 weeks | Smokefree.gov / Cleveland Clinic |
| 🍽️ | Increased Appetite | Within 24 hours | Week 1–2 | Several weeks | Harvard Health / NCI / WebMD |
| 😔 | Low Mood | Day 1–3 | First 2 weeks | Under 1 month | NCI / Mayo Clinic / Cleveland Clinic |
| ⚡ | Restlessness | Day 1–3 | First week | 2–4 weeks | CDC / Smokefree.gov |

Each symptom has 5–6 actionable coping tips with sources.

---

## 20. "Right Now" Science Cards (Stats Tab — by time elapsed)

| Time | Title | Body |
|------|-------|------|
| < 30 min | The moment of freedom | Your last cigarette is behind you. In 20 minutes your heart rate begins dropping. This is the most important decision you'll make today. |
| 30 min – 2 hrs | First cravings arriving | Nicotine levels are dropping and receptors are sending urgency signals. These feel overwhelming but last only 3–5 minutes. Ride the wave — don't fight it. |
| 2–8 hrs | Your blood is cleaning | Carbon monoxide — the same gas in car exhaust — is leaving your bloodstream. Every breath is measurably better than an hour ago. |
| 8–24 hrs | Your brain is adjusting | Nicotine disrupted natural dopamine. Without it, irritability and anxiety may spike. This is neurochemical — not weakness. |
| 24–48 hrs | 24 hours — real victory | CO is fully eliminated. Your lungs are actively clearing debris. Taste and smell receptors are beginning to wake up. |
| 48–72 hrs | Nerve endings regrowing | At 48 hours, nerve endings literally regrow. Day 3 is typically peak withdrawal intensity. You are here. You are stronger than this. |
| Day 3–7 | Past the worst | The acute peak is behind you. Bronchial tubes are relaxing, breathing is getting easier. |
| Day 7–14 | One week — lungs healing | Measurable lung function improvement is beginning. Sleep quality is restoring. You did the hardest part. |
| Day 14–30 | Two weeks of freedom | Circulation has improved ~30%. Exercise feels different. Brain reward pathways are actively rewiring. |
| Day 30–90 | One month smoke-free | Coughing decreases. Cilia in lungs have regrown. Former smokers report lower anxiety than when they smoked. |
| Day 90+ | You've changed your life | Brain chemistry, cardiovascular health, and lung capacity have all measurably improved. You are not a smoker who quit — you are a non-smoker. |

---

## 21. Recovery Milestones

| Time | Label | Title | Body | Source |
|------|-------|-------|------|--------|
| 20 min | 20 min | Heart Stabilizing | Heart rate drops and blood pressure becomes more stable. | American Lung Association |
| 8 hrs | 8 hrs | Oxygen Returning | CO levels drop by half. Oxygen reaches normal levels in your blood. | Better Health Channel |
| 24 hrs | 24 hrs | Lungs Clearing | CO fully eliminated. Lungs begin pushing out mucus and debris. | American Lung Association |
| 48 hrs | 48 hrs | Senses Awakening | Nerve endings begin regrowing. Taste & smell dramatically improve. | Medical News Today |
| 72 hrs | 72 hrs | Breathing Easier | Bronchial tubes relax. Lung capacity noticeably increases. Energy up. | Medical News Today |
| 2 weeks | 2 wks | Circulation Improving | Lung function begins improving. Walking and exercise become noticeably easier. | American Lung Association |
| 1 month | 1 mo | Cilia Regrowing | Coughing decreases. Cilia in lungs regrow, reducing infection risk. | American Cancer Society |
| 3 months | 3 mo | Lung Function Up | Circulation substantially better. Lung capacity significantly improved. | American Lung Association |
| 9 months | 9 mo | Major Lung Recovery | Lung function up 10%. Fatigue and shortness of breath greatly reduced. | American Cancer Society |
| 1 year | 1 yr | Heart Disease Risk Halved | Coronary heart disease risk is now half that of an active smoker. | Surgeon General Report |
| 5 years | 5 yrs | Stroke Risk Normalized | Stroke risk equals that of a lifelong non-smoker. | American Cancer Society |
| 10 years | 10 yrs | Lung Cancer Risk Halved | Lung cancer death risk cut in half vs. continuing smokers. | American Cancer Society |

---

## 22. Craving Missions (SOS popup — shuffled)

| Icon | Mission | Category |
|------|---------|----------|
| figure.walk | Walk for 5 minutes — cravings peak in 3 min then pass | Move |
| drop.fill | Drink a full glass of ice-cold water, slowly | Physical |
| carrot | Eat something crunchy: carrots, apple, or celery | Physical |
| phone.fill | Call or text someone who supports your quit | Connect |
| music.note | Play the one song that makes you feel powerful | Emotional |
| bolt.fill | Do 20 jumping jacks — flush the craving with endorphins | Move |
| pencil | Write 3 specific reasons you are quitting right now | Mental |
| lungs.fill | Do one 4-7-8 breathing cycle right now | Breathe |
| faceid | Brush your teeth — the clean feeling disrupts the craving loop | Physical |
| brain | Count backwards from 100 by 7s — forces full brain focus | Mental |

---

## 23. Breathing Exercises

| Name | Inhale | Hold | Exhale | Hold After | Description |
|------|--------|------|--------|------------|-------------|
| 4-7-8 Calm | 4s | 7s | 8s | 0s | Activates the parasympathetic nervous system. Best for intense cravings and anxiety spikes. |
| Box Breathing | 4s | 4s | 4s | 4s | Used by Navy SEALs for focus under stress. Perfect for irritability and racing thoughts. |
| 2-4 Quick Reset | 2s | 0s | 4s | 0s | Fast craving relief when you can't step away. Works in under 60 seconds. |

---

## 24. Journal (JournalView)

12 rotating prompts from RecoveryData.journalPrompts:

1. What triggered a craving today, and what did I do instead?
2. What physical improvement have I noticed since quitting?
3. How am I feeling emotionally right now — be honest.
4. What would I tell a friend who is thinking about quitting?
5. What am I most proud of in my recovery so far?
6. What healthy habit is replacing my old smoking habit?
7. Describe a moment today when I felt genuinely free.
8. What's the hardest part right now, and what is helping?
9. How has quitting changed how I feel about myself?
10. What will my life look like in one year smoke-free?
11. The CDC says to 'ride the wave' of cravings. How did I ride mine today?
12. What environment changes have I made to remove smoking triggers?

Science context shown at top: "Writing externalizes cravings and triggers, helping your brain process them instead of act on them."

---

## 25. Health Integration Tab (HealthIntegrationView)

Apple HealthKit-powered dashboard with:
- **Daily Goals** — Editable step count and active minutes goals with progress rings
- **Activity Card** — Steps, active minutes, resting heart rate with ring visualization
- **Health Metrics Grid** — HRV, sleep, steps, active minutes
- **HRV Analysis** — Latest vs. 7-day average, trend (rising/dropping/stable), stress detection
- **Sleep Recovery** — Hours, quality bar, sleep advice based on duration
- **Start Workout** — Opens Apple Fitness app
- **Fitness + Recovery Science** — 5 evidence-based recovery facts with sources

---

## 26. Wellness View (WellnessView)

Includes:
- **Relapse Risk Score** — JITAI-based composite score from mood, cravings, sleep, HRV, and lapse history
- **HRV Panel** with stress detection
- **Sleep & Activity biometrics**
- **Exercise logging** with HealthKit integration
- **Supplement tracking** (NRT, medications)

---

## 27. Nearby Help (NearbyHelpView)

Location-based search for nearby substance abuse/mental health support centers using MapKit. Shows distance, driving time, phone number, and directions button. Integrated into the Stats tab and Tree Landing.

---

## 28. Nudge Engine (NudgeEngine)

JITAI-based notification system with categories:
- **JITAI nudges** — Triggered by HRV stress signals or high craving intensity
- **Loss Aversion** — Framing around protecting streaks and savings
- **Kindling** — Momentum-based encouragement
- **Evening check-in reminders** — If pledge not completed
- **Morning momentum reminders**

---

## 29. Gamification (GamificationModel)

- **XP system** — Earned from check-ins, pledges, exercises, skill practice
- **Achievements** — Milestone-based badges
- **Digital Chips** — Sobriety milestones (24h, 1 week, 1 month, etc.)
- **Streak tracking** — Daily pledge streaks
- **Recovery insights** — Personalized tips based on behavior patterns

---

## 30. Help Resources

| Name | Contact | Description | Available |
|------|---------|-------------|-----------|
| SAMHSA National Helpline | 1-800-662-4357 | Free, confidential treatment referral and information service for substance use disorders. Available in English and Spanish. | 24/7 · Free · Confidential |
| CDC Quitline | 1-800-784-8669 | 1-800-QUIT-NOW. Free quit coaching, cessation medications, and personalized quit plans from trained counselors. | Free · Multiple languages |
| 988 Crisis Lifeline | 988 | Call or text 988 for mental health crises. Also supports people experiencing severe withdrawal-related distress. | 24/7 · Call or Text 988 |
| Crisis Text Line | Text HOME to 741741 | Text-based crisis support. Type HOME to 741741 for immediate confidential help from a trained crisis counselor. | 24/7 · Text-based |
| Veterans Crisis Line | 988 · Press 1 | Dedicated support for veterans. Call 988 and press 1. Also serves active service members and their families. | 24/7 · Veterans & Military |
| Emergency Services | 911 | For severe withdrawal emergencies. Alcohol and benzodiazepine withdrawal can be life-threatening. Don't wait. | Emergency Only |

---

## 31. File Architecture

```
Sources/
├── App/
│   └── ReRootApp.swift              — @main entry, SplashView, Color/Font extensions
├── Assets.xcassets/                  — AccentColor, AppIcon (1024px)
├── Info.plist
├── ReRoot.entitlements
├── Managers/
│   ├── HealthKitManager.swift        — HRV, sleep, steps, active min, workout saving
│   ├── LocationManager.swift         — Nearby places, geocoding
│   └── NudgeEngine.swift             — JITAI nudges, notifications, banners
├── Models/
│   ├── AppState.swift                — Core state: quit time, mood, journal, lapse, skills
│   ├── GamificationModel.swift       — XP, achievements, chips, supplements, exercises
│   └── RecoveryData.swift            — Milestones, symptoms, breathing, help, craving missions, journal prompts
├── Services/
│   ├── AmbientAudioManager.swift     — Background calming audio
│   ├── AnthropicService.swift        — Claude API actor for AI chat
│   ├── KeychainManager.swift         — Secure storage
│   └── Secrets.swift                 — API keys
└── Views/
    ├── MainTabView.swift             — 3-tab container, shared UI components
    ├── TreeLandingView.swift         — Growing tree, mood selector, confirm overlay
    ├── GuidedCheckInFlow.swift       — Full check-in flow with all stages
    ├── StatsQuoteView.swift          — Stats tab: timer, quotes, milestones, help
    ├── SkillProgressView.swift       — Skills tab: 6 units, mastery tracking
    ├── HealthIntegrationView.swift   — Health tab: HealthKit dashboard
    ├── HomeView.swift                — Home view (pledge, SOS, check-in entry)
    ├── ExercisesView.swift           — 30 activities with mood-adaptive pools
    ├── WellnessView.swift            — Relapse risk, HRV, supplements
    ├── BreathingView.swift           — Breathing exercise launcher
    ├── ResourcesView.swift           — Help resources, nearby places
    ├── SymptomsView.swift            — Withdrawal symptoms with intensity curves
    ├── JournalView.swift             — Journal with rotating prompts
    ├── ProgressView.swift            — Charts: savings, cravings, mood trends
    ├── OnboardingView.swift          — First-run setup
    ├── ClaudeChatView.swift          — AI conversational support
    ├── CreativeActivityStage.swift   — Doodle/poetry/journal/voice picker
    ├── NearbyHelpView.swift          — MapKit-based support center finder
    ├── SourcesView.swift             — Scientific citations
    ├── StatsQuoteView.swift          — Stats tab content
    └── Activities/                   — 27 interactive skill views
        ├── AffirmationCardsView.swift
        ├── BodyScanView.swift
        ├── BreathingPacerView.swift
        ├── ButterflyTapView.swift
        ├── CelebrationBreathView.swift
        ├── CognitiveReframeView.swift
        ├── ColorBreathingView.swift
        ├── DoodleCanvasView.swift
        ├── EmotionWheelView.swift
        ├── FingerTapView.swift
        ├── GratitudeGardenView.swift
        ├── IceDiveView.swift
        ├── JournalEntryView.swift
        ├── JoyMappingView.swift
        ├── LovingKindnessView.swift
        ├── MindfulListeningView.swift
        ├── OneWordPoetryView.swift
        ├── PatternMemoryView.swift
        ├── SafePlaceBuilderView.swift
        ├── SensoryGroundingView.swift
        ├── Serial7sGameView.swift
        ├── SquareTraceView.swift
        ├── ThoughtDefusionView.swift
        ├── UrgeSurfingView.swift
        ├── VisualizationJourneyView.swift
        ├── VoiceMemoView.swift
        └── WordScrambleView.swift
```

---

## HOW TO EDIT

1. **Add/change/remove rows** in any table above
2. **Add new sections** if you want new content areas
3. When you're done, tell me "update the code from CONTENT_MAP.md" and I'll sync all the Swift files to match your edits
