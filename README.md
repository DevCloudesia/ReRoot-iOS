# ReRoot

**A behavioral science-driven tobacco cessation app built with SwiftUI.**

BY: `try {quit} catch {retreat}`

---

## What It Does

ReRoot helps people quit smoking through daily guided check-ins, evidence-based therapeutic activities, anonymous AI support chat, and real-time health tracking. Unlike generic wellness apps, every feature is specifically designed around tobacco cessation science.

### Core Flow

```
Onboarding → Tree Landing (mood select) → Guided Check-In → Main Dashboard
```

1. **Onboarding** collects the user's name, personal triggers, quit motivation, and quit start time
2. **Tree Landing** shows a growing tree that reflects their recovery journey, with mood-based check-in entry
3. **Guided Check-In** is a 5-minute adaptive flow that changes based on honest self-reporting
4. **Main Dashboard** shows live progress stats, recovery insights, and nearby support resources

---

## Key Features

### Honest Reporting System
- Multi-step check-in: honest lapse reporting → craving intensity → mood assessment
- If they smoked: asks for top 3 triggers (text input)
- If they almost smoked: asks what stopped them and what nearly triggered them
- If smoke-free: skips follow-up, celebrates the win
- All responses stay 100% on-device. Privacy badge displayed throughout.

### 25 In-App Therapeutic Activities
Five activities per mood level (Struggling through Thriving), all fully interactive:

| Category | Activities |
|----------|-----------|
| Breathing | 4-7-8 Pacer, Box Breathing, Color Breathing, Square Trace, Celebration Breath |
| Grounding | 5-4-3-2-1 Sensory (typeable), Ice Dive Reset, Body Scan, Mindful Listening |
| Cognitive | Thought Defusion, Cognitive Reframe, Urge Surfing, Serial 7s, Word Scramble |
| Creative | Doodle Canvas, One-Word Poetry, Journal Entry, Voice Memo (with speech-to-text) |
| Wellness | Butterfly Tap, Finger Tap, Loving-Kindness, Visualization Journey, Gratitude Garden |

Each activity has distinct visuals, animations, step counters, and is calibrated to complete within the 5-minute check-in window.

### AI Support Chat (Claude Haiku)
- Anonymous, zero-trace streaming chat powered by Claude Haiku 4.5
- Receives full check-in context: lapse status, triggers, craving level, mood, quit motivation, and voice memo transcripts
- Focused specifically on tobacco cessation support
- Auto-detects goodbye signals and provides mood reassessment
- API key stored in iOS Keychain

### Growing Tree Visualization
- Animated tree that grows from a seedling based on days smoke-free
- Responds to check-in honesty and consistency
- Subtle breathing animation
- Blossoms appear as the tree matures
- Visually wilts on lapse days, recovers over time

### Live Progress Dashboard
- Real-time smoke-free timer (days, hours, minutes, seconds)
- Weekly check-in tracker (7-day circle row with checkmarks)
- Daily pledge system with streak tracking
- Money saved calculator
- Recovery milestones with medical sources (20 min → 10 years)
- 25 mood-aware rotating quotes with scientific citations

### Nearby Support Resources
- MapKit integration searching within 7.5 miles for treatment centers, counseling, and behavioral health
- Parallel search across 7 query categories
- Closest center shown with distance and drive time
- One-tap directions via Apple Maps, one-tap calling
- Emergency help card: 1-800-QUIT-NOW, 988 Crisis Line, Text QUIT to 741741

### Apple Health Integration
- HealthKit for HRV, sleep, steps, and active minutes
- Configurable daily goals (steps, active minutes)
- JITAI-style nudge engine that evaluates stress signals from biometrics

---

## Behavioral Science Foundation

ReRoot's design is grounded in established behavioral science frameworks:

- **Motivational Interviewing (MI):** Non-judgmental language throughout. The app never shames a lapse. Follow-up questions explore triggers, not failure.
- **Self-Determination Theory (SDT):** Autonomy (choose your own activity), competence (visible progress), relatedness (AI companion, anonymous support).
- **Behavioral Economics:** Daily pledge as a commitment device. Streak mechanics. Loss aversion via visible tree health.
- **Duolingo-style Engagement:** Check-in streaks, weekly tracker, adaptive difficulty, micro-commitments, gentle accountability.
- **JITAI (Just-In-Time Adaptive Interventions):** Nudge engine evaluates HealthKit biometrics + time-of-day + quit stage to deliver context-appropriate support.

All recovery content (milestones, science cards, symptom data) is sourced from:
- National Institute on Drug Abuse (NIDA)
- American Lung Association
- American Cancer Society
- CDC / Surgeon General Reports
- Harvard Health / Medical News Today

---

## Technical Architecture

### Stack
- **SwiftUI** — 100% declarative UI, no UIKit
- **Swift 5.9** — iOS 17.0+ deployment target
- **XcodeGen** — `project.yml` generates the Xcode project
- **No third-party dependencies** — everything is built with Apple frameworks

### Frameworks Used
| Framework | Purpose |
|-----------|---------|
| SwiftUI | All views, animations, gestures |
| HealthKit | HRV, sleep, steps, workout tracking |
| MapKit + CoreLocation | Nearby support center search and routing |
| AVFoundation | Voice memo recording and playback |
| Speech | On-device voice-to-text transcription |
| Security | Keychain storage for API keys |
| UserNotifications | JITAI nudges and check-in reminders |

### Project Structure
```
Sources/
├── App/
│   └── ReRootApp.swift              # @main entry, splash screen, routing
├── Models/
│   ├── AppState.swift               # Global state, persistence, quit timer
│   ├── GamificationModel.swift      # Streaks, achievements, pledges
│   └── RecoveryData.swift           # Milestones, symptoms, breathing exercises, quotes
├── Managers/
│   ├── HealthKitManager.swift       # HRV, sleep, steps, workout integration
│   ├── LocationManager.swift        # CLLocationManager wrapper
│   └── NudgeEngine.swift            # JITAI nudge evaluation and scheduling
├── Services/
│   ├── AnthropicService.swift       # Claude Haiku streaming chat client
│   ├── KeychainManager.swift        # Secure key storage
│   ├── AmbientAudioManager.swift    # Audio manager (stub)
│   └── Secrets.swift                # API key bootstrap
├── Views/
│   ├── TreeLandingView.swift        # Daily tree + mood selection
│   ├── GuidedCheckInFlow.swift      # Multi-stage adaptive check-in
│   ├── ClaudeChatView.swift         # AI support chat
│   ├── MainTabView.swift            # 3-tab navigation shell
│   ├── StatsQuoteView.swift         # Stats dashboard + quotes
│   ├── OnboardingView.swift         # First-launch onboarding
│   ├── NearbyHelpView.swift         # Map-based support finder
│   ├── SkillProgressView.swift      # Activity catalog
│   ├── HealthIntegrationView.swift  # Apple Health dashboard
│   └── [10 more view files]
└── Views/Activities/                # 27 interactive therapeutic activities
    ├── BreathingPacerView.swift
    ├── SensoryGroundingView.swift
    ├── DoodleCanvasView.swift
    ├── VoiceMemoView.swift          # Recording + speech-to-text
    └── [23 more activity files]
```

### Data & Privacy
- **All user data stays on-device** via `UserDefaults` and `JSONEncoder`
- **API key** stored in iOS Keychain, never in UserDefaults
- **AI chat is zero-trace** — no conversation history is persisted
- **Location** used only for real-time nearby search, never stored or transmitted
- **Voice memos** transcribed on-device via Apple's Speech framework, never uploaded

---

## Building & Running

### Prerequisites
- Xcode 16+ with iOS 17.0+ SDK
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

### Steps
```bash
cd ReRoot-iOS
xcodegen generate
open ReRoot.xcodeproj
# Build and run on simulator or device (Cmd+R)
```

Or from the command line:
```bash
xcodegen generate
xcodebuild -project ReRoot.xcodeproj -target ReRoot -sdk iphonesimulator -arch arm64 build
xcrun simctl install booted build/Debug-iphonesimulator/ReRoot.app
xcrun simctl launch booted com.tryquit.reroot
```

---

## What Makes ReRoot Different

| Generic Wellness App | ReRoot |
|---------------------|--------|
| Generic meditation | Tobacco-specific therapeutic activities |
| Self-reported mood only | Honest lapse reporting with trigger analysis |
| Static content | Adaptive flow that changes based on craving intensity, mood, and lapse status |
| No accountability | Daily pledge system, streak tracking, weekly visual tracker |
| Generic chatbot | AI companion with full check-in context, focused on tobacco cessation |
| No crisis support | Emergency helplines + nearest treatment center with directions |
| Trust us with your data | 100% on-device storage, zero-trace chat, privacy badges throughout |

---

*Built at Cupertino Hack 2026.*
