//  Booking.swift
//  DrFind

import Foundation
import CoreLocation
import Combine
import SwiftUI

struct Booking: Identifiable, Codable, Equatable {
    let id: String
    let placeId: String
    let placeName: String
    let date: Date
    var userName: String
    var userContact: String
    var note: String?
}

final class BookingsStore: ObservableObject {
    static let shared = BookingsStore()
    private let key = "drfind.bookings"
    @Published var items: [Booking] = [] {
        didSet { persist() }
    }
    private init() {
        items = load()
    }

    private func load() -> [Booking] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Booking].self, from: data)) ?? []
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func add(_ booking: Booking) {
        items.insert(booking, at: 0)
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func remove(id: String) {
        if let idx = items.firstIndex(where: { $0.id == id }) {
            items.remove(at: idx)
        }
    }
}
