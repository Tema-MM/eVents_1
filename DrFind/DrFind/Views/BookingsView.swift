//  BookingsView.swift
//  DrFind

import SwiftUI

struct BookingsView: View {
    @ObservedObject private var store = BookingsStore.shared
    @State private var selectedTab = "Upcoming"
    private let tabs = ["Upcoming", "Past"]

    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == tab ?
                                Color.blue.opacity(0.1) :
                                Color.clear
                            )
                            .foregroundColor(selectedTab == tab ? .blue : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.vertical, 8)

            // Content based on selected tab
            if selectedTab == "Upcoming" {
                upcomingAppointmentsView
            } else {
                pastAppointmentsView
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var upcomingAppointmentsView: some View {
        Group {
            if store.items.isEmpty {
                emptyStateView(message: "No upcoming appointments", subtext: "Your appointments will appear here")
            } else {
                List {
                    ForEach(store.items) { booking in
                        BookingCard(booking: booking)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.secondary.opacity(0.1))
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: store.remove)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }

    private var pastAppointmentsView: some View {
        // For demo, showing empty state - in real app would filter past appointments
        emptyStateView(message: "No past appointments", subtext: "Your appointment history will appear here")
    }

    private func emptyStateView(message: String, subtext: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text(message)
                .font(.headline)
            Text(subtext)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct BookingCard: View {
    let booking: Booking

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("dochealthcare")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.blue)
                Text(booking.placeName).font(.headline)
            }
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Text(booking.date.formatted(date: .abbreviated, time: .shortened))
                Spacer()
            }
            if !booking.userName.isEmpty {
                HStack {
                    Image(systemName: "person")
                        .foregroundStyle(.secondary)
                    Text(booking.userName)
                }
            }
            if !booking.userContact.isEmpty {
                HStack {
                    Image(systemName: "phone")
                        .foregroundStyle(.secondary)
                    Text(booking.userContact)
                }
            }
            if let note = booking.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack { BookingsView() }
}
