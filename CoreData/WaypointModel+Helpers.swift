//
//  WaypointModel+Helpers.swift
//  Diploma
//
//  Created by Olesia Skydan on 01.05.2025.
//


import CoreLocation

extension WaypointModel {
    func toWaypoint() -> Waypoint {
        Waypoint(title: title ?? "",
                 placeId: placeId ?? "",
                 coord: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                 isPOI: isPOI)
    }

    func fill(from wp: Waypoint, order: Int16) {
        title   = wp.title
        placeId = wp.placeId
        lat     = wp.coord.latitude
        lng     = wp.coord.longitude
        isPOI   = wp.isPOI
        self.order = order
    }
}

// RouteModel+Helpers.swift
extension RouteModel {
    /// waypoints, отсортированные по полю order
    func sortedWaypoints() -> [Waypoint] {
        (waypoints as? Set<WaypointModel> ?? [])
            .sorted { $0.order < $1.order }
            .map   { $0.toWaypoint() }
    }
}
