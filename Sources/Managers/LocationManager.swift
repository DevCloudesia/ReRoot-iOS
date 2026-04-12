import Foundation
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var nearbyPlaces: [NearbyPlace] = []
    @Published var isSearching = false
    @Published var searchError: String?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        DispatchQueue.main.async {
            self.userLocation = loc.coordinate
        }
        searchNearby(location: loc)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.searchError = error.localizedDescription
        }
    }

    func searchNearby(location: CLLocation) {
        DispatchQueue.main.async { self.isSearching = true; self.nearbyPlaces = [] }

        let queries = [
            "addiction treatment center",
            "substance abuse treatment",
            "drug rehabilitation",
        ]

        let group = DispatchGroup()
        var results: [MKMapItem] = []

        for query in queries {
            group.enter()
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 20_000,
                longitudinalMeters: 20_000
            )
            MKLocalSearch(request: request).start { response, _ in
                if let items = response?.mapItems { results.append(contentsOf: items) }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            // Deduplicate by name, sort by distance
            let seen = NSMutableSet()
            let unique = results.filter { item in
                let key = item.name ?? item.placemark.title ?? UUID().uuidString
                if seen.contains(key) { return false }
                seen.add(key); return true
            }
            self.nearbyPlaces = Array(unique.prefix(10)).map { item in
                NearbyPlace(
                    name: item.name ?? "Treatment Center",
                    address: item.placemark.formattedAddress,
                    coordinate: item.placemark.coordinate,
                    phone: item.phoneNumber,
                    mapItem: item,
                    distance: location.distance(from: CLLocation(
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    ))
                )
            }.sorted { $0.distance < $1.distance }
            self.isSearching = false
        }
    }
}

struct NearbyPlace: Identifiable {
    let id = UUID()
    let name: String
    let address: String?
    let coordinate: CLLocationCoordinate2D
    let phone: String?
    let mapItem: MKMapItem
    let distance: CLLocationDistance

    var distanceText: String {
        let miles = distance * 0.000621371
        if miles < 0.1 { return "Nearby" }
        return String(format: "%.1f mi", miles)
    }
}

extension CLPlacemark {
    var formattedAddress: String? {
        [subThoroughfare, thoroughfare, locality, administrativeArea]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
            .nilIfEmpty
    }
}

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
