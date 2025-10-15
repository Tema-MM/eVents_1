//  BookingView.swift
//  DrFind

import SwiftUI
import Combine
import CoreLocation

struct BookingView: View {
    let place: Place
    @StateObject private var vm = BookingViewModel()
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profile = ProfileStore.shared

    @State private var forMyself: Bool = true
    @State private var otherName: String = ""
    @State private var otherContact: String = ""
    @State private var note: String = ""
    @State private var showSuccess: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appointment")) {
                    DatePicker("Date & Time", selection: $vm.date, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Booking For")) {
                    Picker("Who", selection: $forMyself) {
                        Text("Myself").tag(true)
                        Text("Someone else").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                if forMyself == false {
                    Section(header: Text("Contact Details")) {
                        TextField("Full Name", text: $otherName)
                        TextField("Contact (phone/email)", text: $otherContact)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                    }
                }

                Section(header: Text("Description")) {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
                }
            }
            .navigationTitle("Book: \(place.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        let name = forMyself ? (profile.fullName.isEmpty ? "Me" : profile.fullName) : otherName
                        let contact = forMyself ? profile.contact : otherContact
                        vm.submitBooking(for: place, userName: name, userContact: contact, note: note)
                        showSuccess = true
                    }
                    .disabled((forMyself == false) && (otherName.isEmpty || otherContact.isEmpty))
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Booking Confirmed", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your appointment has been booked.")
            }
        }
    }
}

#Preview {
    BookingView(place: Place(id: "1", name: "Test Clinic", subtitle: "123 Main St", coordinate: CLLocationCoordinate2DMake(0, 0)))
}
