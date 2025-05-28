//
//  WaypointModel+DTO.swift
//  Diploma
//
//  Created by Olesia Skydan on 01.05.2025.
//

import CoreData
import CoreLocation

extension WaypointModel {
    func toDTO() -> Waypoint {
        .init(title : title        ?? "",
              placeId: placeId      ?? "",
              coord  : .init(latitude:  lat,
                             longitude: lng),
              isPOI  : isPOI)
    }
}

extension RouteModel {
    var orderedWaypoints: [Waypoint] {
        (waypoints as? Set<WaypointModel> ?? [])
            .sorted { $0.order < $1.order }
            .map   { $0.toDTO() }
    }
}
