//
//  WaypointsStorage.swift.swift
//  Diploma
//
//  Created by Olesia Skydan on 27.04.2025.
//

import Foundation
import CoreLocation          // (GoogleMaps / Places не нужны в модели)

/// Точка маршрута (звичайна або POI)
struct Waypoint: Codable, Equatable, Identifiable {

    // ────────────  НОВОЕ  ────────────
    /// Cтабільний ідентифікатор, генерируется один раз и сохраняется в CoreData / UserDefaults
    let id: UUID

    // ────────────  СТАРЫЕ ПОЛЯ  ──────
    let title:   String
    let placeId: String
    let coord:   CLLocationCoordinate2D
    var isPOI:   Bool = false

    // MARK: – init
    init(id: UUID = UUID(),
         title: String,
         placeId: String,
         coord: CLLocationCoordinate2D,
         isPOI: Bool = false)
    {
        self.id      = id
        self.title   = title
        self.placeId = placeId
        self.coord   = coord
        self.isPOI   = isPOI
    }

    // MARK: – Equatable
    /// Сравниваем только по `id`, чтобы индексы/порядок не влияли
    static func == (lhs: Waypoint, rhs: Waypoint) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: – Codable
    private enum CodingKeys: String, CodingKey {
        case id, title, placeId, latitude, longitude, isPOI
    }

    init(from decoder: Decoder) throws {
        let c   = try decoder.container(keyedBy: CodingKeys.self)
        id      = try c.decode(UUID.self,            forKey: .id)
        title   = try c.decode(String.self,          forKey: .title)
        placeId = try c.decode(String.self,          forKey: .placeId)
        let lat = try c.decode(CLLocationDegrees.self, forKey: .latitude)
        let lng = try c.decode(CLLocationDegrees.self, forKey: .longitude)
        coord   = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        isPOI   = try c.decodeIfPresent(Bool.self, forKey: .isPOI) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,                  forKey: .id)
        try c.encode(title,               forKey: .title)
        try c.encode(placeId,             forKey: .placeId)
        try c.encode(coord.latitude,      forKey: .latitude)
        try c.encode(coord.longitude,     forKey: .longitude)
        try c.encode(isPOI,               forKey: .isPOI)
    }
}
