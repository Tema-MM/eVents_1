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
    @State private var scrollOffset: CGFloat = 0
    @FocusState private var searchFocused: Bool

    private let specialties = ["All", "General Practitioner", "Dentist", "Pediatrician", "Cardiologist", "Hospital"]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background images based on state
                backgroundImage
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        searchBar
                            .background(.thinMaterial)

                        // Results list under filters when a specialty is selected
                        if vm.specialty != "All" && !vm.places.isEmpty {
                            resultsList
                        }

                        // Spacer to allow scrolling for background image changes
                        Spacer(minLength: 100)
                    }
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: ScrollOffsetKey.self, value: proxy.frame(in: .named("scroll")).origin.y)
                    })
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    scrollOffset = value
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
                    ProviderDetailView(provider: place)
                        .navigationTitle(place.name)
                        .navigationBarTitleDisplayMode(.inline)
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

    private var backgroundImage: some View {
        ZStack {
            // Default background (1st image)
            Image("image-2")
                .resizable()
                .scaledToFill()
                .opacity(vm.specialty == "All" ? (scrollOffset < -50 ? 0.3 : 1.0) : 0.3)

            // Scrolling background (2nd image) - shows when scrolled down
            if scrollOffset < -50 {
                Image("map")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.7)
            }

            // Doctor filter background (3rd image)
            if vm.specialty == "General Practitioner" || vm.specialty == "Dentist" || vm.specialty == "Pediatrician" || vm.specialty == "Cardiologist" {
                Image("wblackDr")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.8)
            }

            // Hospital filter background (4th image)
            if vm.specialty == "Hospital" {
                Image("booking-icon")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.8)
            }
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

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    MapSearchView()
}
