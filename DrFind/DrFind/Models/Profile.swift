//  Profile.swift
//  DrFind

import Foundation
import Combine

final class ProfileStore: ObservableObject {
    static let shared = ProfileStore()
    @Published var fullName: String {
        didSet { persist() }
    }
    @Published var contact: String {
        didSet { persist() }
    }

    private let nameKey = "drfind.profile.name"
    private let contactKey = "drfind.profile.contact"

    private init() {
        self.fullName = UserDefaults.standard.string(forKey: nameKey) ?? ""
        self.contact = UserDefaults.standard.string(forKey: contactKey) ?? ""
    }

    private func persist() {
        UserDefaults.standard.set(fullName, forKey: nameKey)
        UserDefaults.standard.set(contact, forKey: contactKey)
    }
}
