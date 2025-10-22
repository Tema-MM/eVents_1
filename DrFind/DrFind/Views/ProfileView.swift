//  ProfileView.swift
//  DrFind

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profile = ProfileStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // User avatar section
                VStack {
                    Image("fWhiteDr")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )

                    Text("Your Details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.secondarySystemBackground))

                // Form fields
                VStack(spacing: 16) {
                    // Full name field
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        TextField("Full name", text: $fullName)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )

                    // Email field
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        TextField("Email", text: $email)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )

                    // Phone number field
                    HStack {
                        Image(systemName: "phone")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        TextField("Phone number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                // Save button
                Button(action: {
                    // Save profile data
                    profile.fullName = fullName
                    profile.contact = email // Using email as contact for now
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "lock")
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cyan)
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Load existing profile data
            fullName = profile.fullName
            email = profile.contact // Using contact as email for now
            phoneNumber = "" // Would load from profile if available
        }
    }
}

#Preview {
    NavigationStack { ProfileView() }
}
