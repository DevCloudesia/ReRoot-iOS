import HealthKit
import Combine

// MARK: - HRV Sample

struct HRVSample: Identifiable {
    let id = UUID()
    let value: Double   // milliseconds (SDNN)
    let date: Date
}

struct SleepSession: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let stage: String
    var hours: Double { end.timeIntervalSince(start) / 3600 }
}

// MARK: - HealthKit Manager

@MainActor
class HealthKitManager: ObservableObject {

    private let store = HKHealthStore()

    @Published var isAvailable: Bool = HKHealthStore.isHealthDataAvailable()
    @Published var authorized: Bool = false

    // HRV
    @Published var recentHRV: [HRVSample] = []
    @Published var latestHRV: Double?
    @Published var avgHRV7d: Double?
    @Published var hrvTrend: HRVTrend = .stable

    // Sleep
    @Published var sleepHoursLast: Double?    // last night
    @Published var avgSleep7d: Double?

    // Activity
    @Published var stepsToday: Int = 0
    @Published var activeMinutesToday: Int = 0
    @Published var restingHR: Double?

    enum HRVTrend { case rising, stable, dropping }

    // Stress signal: HRV drop > 15% from rolling avg
    var stressSignalDetected: Bool {
        guard let latest = latestHRV, let avg = avgHRV7d, avg > 0 else { return false }
        return (avg - latest) / avg > 0.15
    }

    // Derived: risk contribution from biometrics
    var biometricRiskFactor: Double {
        var risk = 0.0
        if stressSignalDetected { risk += 0.25 }
        if let sleep = sleepHoursLast, sleep < 6 { risk += 0.20 }
        if let sleep = sleepHoursLast, sleep < 5 { risk += 0.10 }
        if activeMinutesToday < 10 { risk += 0.10 }
        return min(risk, 0.55)
    }

    // MARK: - Auth

    func requestAuthorization() async {
        guard isAvailable else {
            authorized = false
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.heartRate),
            HKQuantityType(.restingHeartRate),
            HKCategoryType(.sleepAnalysis),
            HKQuantityType(.stepCount),
            HKQuantityType(.appleExerciseTime),
        ]

        let writeTypes: Set<HKSampleType> = [
            HKWorkoutType.workoutType(),
            HKQuantityType(.activeEnergyBurned),
        ]

        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            authorized = true
            UserDefaults.standard.set(true, forKey: "hk_authorized")
            await fetchAll()
        } catch {
            authorized = false
        }
    }

    func checkExistingAuth() {
        if isAvailable && UserDefaults.standard.bool(forKey: "hk_authorized") {
            authorized = true
            Task { await fetchAll() }
        }
    }

    func fetchAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchHRV() }
            group.addTask { await self.fetchSleep() }
            group.addTask { await self.fetchSteps() }
            group.addTask { await self.fetchExercise() }
            group.addTask { await self.fetchRestingHR() }
        }
    }

    // MARK: - HRV

    func fetchHRV() async {
        let type = HKQuantityType(.heartRateVariabilitySDNN)
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let pred = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: now)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: pred, limit: 48, sortDescriptors: [sort]) { _, samples, _ in
                guard let samples = samples as? [HKQuantitySample] else {
                    continuation.resume(); return
                }
                let parsed = samples.map { s in
                    HRVSample(value: s.quantity.doubleValue(for: .init(from: "ms")), date: s.endDate)
                }
                Task { @MainActor in
                    self.recentHRV = parsed
                    self.latestHRV = parsed.first?.value
                    if parsed.count > 1 {
                        self.avgHRV7d = parsed.map(\.value).reduce(0, +) / Double(parsed.count)
                        // Trend: compare first half vs second half
                        let half = parsed.count / 2
                        let recent = parsed.prefix(half).map(\.value).reduce(0, +) / Double(half)
                        let older  = parsed.suffix(half).map(\.value).reduce(0, +) / Double(half)
                        if recent > older * 1.05 { self.hrvTrend = .rising }
                        else if recent < older * 0.95 { self.hrvTrend = .dropping }
                        else { self.hrvTrend = .stable }
                    }
                }
                continuation.resume()
            }
            store.execute(query)
        }
    }

    // MARK: - Sleep

    func fetchSleep() async {
        let type = HKCategoryType(.sleepAnalysis)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let pred = HKQuery.predicateForSamples(withStart: yesterday, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: pred, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(); return
                }
                let asleepStages: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue,
                ]
                let totalHours = samples
                    .filter { asleepStages.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) / 3600 }
                Task { @MainActor in
                    self.sleepHoursLast = totalHours > 0 ? totalHours : nil
                }
                continuation.resume()
            }
            store.execute(query)
        }
    }

    // MARK: - Steps

    func fetchSteps() async {
        let type = HKQuantityType(.stepCount)
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
                let steps = Int(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                Task { @MainActor in self.stepsToday = steps }
                continuation.resume()
            }
            store.execute(query)
        }
    }

    // MARK: - Exercise

    func fetchExercise() async {
        let type = HKQuantityType(.appleExerciseTime)
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
                let mins = Int(stats?.sumQuantity()?.doubleValue(for: .minute()) ?? 0)
                Task { @MainActor in self.activeMinutesToday = mins }
                continuation.resume()
            }
            store.execute(query)
        }
    }

    // MARK: - Save Workout

    func saveWorkout(type: HKWorkoutActivityType, minutes: Int) async -> Bool {
        guard authorized else { return false }
        let start = Date().addingTimeInterval(-Double(minutes) * 60)
        let end = Date()
        let config = HKWorkoutConfiguration()
        config.activityType = type
        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        do {
            try await builder.beginCollection(at: start)
            let energy = HKQuantity(unit: .kilocalorie(), doubleValue: Double(minutes) * 5.0)
            let energySample = HKQuantitySample(
                type: HKQuantityType(.activeEnergyBurned),
                quantity: energy,
                start: start,
                end: end
            )
            try await builder.addSamples([energySample])
            try await builder.endCollection(at: end)
            try await builder.finishWorkout()
            await fetchExercise()
            return true
        } catch {
            return false
        }
    }

    static func workoutType(for activityName: String) -> HKWorkoutActivityType {
        let name = activityName.lowercased()
        if name.contains("run") || name.contains("sprint") || name.contains("jog") || name.contains("tempo") { return .running }
        if name.contains("walk") || name.contains("hike") || name.contains("hiking") { return .walking }
        if name.contains("cycl") || name.contains("bike") { return .cycling }
        if name.contains("swim") { return .swimming }
        if name.contains("yoga") { return .yoga }
        if name.contains("box") { return .boxing }
        if name.contains("dance") { return .socialDance }
        if name.contains("strength") || name.contains("dumbbell") || name.contains("weight") { return .traditionalStrengthTraining }
        if name.contains("hiit") || name.contains("burpee") || name.contains("interval") { return .highIntensityIntervalTraining }
        if name.contains("breath") || name.contains("meditation") || name.contains("mindful") { return .mindAndBody }
        return .other
    }

    // MARK: - Resting HR

    func fetchRestingHR() async {
        let type = HKQuantityType(.restingHeartRate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let hr = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: .init(from: "count/min"))
                Task { @MainActor in self.restingHR = hr }
                continuation.resume()
            }
            store.execute(query)
        }
    }
}
