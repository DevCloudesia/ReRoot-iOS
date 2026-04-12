import SwiftUI
import MapKit

struct ResourcesView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.33, longitude: -122.03),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    // Emergency banner
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.rDanger)
                            .font(.system(size: 20))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Severe alcohol/benzo withdrawal is life-threatening.")
                                .font(.sansRR(13, weight: .semibold))
                                .foregroundColor(.rDanger)
                            Text("If you have seizures, confusion, or fever — call 911 immediately.")
                                .font(.sansRR(11))
                                .foregroundColor(.rText2)
                        }
                    }
                    .padding(14)
                    .background(Color.rDanger.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.rDanger.opacity(0.2), lineWidth: 1))

                    // Helpline cards
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HELPLINES — ONE TAP TO CALL")
                            .font(.sansRR(10, weight: .bold))
                            .foregroundColor(.rText3)
                            .tracking(1.2)

                        ForEach(RecoveryData.helpResources) { resource in
                            HelplineCard(resource: resource)
                        }
                    }

                    // Nearby Centers
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("NEARBY TREATMENT CENTERS")
                                .font(.sansRR(10, weight: .bold))
                                .foregroundColor(.rText3)
                                .tracking(1.2)
                            Spacer()
                            if locationManager.isSearching {
                                SwiftUI.ProgressView().scaleEffect(0.8)
                            }
                        }

                        switch locationManager.authStatus {
                        case .notDetermined:
                            LocationPermissionCard()
                        case .denied, .restricted:
                            RRCard {
                                HStack(spacing: 12) {
                                    Image(systemName: "location.slash.fill")
                                        .foregroundColor(.rText3).font(.system(size: 24))
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Location access denied")
                                            .font(.sansRR(14, weight: .semibold))
                                            .foregroundColor(.rText)
                                        Text("Enable in Settings → Privacy → Location to find nearby centers.")
                                            .font(.sansRR(12))
                                            .foregroundColor(.rText3)
                                    }
                                    Spacer()
                                    Button {
                                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                    } label: {
                                        Text("Settings")
                                            .font(.sansRR(12, weight: .semibold))
                                            .foregroundColor(.rAccent)
                                    }
                                }
                            }
                        case .authorizedWhenInUse, .authorizedAlways:
                            if let coord = locationManager.userLocation {
                                // Map
                                Map(initialPosition: .region(MKCoordinateRegion(
                                    center: coord,
                                    span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
                                ))) {
                                    ForEach(locationManager.nearbyPlaces) { place in
                                        Annotation("", coordinate: place.coordinate) {
                                            VStack(spacing: 2) {
                                                ZStack {
                                                    Circle().fill(Color.rAccent).frame(width: 28, height: 28)
                                                    Image(systemName: "cross.fill")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                                Triangle().fill(Color.rAccent).frame(width: 8, height: 6)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.rBg2, lineWidth: 1))

                                if locationManager.nearbyPlaces.isEmpty && !locationManager.isSearching {
                                    RRCard {
                                        HStack {
                                            Image(systemName: "magnifyingglass").foregroundColor(.rText3)
                                            Text("No treatment centers found nearby. Try searching FindTreatment.gov or calling SAMHSA at 1-800-662-4357.")
                                                .font(.sansRR(13))
                                                .foregroundColor(.rText2)
                                        }
                                    }
                                } else {
                                    ForEach(locationManager.nearbyPlaces) { place in
                                        NearbyPlaceCard(place: place)
                                    }
                                }
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }

                    // Online resources
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ONLINE RESOURCES")
                            .font(.sansRR(10, weight: .bold))
                            .foregroundColor(.rText3)
                            .tracking(1.2)

                        ForEach(onlineResources, id: \.0) { item in
                            Link(destination: URL(string: item.1)!) {
                                RRCard {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(item.0)
                                                .font(.sansRR(14, weight: .semibold))
                                                .foregroundColor(.rText)
                                            Text(item.2)
                                                .font(.sansRR(12))
                                                .foregroundColor(.rText3)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.right.square")
                                            .foregroundColor(.rAccent)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color.rBg.ignoresSafeArea())
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private let onlineResources: [(String, String, String)] = [
        ("FindTreatment.gov",           "https://findtreatment.gov",                            "SAMHSA treatment locator"),
        ("Smokefree.gov",               "https://smokefree.gov",                                "Free quit plans, apps & coaching"),
        ("CDC Quit Smoking",            "https://www.cdc.gov/tobacco/campaign/tips/quit-smoking/tips-for-quitting/index.html", "Evidence-based quitting tips"),
        ("NIDA: Why Drugs Are Hard to Quit", "https://nida.nih.gov/videos/why-are-drugs-so-hard-to-quit", "The science of addiction (video)"),
        ("Harvard: 5 Steps to Quit",    "https://www.health.harvard.edu/diseases-and-conditions/five-action-steps-for-quitting-an-addiction", "Harvard Medical School guide"),
        ("Mayo Clinic: Treatment",      "https://www.mayoclinic.org/diseases-conditions/drug-addiction/diagnosis-treatment/drc-20365113", "Professional treatment options"),
    ]
}

// MARK: - Helpline Card

struct HelplineCard: View {
    let resource: HelpResource

    var body: some View {
        RRCard(padding: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(resource.color.opacity(0.12)).frame(width: 46, height: 46)
                    Image(systemName: resource.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(resource.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(resource.name)
                        .font(.sansRR(14, weight: .bold))
                        .foregroundColor(.rText)
                    Text(resource.number)
                        .font(.serif(16, weight: .semibold))
                        .foregroundColor(resource.color)
                    Text(resource.desc)
                        .font(.sansRR(11))
                        .foregroundColor(.rText3)
                        .lineSpacing(2)
                    Text(resource.available)
                        .font(.sansRR(10, weight: .bold))
                        .foregroundColor(resource.color.opacity(0.7))
                        .tracking(0.3)
                }

                Spacer()

                // Dial button
                if let url = URL(string: resource.dialString) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        ZStack {
                            Circle().fill(resource.color).frame(width: 44, height: 44)
                            Image(systemName: resource.dialString.hasPrefix("sms") ? "message.fill" : "phone.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: resource.color.opacity(0.4), radius: 6, y: 2)
                    }
                }
            }
        }
    }
}

// MARK: - Nearby Place Card

struct NearbyPlaceCard: View {
    let place: NearbyPlace

    var body: some View {
        RRCard {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.rAccent.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: "cross.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.rAccent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(place.name)
                        .font(.sansRR(14, weight: .semibold))
                        .foregroundColor(.rText)
                        .lineLimit(1)
                    if let addr = place.address {
                        Text(addr)
                            .font(.sansRR(11))
                            .foregroundColor(.rText3)
                            .lineLimit(1)
                    }
                    Text(place.distanceText)
                        .font(.sansRR(11, weight: .bold))
                        .foregroundColor(.rAccent)
                }

                Spacer()

                HStack(spacing: 8) {
                    // Call button
                    if let phone = place.phone, let url = URL(string: "tel://\(phone.filter { $0.isNumber })") {
                        Button {
                            UIApplication.shared.open(url)
                        } label: {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.rAccent)
                                .clipShape(Circle())
                        }
                    }

                    // Maps button
                    Button {
                        place.mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                    } label: {
                        Image(systemName: "map.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.rAmber)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// MARK: - Location Permission Card

struct LocationPermissionCard: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        RRCard {
            VStack(spacing: 14) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.rAccent)

                VStack(spacing: 6) {
                    Text("Find Nearby Treatment Centers")
                        .font(.sansRR(16, weight: .bold))
                        .foregroundColor(.rText)
                        .multilineTextAlignment(.center)
                    Text("ReRoot can find addiction treatment centers, counselors, and support groups near you — all on a live map with one-tap directions and calling.")
                        .font(.sansRR(13))
                        .foregroundColor(.rText2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                Button {
                    locationManager.requestPermission()
                } label: {
                    Label("Enable Location Access", systemImage: "location.fill")
                        .font(.sansRR(15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.rAccent)
                        .clipShape(Capsule())
                        .shadow(color: Color.rAccent.opacity(0.3), radius: 8, y: 3)
                }

                Text("Your location is only used to search nearby. It is never stored or shared.")
                    .font(.sansRR(10))
                    .foregroundColor(.rText3)
                    .multilineTextAlignment(.center)
                    .italic()
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Triangle shape for map pin

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
