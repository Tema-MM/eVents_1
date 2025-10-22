//  HomeView.swift
//  DrFind

import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var mapVM = MapSearchViewModel()
    @ObservedObject private var location = LocationManager.shared
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showMapView = false
    @State private var showAppointments = false
    @State private var showProfile = false
    @State private var showProviderDetail = false
    @State private var selectedProvider: Place? = nil

    private let filters = ["All", "Doctor", "Hospital"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView

                // Search Bar
                searchBar

                // Action Buttons
                actionButtons

                // Filter Tabs
                filterTabs

                // Content Section
                contentSection
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showMapView) {
                MapSearchView()
                    .navigationTitle("Map View")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(isPresented: $showAppointments) {
                BookingsView()
                    .navigationTitle("My Appointments")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationDestination(isPresented: $showProviderDetail) {
                if let provider = selectedProvider {
                    ProviderDetailView(provider: provider)
                        .navigationTitle(provider.name)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationDestination(isPresented: $showProfile) {
                ProfileView()
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            location.requestWhenInUse()
        }
        .onReceive(location.$currentLocation) { loc in
            if let location = loc {
                Task {
                    await mapVM.searchNearby(from: location)
                }
            }
        }
        .overlay {
            if location.authorizationStatus == .notDetermined {
                // Initial loading state while requesting location permission
                VStack(spacing: 16) {
                    Image(systemName: "location")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    Text("Requesting Location Access")
                        .font(.headline)
                    Text("We need your location to find nearby healthcare providers")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Find Your Healthcare Provider")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            Spacer()

            Button(action: {
                showProfile = true
            }) {
                Image("fWhiteDr")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search doctors, hospitals...", text: $searchText)
                .autocorrectionDisabled()
                .onSubmit {
                    if !searchText.isEmpty {
                        Task {
                            if let location = location.currentLocation {
                                await mapVM.searchNearby(from: location)
                            }
                        }
                    }
                }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(25) // Increased corner radius for more curved appearance
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Map View Button
            Button(action: {
                showMapView = true
            }) {
                HStack {
//                    Image("map")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
                    Text("Map View")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.cyan)
                .cornerRadius(12)
            }

            // Appointments Button
            Button(action: {
                showAppointments = true
            }) {
                HStack {
//                    Image("booking-icon")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
                    Text("Appointment")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.pink, .orange]),
                                 startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }

    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
//                        applyFilter(filter)
                    }) {
                        Text(filter)
                            .font(.subheadline)
                            .fontWeight(selectedFilter == filter ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ?
                                Color.blue.opacity(0.1) :
                                Color(.secondarySystemBackground)
                            )
                            .foregroundColor(selectedFilter == filter ? .blue : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8) // Add vertical padding around filter tabs
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nearby Providers")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            if mapVM.places.isEmpty && location.currentLocation != nil {
                // Loading or no results state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("Searching for providers...")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Make sure location services are enabled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            } else if filteredProviders.isEmpty && !mapVM.places.isEmpty {
                // No results for current filter
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("No \(selectedFilter.lowercased())s found")
                        .font(.headline)
                    Text("Try adjusting your search or filter")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredProviders) { provider in
                            ProviderCard(provider: provider)
                                .onTapGesture {
                                    selectedProvider = provider
                                    showProviderDetail = true
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.white)
    }

    private var filteredProviders: [Place] {
        guard !mapVM.places.isEmpty else { return [] }

        switch selectedFilter {
        case "Doctor":
            return mapVM.places.filter { place in
                place.category?.contains("Doctor") == true ||
                place.name.lowercased().contains("doctor") ||
                place.name.lowercased().contains("clinic")
            }
        case "Hospital":
            return mapVM.places.filter { place in
                place.category?.contains("Hospital") == true ||
                place.name.lowercased().contains("hospital") ||
                place.name.lowercased().contains("medical center")
            }
        default:
            return mapVM.places
        }
    }
}

struct ProviderCard: View {
    let provider: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Use a placeholder image since Place doesn't have image data
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 150)
                .overlay(
                    Image(systemName: "building.2")
                        .foregroundColor(.gray)
                        .font(.largeTitle)
                )
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 8) {
                // Type badge
                HStack {
                    Text(getProviderType())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    Spacer()
                }

                // Rating (mock data for now)
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("4.5")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("(120)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Name
                Text(provider.name)
                    .font(.headline)
                    .lineLimit(2)

                // Category/Specialty
                HStack {
                    Image(systemName: "briefcase.medical")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(provider.category ?? "Healthcare")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Address
                HStack {
                    Image(systemName: "mappin.circle")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(provider.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func getProviderType() -> String {
        if provider.category?.contains("Hospital") == true ||
           provider.name.lowercased().contains("hospital") ||
           provider.name.lowercased().contains("medical center") {
            return "Hospital"
        } else if provider.category?.contains("Doctor") == true ||
                  provider.name.lowercased().contains("doctor") ||
                  provider.name.lowercased().contains("clinic") {
            return "Doctor"
        }
        return "Healthcare"
    }
}

#Preview {
    HomeView()
}
