//  BookingsView.swift
//  DrFind

import SwiftUI

struct BookingsView: View {
    @ObservedObject private var store = BookingsStore.shared
    @State private var showProfile = false

    var body: some View {
        Group {
            if store.items.isEmpty {
                emptyState
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
                .background(Color(.systemGroupedBackground))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showProfile = true
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Profile")
            }
        }
        .sheet(isPresented: $showProfile) {
            NavigationStack { ProfileView() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("No bookings yet")
                .font(.headline)
            Text("Your appointments will appear here after you book one.")
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
                Image(systemName: "cross.case")
                    .foregroundStyle(.background)
                Text(booking.placeName).font(.headline)
            }
            HStack(spacing: 8) {
                Label(booking.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                Spacer()
            }
            if !booking.userName.isEmpty {
                Label(booking.userName, systemImage: "person")
            }
            if !booking.userContact.isEmpty {
                Label(booking.userContact, systemImage: "phone")
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
