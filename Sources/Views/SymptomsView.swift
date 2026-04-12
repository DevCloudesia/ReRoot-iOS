import SwiftUI

struct SymptomsView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedSymptom: Symptom?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Right Now Banner
                    let rn = state.rightNow
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 7) {
                            Circle().fill(state.phaseColor).frame(width: 7, height: 7)
                                .shadow(color: state.phaseColor, radius: 3)
                            Text("HOUR \(Int(state.elapsed / 3600)) OF YOUR QUIT")
                                .font(.sansRR(10, weight: .bold))
                                .foregroundColor(state.phaseColor)
                                .tracking(1.5)
                        }
                        Text(rn.title)
                            .font(.serif(18, weight: .bold))
                            .foregroundColor(.rText)
                        Text(rn.body)
                            .font(.sansRR(13))
                            .foregroundColor(.rText2)
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(state.phaseColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(state.phaseColor.opacity(0.2), lineWidth: 1))

                    // Medical fact banner
                    HStack(spacing: 10) {
                        Image(systemName: "info.circle.fill").foregroundColor(.rAccent)
                        Text("Peak withdrawal is around day 3. All symptoms resolve within 2–4 weeks. — CDC / NCI")
                            .font(.sansRR(12))
                            .foregroundColor(.rAccent)
                    }
                    .padding(12)
                    .background(Color.rAccent.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Symptoms list
                    let active = state.activeSymptoms
                    if active.isEmpty {
                        RRCard {
                            VStack(spacing: 10) {
                                Text("🌱").font(.system(size: 44))
                                Text("Acute withdrawal symptoms have resolved.")
                                    .font(.sansRR(15, weight: .semibold))
                                    .foregroundColor(.rText)
                                    .multilineTextAlignment(.center)
                                Text("Your body is in a sustained healing phase.")
                                    .font(.sansRR(13))
                                    .foregroundColor(.rText3)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    } else {
                        Text("TAP ANY SYMPTOM FOR COPING STRATEGIES")
                            .font(.sansRR(10, weight: .bold))
                            .foregroundColor(.rText3)
                            .tracking(1)

                        ForEach(active, id: \.symptom.id) { item in
                            Button { selectedSymptom = item.symptom } label: {
                                SymptomRow(symptom: item.symptom, intensity: item.intensity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color.rBg.ignoresSafeArea())
            .navigationTitle("Right Now")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedSymptom) { sym in
                SymptomDetailView(symptom: sym, intensity: state.activeSymptoms.first(where: { $0.symptom.id == sym.id })?.intensity ?? 0)
            }
        }
    }
}

struct SymptomRow: View {
    let symptom: Symptom
    let intensity: Double

    var intensityLabel: String {
        intensity > 0.7 ? "High" : intensity > 0.4 ? "Moderate" : "Mild"
    }
    var intensityColor: Color {
        intensity > 0.7 ? .rDanger : intensity > 0.4 ? .rAmber : .rAccent
    }

    var body: some View {
        RRCard {
            HStack(alignment: .center, spacing: 12) {
                Text(symptom.icon).font(.system(size: 28))

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(symptom.name)
                            .font(.sansRR(15, weight: .semibold))
                            .foregroundColor(.rText)
                        Spacer()
                        Text(intensityLabel)
                            .font(.sansRR(10, weight: .bold))
                            .foregroundColor(intensityColor)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .background(intensityColor.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.rBg2).frame(height: 5)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(intensityColor)
                                .frame(width: geo.size.width * intensity, height: 5)
                        }
                    }
                    .frame(height: 5)

                    HStack(spacing: 16) {
                        Label(symptom.onset, systemImage: "clock")
                            .font(.sansRR(11))
                            .foregroundColor(.rText3)
                        Label(symptom.peak, systemImage: "arrow.up.circle")
                            .font(.sansRR(11))
                            .foregroundColor(.rText3)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.rText3)
            }
        }
    }
}

struct SymptomDetailView: View {
    let symptom: Symptom
    let intensity: Double
    @Environment(\.dismiss) var dismiss

    var intensityColor: Color {
        intensity > 0.7 ? .rDanger : intensity > 0.4 ? .rAmber : .rAccent
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header
                VStack(spacing: 8) {
                    Text(symptom.icon).font(.system(size: 52))
                    Text(symptom.name)
                        .font(.serif(28, weight: .bold))
                        .foregroundColor(.rText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)

                // Intensity bar
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("CURRENT INTENSITY")
                            .font(.sansRR(10, weight: .bold))
                            .foregroundColor(.rText3)
                            .tracking(0.8)
                        Spacer()
                        Text("\(Int(intensity * 100))%")
                            .font(.sansRR(12, weight: .bold))
                            .foregroundColor(intensityColor)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4).fill(Color.rBg2).frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(intensityColor)
                                .frame(width: geo.size.width * intensity, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(16)
                .background(Color.rBg2.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Why this happens
                VStack(alignment: .leading, spacing: 8) {
                    Text("WHY THIS HAPPENS")
                        .font(.sansRR(10, weight: .bold))
                        .foregroundColor(.rText3)
                        .tracking(1)
                    Text(symptom.why)
                        .font(.sansRR(13))
                        .foregroundColor(.rText)
                        .lineSpacing(4)
                }
                .padding(14)
                .background(Color.rBg2.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Timeline chips
                HStack(spacing: 8) {
                    ForEach([("Onset", symptom.onset), ("Peak", symptom.peak), ("Duration", symptom.duration)], id: \.0) { label, value in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(label.uppercased())
                                .font(.sansRR(9, weight: .bold))
                                .foregroundColor(.rText3)
                                .tracking(0.5)
                            Text(value)
                                .font(.sansRR(12, weight: .medium))
                                .foregroundColor(.rText)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.rBg2.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                // Coping strategies
                VStack(alignment: .leading, spacing: 10) {
                    Text("COPING STRATEGIES")
                        .font(.sansRR(10, weight: .bold))
                        .foregroundColor(.rAccent)
                        .tracking(1)

                    ForEach(symptom.tips.indices, id: \.self) { i in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(i + 1)")
                                .font(.sansRR(11, weight: .bold))
                                .foregroundColor(.rAccent)
                                .frame(width: 22, height: 22)
                                .background(Color.rAccent.opacity(0.1))
                                .clipShape(Circle())
                            Text(symptom.tips[i])
                                .font(.sansRR(13))
                                .foregroundColor(.rText)
                                .lineSpacing(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if i < symptom.tips.count - 1 {
                            Divider().background(Color.rBg2)
                        }
                    }
                }

                Text("Source: \(symptom.source)")
                    .font(.sansRR(10))
                    .foregroundColor(.rText3)
                    .italic()
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.rBg.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.rText3)
            }
            .padding(20)
        }
    }
}
