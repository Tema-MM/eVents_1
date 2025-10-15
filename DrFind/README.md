# DrFind

SwiftUI + MapKit app to find doctors/hospitals nearby, view details, get directions, and book appointments.

## Features
- Location permission on launch and centering map on user location (`Services/LocationManager.swift`).
- Map with search via `MKLocalSearch` and specialty chips (`Views/MapSearchView.swift`, `ViewModels/MapSearchViewModel.swift`).
- Custom annotations and selection bridged via `MKMapView` (`Views/MapViewRepresentable.swift`).
- Detail page with name, address, phone, hours, buttons for directions and booking (`Views/PlaceDetailView.swift`).
- Directions rendered as polyline via `MKDirections` (`ViewModels/MapSearchViewModel.swift`).
- Booking form with local persistence in `UserDefaults` (`Views/BookingView.swift`, `Models/Booking.swift`).
- MVVM structure with separate view models (`ViewModels/`).

## Project Structure
- `DrFindApp.swift`: App entry.
- `ContentView.swift`: Root shows `MapSearchView`.
- `Models/`: `Place`, `Booking`.
- `Services/`: `LocationManager` for permissions and location updates.
- `ViewModels/`: `MapSearchViewModel`, `BookingViewModel`.
- `Views/`: `MapSearchView`, `MapViewRepresentable`, `PlaceDetailView`, `BookingView`.

## Setup
1. Open `DrFind.xcodeproj` in Xcode 15+.
2. In target Info, add the following Info.plist keys with user-facing strings:
   - `NSLocationWhenInUseUsageDescription` = "We use your location to find nearby doctors and hospitals."
3. Build & Run on a device or simulator with location.

Optional keys if you later request always-on location:
- `NSLocationAlwaysAndWhenInUseUsageDescription`.

## Usage
- On launch, allow location access.
- Use the search bar to search (defaults to "Doctors").
- Tap a specialty chip to filter (e.g., Dentist, Hospital).
- Tap a pin to open details.
- From details, tap "Get Directions" to draw the route, or "Book Appointment" to submit a booking.

## Notes
- Recent searches and bookings are persisted via `UserDefaults`.
- Office hours are shown as a static example (Mon–Fri 8:00–17:00). Replace with real data when available.
- Phone numbers come from `MKMapItem.phoneNumber` when provided by MapKit.
