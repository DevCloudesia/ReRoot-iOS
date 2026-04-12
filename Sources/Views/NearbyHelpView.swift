import SwiftUI
import MapKit
import CoreLocation

// MARK: - Location Manager

@MainActor
final class NearbyHelpLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var places: [HelpPlace] = []
    @Published var isSearching = false
    @Published var closestPlace: HelpPlace?
    @Published var route: MKRoute?
    @Published var errorMessage: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startLocating() {
        manager.requestLocation()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.userLocation = loc.coordinate
            await self.searchNearby(around: loc.coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = "Could not determine your location."
            self.isSearching = false
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.startLocating()
            }
        }
    }

    private static let radiusMeters: Double = 40_234 // 25 miles

    private let searchQueries = [
        "addiction treatment center",
        "behavioral health counseling",
        "rehabilitation center",
    ]

    private var lastSearchTime: Date?

    func searchNearby(around coord: CLLocationCoordinate2D) async {
        if let last = lastSearchTime, Date().timeIntervalSince(last) < 90 {
            return
        }
        lastSearchTime = Date()

        isSearching = true
        errorMessage = nil
        var allPlaces: [HelpPlace] = []
        let userLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let region = MKCoordinateRegion(
            center: coord,
            latitudinalMeters: Self.radiusMeters * 2,
            longitudinalMeters: Self.radiusMeters * 2
        )

        for query in searchQueries {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region
            do {
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                for item in response.mapItems {
                    let placeLoc = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                    let place = HelpPlace(
                        name: item.name ?? "Support Center",
                        address: formatAddress(item.placemark),
                        coordinate: item.placemark.coordinate,
                        distance: userLoc.distance(from: placeLoc),
                        phone: item.phoneNumber,
                        category: query,
                        mapItem: item
                    )
                    if place.distance <= Self.radiusMeters,
                       !allPlaces.contains(where: { $0.name == place.name && abs($0.coordinate.latitude - place.coordinate.latitude) < 0.0001 }) {
                        allPlaces.append(place)
                    }
                }
            } catch {
                continue
            }
        }

        allPlaces.sort { $0.distance < $1.distance }
        places = allPlaces
        closestPlace = allPlaces.first
        isSearching = false

        if let closest = closestPlace {
            await calculateRoute(to: closest, from: coord)
        }

        if allPlaces.isEmpty {
            errorMessage = "No support centers found within 25 miles. Try again later or call 1-800-QUIT-NOW for immediate help."
        }
    }

    func calculateRoute(to place: HelpPlace, from origin: CLLocationCoordinate2D) async {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = place.mapItem
        request.transportType = .automobile

        do {
            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            route = response.routes.first
        } catch {
            route = nil
        }
    }

    private nonisolated func formatAddress(_ pm: MKPlacemark) -> String {
        var parts: [String] = []
        if let st = pm.thoroughfare { parts.append(st) }
        if let city = pm.locality { parts.append(city) }
        if let state = pm.administrativeArea { parts.append(state) }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Data Model

struct HelpPlace: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let distance: Double
    let phone: String?
    let category: String
    let mapItem: MKMapItem

    var distanceText: String {
        let miles = distance / 1609.34
        if miles < 0.1 { return "Nearby" }
        return String(format: "%.1f mi", miles)
    }
}

// MARK: - Nearby Help View

struct NearbyHelpView: View {
    @ObservedObject var locManager: NearbyHelpLocationManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlace: HelpPlace?
    @State private var showDirections = false
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.96, green: 0.95, blue: 0.93).ignoresSafeArea()

                Group {
                    switch locManager.authorizationStatus {
                    case .notDetermined:
                        permissionRequestView
                    case .denied, .restricted:
                        deniedView
                    default:
                        mainContent
                    }
                }
            }
            .navigationTitle("Help Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.sansRR(15, weight: .semibold))
                }
            }
        }
        .onAppear {
            if locManager.authorizationStatus == .authorizedWhenInUse || locManager.authorizationStatus == .authorizedAlways {
                locManager.startLocating()
            }
        }
    }

    // MARK: - Permission Request

    var permissionRequestView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "location.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                )

            VStack(spacing: 8) {
                Text("Find Support Near You")
                    .font(.serif(24, weight: .bold))
                    .foregroundColor(.rText)

                Text("We'll search for addiction counselors, treatment centers, and support groups in your area.")
                    .font(.sansRR(14))
                    .foregroundColor(.rText2)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 32)

            Button {
                locManager.requestPermission()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                    Text("Allow Location Access")
                }
                .font(.sansRR(16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.rAccent)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 40)

            Text("Your location is only used to find nearby help. It is never stored or shared.")
                .font(.sansRR(11))
                .foregroundColor(.rText3)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    var deniedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "location.slash.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.rText3)

            Text("Location Access Needed")
                .font(.serif(22, weight: .bold))
                .foregroundColor(.rText)

            Text("Please enable location access in Settings to find support centers near you.")
                .font(.sansRR(14))
                .foregroundColor(.rText2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.sansRR(15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 14)
                    .background(Color.rAccent).clipShape(Capsule())
            }
            Spacer()
        }
    }

    // MARK: - Main Content

    var mainContent: some View {
        VStack(spacing: 0) {
            mapSection
                .frame(height: 320)

            if locManager.isSearching {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.rAccent)
                    Text("Searching for support near you...")
                        .font(.sansRR(13))
                        .foregroundColor(.rText2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = locManager.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.rText3)
                    Text(error)
                        .font(.sansRR(13))
                        .foregroundColor(.rText2)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                placesList
            }
        }
    }

    // MARK: - Map

    var mapSection: some View {
        Map(position: $cameraPosition) {
            if let userLoc = locManager.userLocation {
                Annotation("You", coordinate: userLoc) {
                    ZStack {
                        Circle().fill(.blue).frame(width: 16, height: 16)
                        Circle().stroke(.white, lineWidth: 3).frame(width: 16, height: 16)
                        Circle().fill(.blue.opacity(0.2)).frame(width: 40, height: 40)
                    }
                }
            }

            ForEach(locManager.places) { place in
                Annotation(place.name, coordinate: place.coordinate) {
                    Button {
                        withAnimation { selectedPlace = place }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: place.id == locManager.closestPlace?.id ? "star.circle.fill" : "mappin.circle.fill")
                                .font(.system(size: place.id == locManager.closestPlace?.id ? 32 : 26))
                                .foregroundColor(place.id == locManager.closestPlace?.id ? .orange : .red)
                        }
                    }
                }
            }

            if let route = locManager.route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 4)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .overlay(alignment: .topLeading) {
            if let closest = locManager.closestPlace, locManager.route != nil {
                closestBanner(closest)
                    .padding(.top, 16)
                    .padding(.leading, 24)
            }
        }
    }

    func closestBanner(_ place: HelpPlace) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.orange)
                Text("CLOSEST").font(.sansRR(9, weight: .bold)).foregroundColor(.orange)
            }
            Text(place.name)
                .font(.sansRR(12, weight: .bold))
                .foregroundColor(.rText)
                .lineLimit(1)
            if let route = locManager.route {
                Text("\(place.distanceText) · \(Int(route.expectedTravelTime / 60)) min drive")
                    .font(.sansRR(10))
                    .foregroundColor(.rText2)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Places List

    var placesList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(locManager.places) { place in
                    placeCard(place)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    func placeCard(_ place: HelpPlace) -> some View {
        let isClosest = place.id == locManager.closestPlace?.id

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    if isClosest {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.orange)
                            Text("CLOSEST TO YOU").font(.sansRR(9, weight: .bold)).foregroundColor(.orange)
                        }
                    }
                    Text(place.name)
                        .font(.sansRR(15, weight: .bold))
                        .foregroundColor(.rText)
                    Text(place.address)
                        .font(.sansRR(12))
                        .foregroundColor(.rText2)
                }
                Spacer()
                Text(place.distanceText)
                    .font(.sansRR(13, weight: .semibold))
                    .foregroundColor(.rAccent)
            }

            HStack(spacing: 10) {
                Button {
                    openDirections(to: place)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 12))
                        Text("Directions")
                            .font(.sansRR(12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.blue).clipShape(Capsule())
                }

                if let phone = place.phone, !phone.isEmpty {
                    Button {
                        let cleaned = phone.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
                        if let url = URL(string: "tel://\(cleaned)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 12))
                            Text("Call")
                                .font(.sansRR(12, weight: .semibold))
                        }
                        .foregroundColor(.rAccent)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color.rAccent.opacity(0.12)).clipShape(Capsule())
                    }
                }

                Spacer()

                Image(systemName: categoryIcon(place.category))
                    .font(.system(size: 16))
                    .foregroundColor(.rText3)
            }
        }
        .padding(14)
        .background(isClosest ? Color.orange.opacity(0.06) : Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isClosest ? Color.orange.opacity(0.3) : Color.rBg2.opacity(0.8), lineWidth: isClosest ? 1.5 : 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    func openDirections(to place: HelpPlace) {
        place.mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    func categoryIcon(_ cat: String) -> String {
        if cat.contains("addiction") || cat.contains("substance") { return "building.2.fill" }
        if cat.contains("behavioral") || cat.contains("mental") { return "brain.head.profile" }
        if cat.contains("therapy") || cat.contains("counseling") { return "person.2.fill" }
        if cat.contains("rehabilitation") { return "cross.case.fill" }
        if cat.contains("community") { return "heart.circle.fill" }
        return "cross.case.fill"
    }
}

// Equatable conformance for map annotation comparison
extension HelpPlace: Equatable {
    static func == (lhs: HelpPlace, rhs: HelpPlace) -> Bool {
        lhs.id == rhs.id
    }
}
