//  BookingViewModel.swift
//  DrFind

import Foundation
import Combine

@MainActor
final class BookingViewModel: ObservableObject {
    @Published var date: Date = Date()

    func submitBooking(for place: Place, userName: String, userContact: String, note: String?) {
        let booking = Booking(
            id: UUID().uuidString,
            placeId: place.id,
            placeName: place.name,
            date: date,
            userName: userName,
            userContact: userContact,
            note: note
        )
        BookingsStore.shared.add(booking)
    }
}
