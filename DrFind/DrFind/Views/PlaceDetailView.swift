//  PlaceDetailView.swift
//  DrFind

import SwiftUI
import Combine
import MapKit
import CoreLocation

struct PlaceDetailView: View {
    let place: Place
    @ObservedObject var vm: MapSearchViewModel
    let userLocation: CLLocation?

    @State private var showBooking = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(place.name)
                    .font(.title2).bold()
                Text(place.subtitle)
                    .foregroundStyle(.secondary)

                if let phone = place.phoneNumber { Label(phone, systemImage: "phone") }
                if let cat = place.category { Label(cat.replacingOccurrences(of: "_", with: " "), systemImage: "cross.case") }

                Label("Mon–Fri 8:00–17:00", systemImage: "clock")

                HStack {
                    Button("Get Directions") {
                        Task { await vm.buildRoute(from: userLocation, to: place) }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Book Appointment") { showBooking = true }
                        .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBooking) {
            BookingView(place: place)
        }
    }
}

#Preview {
    PlaceDetailView(place: Place(id: "1", name: "Test Clinic", subtitle: "123 Main St", coordinate: CLLocationCoordinate2DMake(0, 0)), vm: MapSearchViewModel(), userLocation: nil)
}
