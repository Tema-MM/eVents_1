//  MapSearchView.swift
//  DrFind

import SwiftUI
import Combine
import UIKit
import MapKit

struct MapSearchView: View {
    @StateObject private var vm = MapSearchViewModel()
    @ObservedObject private var location = LocationManager.shared

    @State private var showDetails = false
    @FocusState private var searchFocused: Bool

    private let specialties = ["All", "General Practitioner", "Dentist", "Pediatrician", "Cardiologist", "Hospital"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                // Results list under filters when a specialty is selected
                if vm.specialty != "All" && !vm.places.isEmpty {
                    resultsList
                }

                MapViewRepresentable(
                    region: $vm.region,
                    places: $vm.places,
                    selectedPlace: $vm.selectedPlace,
                    route: $vm.route
                )
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: vm.selectedPlace) { new in
                    if new != nil { showDetails = true }
                }
                .overlay(alignment: .topTrailing) {
                    if vm.route != nil {
                        Button {
                            vm.clearRoute()
                        } label: {
                            Label("Clear Route", systemImage: "xmark.circle.fill")
                                .labelStyle(.iconOnly)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .padding()
                    }
                }
            }
            .overlay(
                Group {
                    if location.authorizationStatus != .authorizedWhenInUse && location.authorizationStatus != .authorizedAlways {
                        permissionBanner
                            .transition(.move(edge: .top))
                            .zIndex(1)
                    }
                }, alignment: .top
            )
            .navigationDestination(isPresented: $showDetails) {
                if let place = vm.selectedPlace {
                    PlaceDetailView(place: place, vm: vm, userLocation: location.currentLocation)
                }
            }
            .onAppear {
                location.requestWhenInUse()
            }
            .onReceive(location.$currentLocation) { loc in
                vm.updateRegionForUserLocation(loc)
                if vm.places.isEmpty, let _ = loc,
                   location.authorizationStatus == .authorizedWhenInUse || location.authorizationStatus == .authorizedAlways {
                    Task { await vm.searchNearby(from: loc) }
                }
            }
            // Tap anywhere to dismiss keyboard and lists
            .simultaneousGesture(TapGesture().onEnded {
                searchFocused = false
            })
        }
    }

    private var searchBar: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Search Doctors or Hospitals", text: $vm.query)
                    .focused($searchFocused)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(alignment: .trailing) {
                        if !vm.query.isEmpty {
                            Button {
                                vm.query = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                Button("Search") {
                    Task { await vm.searchNearby(from: location.currentLocation) }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(specialties, id: \.self) { spec in
                        Button(action: {
                            vm.specialty = spec
                        }) {
                            Text(spec)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(vm.specialty == spec ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }.padding(.horizontal)
            }

            // Recent searches list appears when search field is focused
            if searchFocused && !vm.recentSearches.isEmpty {
                recentList
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(.thinMaterial)
    }

    private var recentList: some View {
        List {
            ForEach(vm.recentSearches, id: \.self) { term in
                HStack {
                    Image(systemName: "clock")
                    Text(term)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    vm.query = term
                    searchFocused = false
                    Task { await vm.searchNearby(from: location.currentLocation) }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let term = vm.recentSearches[index]
                    vm.removeRecentSearch(term)
                }
            }
        }
        .listStyle(.plain)
        .frame(maxHeight: 200)
    }

    private var resultsList: some View {
        let filtered = vm.places.filter { place in
            guard vm.specialty != "All" else { return true }
            let spec = vm.specialty.lowercased()
            return (place.category?.lowercased().contains(spec) ?? false)
                || place.name.lowercased().contains(spec)
                || place.subtitle.lowercased().contains(spec)
        }
        return List(filtered) { place in
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name).font(.subheadline).bold()
                Text(place.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                searchFocused = false
                vm.setRegion(to: place.coordinate)
                Task { await vm.searchNearby(at: place.coordinate) }
            }
        }
        .listStyle(.plain)
        .frame(maxHeight: 240)
    }

    private var permissionBanner: some View {
        VStack(spacing: 8) {
            Text("Location Access Needed")
                .font(.headline)
            Text("Enable location to center the map and search nearby doctors and hospitals.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            HStack {
                Button("Enable Location") { location.requestWhenInUse() }
                    .buttonStyle(.borderedProminent)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 0).stroke(Color.secondary.opacity(0.2))
        )
    }
}

#Preview {
    MapSearchView()
}
