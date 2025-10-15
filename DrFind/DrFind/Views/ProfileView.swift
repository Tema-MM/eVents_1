//  ProfileView.swift
//  DrFind

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profile = ProfileStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section(header: Text("Your Details")) {
                TextField("Full Name", text: $profile.fullName)
                TextField("Contact (phone/email)", text: $profile.contact)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
