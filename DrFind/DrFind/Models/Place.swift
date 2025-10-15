//  Place.swift
//  DrFind

import Foundation
import CoreLocation
import MapKit

struct Place: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let phoneNumber: String?
    let hours: String?
    let category: String?

    init(mapItem: MKMapItem) {
        let lat = mapItem.placemark.coordinate.latitude
        let lon = mapItem.placemark.coordinate.longitude
        self.id = "\(lat),\(lon)|\(mapItem.name ?? "")"
        self.name = mapItem.name ?? "Unknown"
        self.subtitle = [
            mapItem.placemark.subThoroughfare,
            mapItem.placemark.thoroughfare,
            mapItem.placemark.locality
        ].compactMap { $0 }.joined(separator: ", ")
        self.coordinate = mapItem.placemark.coordinate
        self.phoneNumber = mapItem.phoneNumber
        self.hours = nil
        self.category = mapItem.pointOfInterestCategory?.rawValue
    }

    init(id: String = UUID().uuidString,
         name: String,
         subtitle: String,
         coordinate: CLLocationCoordinate2D,
         phoneNumber: String? = nil,
         hours: String? = nil,
         category: String? = nil) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.phoneNumber = phoneNumber
        self.hours = hours
        self.category = category
    }
}

extension Place {
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let lat = try container.decode(CLLocationDegrees.self)
        let lon = try container.decode(CLLocationDegrees.self)
        self.init(latitude: lat, longitude: lon)
    }
}
