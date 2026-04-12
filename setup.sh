#!/bin/bash
# ─────────────────────────────────────────────
#  ReRoot iOS — Xcode Project Setup Script
#  Team: Try { Quit } Catch { Relapse }
#  Cupertino Hack 2026
# ─────────────────────────────────────────────

set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo ""
echo "🌿  ReRoot iOS — Xcode Project Setup"
echo "──────────────────────────────────────"

# ── Try xcodegen (fastest path) ──
if command -v xcodegen &> /dev/null; then
    echo "✅  xcodegen found — generating project..."
    xcodegen generate
    echo "✅  ReRoot.xcodeproj generated"
    open ReRoot.xcodeproj
    exit 0
fi

# ── Try to install xcodegen via Mint ──
if command -v mint &> /dev/null; then
    echo "📦  Installing xcodegen via Mint..."
    mint install yonaskolb/XcodeGen
    mint run xcodegen generate
    open ReRoot.xcodeproj
    exit 0
fi

# ── Try Homebrew (may need network) ──
if command -v brew &> /dev/null; then
    echo "📦  Installing xcodegen via Homebrew..."
    brew install xcodegen && xcodegen generate && open ReRoot.xcodeproj
    exit 0
fi

# ── Manual Xcode setup instructions ──
echo ""
echo "⚠️  xcodegen not available. Follow these steps in Xcode:"
echo ""
echo "1. Open Xcode → File → New → Project"
echo "2. Choose: iOS → App"
echo "3. Settings:"
echo "   • Product Name:    ReRoot"
echo "   • Team:            Your team / Personal"
echo "   • Bundle ID:       com.tryquit.reroot"
echo "   • Interface:       SwiftUI"
echo "   • Language:        Swift"
echo "   • Minimum iOS:     17.0"
echo ""
echo "4. Save project to: $(pwd)"
echo ""
echo "5. In Xcode, right-click the project folder → 'Add Files to ReRoot'"
echo "   Select ALL files in: $(pwd)/Sources/"
echo "   ✓ Check 'Copy items if needed'"
echo ""
echo "6. Add HealthKit capability:"
echo "   • Click project → Signing & Capabilities → + Capability → HealthKit"
echo ""
echo "7. Add Location capability:"
echo "   • + Capability → Location When In Use"
echo ""
echo "8. Build & Run on simulator or device (⌘R)"
echo ""
echo "────────────────────────────────────────"
echo "  Team: Try { Quit } Catch { Relapse }"
echo "  Cupertino Hack 2026 · Health & Wellness"
echo "────────────────────────────────────────"
