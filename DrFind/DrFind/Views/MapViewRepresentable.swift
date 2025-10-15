//  MapViewRepresentable.swift
//  DrFind

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var places: [Place]
    @Binding var selectedPlace: Place?
    @Binding var route: MKPolyline?

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        map.pointOfInterestFilter = .includingAll
        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)

        // Update annotations
        let existing = uiView.annotations.filter { !($0 is MKUserLocation) }
        uiView.removeAnnotations(existing)
        let annotations: [MKPointAnnotation] = places.map { place in
            let ann = MKPointAnnotation()
            ann.title = place.name
            ann.subtitle = place.subtitle
            ann.coordinate = place.coordinate
            return ann
        }
        uiView.addAnnotations(annotations)

        // Update route overlay
        uiView.overlays.forEach { uiView.removeOverlay($0) }
        if let route = route {
            uiView.addOverlay(route)
            uiView.setVisibleMapRect(route.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 180, right: 40), animated: true)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        init(_ parent: MapViewRepresentable) { self.parent = parent }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let coord = view.annotation?.coordinate else { return }
            if let place = parent.places.first(where: { $0.coordinate.latitude == coord.latitude && $0.coordinate.longitude == coord.longitude }) {
                parent.selectedPlace = place
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
