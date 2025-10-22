//  DrFind

import SwiftUI
import CoreLocation

struct ProviderDetailView: View {
    let provider: Place
    @ObservedObject private var profile = ProfileStore.shared
    @State private var showBookingSheet = false
    @State private var appointmentDate = Date()
    @State private var appointmentNote = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "building.2")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    )

                VStack(alignment: .leading, spacing: 16) {
                    // Header info
                    VStack(alignment: .leading, spacing: 8) {
                        // Type badge and rating
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
                        }

                        // Name and category
                        Text(provider.name)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack {
                            Image(systemName: "briefcase.medical")
                                .foregroundColor(.secondary)
                            Text(provider.category ?? "Healthcare")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    // Info sections
                    VStack(spacing: 12) {
                        InfoCard(title: "Address",
                                content: provider.subtitle,
                                icon: "mappin.circle")

                        InfoCard(title: "Phone",
                                content: provider.phoneNumber ?? "Not available",
                                icon: "phone.circle")

                        InfoCard(title: "Hours",
                                content: "Mon-Fri: 9AM-5PM", // Default hours
                                icon: "clock.circle")
                    }
                    .padding(.horizontal)

                    // About section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .padding(.horizontal)

                        Text("Healthcare provider offering quality medical services in your area.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .lineLimit(nil)
                    }

                    // Book Appointment button
                    Button(action: {
                        showBookingSheet = true
                    }) {
                        Text("Book Appointment")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.cyan)
                            .cornerRadius(12)
                            .padding()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showBookingSheet) {
            BookingSheet(provider: provider, appointmentDate: $appointmentDate, appointmentNote: $appointmentNote)
        }
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

struct BookingSheet: View {
    let provider: Place
    @Binding var appointmentDate: Date
    @Binding var appointmentNote: String
    @ObservedObject private var profile = ProfileStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Book Appointment")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Provider: \(provider.name)")
                        .font(.headline)

                    Text("Location: \(provider.subtitle)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

                DatePicker("Select Date & Time",
                          selection: $appointmentDate,
                          in: Date()...,
                          displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .padding()

                TextField("Notes (optional)", text: $appointmentNote)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)

                Spacer()

                Button(action: {
                    bookAppointment()
                }) {
                    Text("Confirm Booking")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.cyan)
                        .cornerRadius(12)
                        .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func bookAppointment() {
        let booking = Booking(
            id: UUID().uuidString,
            placeId: provider.id,
            placeName: provider.name,
            date: appointmentDate,
            userName: profile.fullName,
            userContact: profile.contact,
            note: appointmentNote.isEmpty ? nil : appointmentNote
        )

        BookingsStore.shared.add(booking)
        dismiss()
    }
}

struct InfoCard: View {
    let title: String
    let content: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        ProviderDetailView(provider: Place(
            name: "Sample Hospital",
            subtitle: "123 Main St, City",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            category: "Hospital"
        ))
    }
}
