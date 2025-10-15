//  RootTabView.swift
//  DrFind

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MapSearchView()
                    .navigationTitle("Discover")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Discover", systemImage: "map")
            }

            NavigationStack {
                BookingsView()
                    .navigationTitle("Bookings")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("Bookings", systemImage: "calendar")
            }
        }
    }
}

#Preview {
    RootTabView()
}
