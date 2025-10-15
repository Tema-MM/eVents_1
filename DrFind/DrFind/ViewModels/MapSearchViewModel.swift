//  MapSearchViewModel.swift
//  DrFind

import Foundation
import MapKit
import CoreLocation
import Combine

@MainActor
final class MapSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var specialty: String = "All"
    @Published var places: [Place] = []
    @Published var selectedPlace: Place?

    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2DMake(0, 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @Published var route: MKPolyline?

    private let recentKey = "drfind.recentSearches"

    var recentSearches: [String] {
        get { UserDefaults.standard.stringArray(forKey: recentKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: recentKey) }
    }

    func updateRegionForUserLocation(_ location: CLLocation?) {
        guard let loc = location else { return }
        region = MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }

    func searchNearby(from location: CLLocation?) async {
        guard let location = location else { return }

        let textBase = query.isEmpty ? "Doctors" : query
        let composed = specialty == "All" ? textBase : "\(textBase) \(specialty)"

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = composed
        request.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))

        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            let items = response.mapItems
            self.places = items.map { Place(mapItem: $0) }
            saveRecentSearch(composed)
        } catch {
            print("Search error: \(error)")
            self.places = []
        }
    }

    private func saveRecentSearch(_ term: String) {
        var arr = recentSearches
        if let idx = arr.firstIndex(of: term) { arr.remove(at: idx) }
        arr.insert(term, at: 0)
        recentSearches = Array(arr.prefix(10))
    }

    func removeRecentSearch(_ term: String) {
        var arr = recentSearches
        arr.removeAll { $0 == term }
        recentSearches = arr
    }

    func setRegion(to coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)) {
        region = MKCoordinateRegion(center: coordinate, span: span)
    }

    func searchNearby(at coordinate: CLLocationCoordinate2D) async {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        await searchNearby(from: location)
    }

    func clearRoute() { route = nil }

    func buildRoute(from userLocation: CLLocation?, to place: Place?) async {
        guard let userLocation = userLocation, let place = place else { return }
        // iOS 16-compatible routing using MKPlacemark + MKMapItem(placemark:)
        let srcPlacemark = MKPlacemark(coordinate: userLocation.coordinate)
        let dstPlacemark = MKPlacemark(coordinate: place.coordinate)
        let src = MKMapItem(placemark: srcPlacemark)
        let dst = MKMapItem(placemark: dstPlacemark)
        let request = MKDirections.Request()
        request.source = src
        request.destination = dst
        request.transportType = .automobile
        do {
            let dir = MKDirections(request: request)
            let resp = try await dir.calculate()
            if let route = resp.routes.first {
                self.route = route.polyline
            }
        } catch {
            print("Route error: \(error)")
        }
    }
}
