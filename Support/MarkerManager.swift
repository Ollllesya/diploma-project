//
//  MarkerManager.swift
//  Diploma
//
//  Created by Olesia Skydan on 29.04.2025.
//

import GoogleMaps
import UIKit


/// Управляет маркерами на карте (цвет, добавление, очистка)
final class MarkerManager {

    private(set) var markers: [GMSMarker] = []
    private weak var mapView: GMSMapView?

    init(mapView: GMSMapView) { self.mapView = mapView }

    // MARK: – Public API --------------------------------------------------------

    func clearAll() {
        markers.forEach { $0.map = nil }
        markers.removeAll()
    }

    /// Добавить маркер для Waypoint-а
    func addMarker(for wp: Waypoint,
                   startID: UUID?,
                   endID  : UUID?) {
        let marker = GMSMarker(position: wp.coord)
        marker.userData = wp.id                         // ← сохраняем UUID
        marker.icon     = GMSMarker.markerImage(with: color(for: wp,
                                                            startID: startID,
                                                            endID: endID))
        marker.title    = wp.title
        marker.map      = mapView
        markers.append(marker)
    }

    /// Маркер «Старт» (если startID == nil)
    func addCurrentLocationStart(at coord: CLLocationCoordinate2D) {
        let m = GMSMarker(position: coord)
        m.icon  = GMSMarker.markerImage(with: .systemGreen)
        m.title = "Start"
        m.map   = mapView
        markers.append(m)
    }

    /// Цветовая перераскраска после изменений
    func updateMarkerColors(startID: UUID?, endID: UUID?, waypoints: [Waypoint]) {
        for marker in markers {
            guard let id = marker.userData as? UUID,
                  let wp = waypoints.first(where: { $0.id == id }) else { continue }
            marker.icon = GMSMarker.markerImage(with: color(for: wp,
                                                            startID: startID,
                                                            endID: endID))
        }
    }

    /// Нарисовать полилинию
    func showPolyline(path: GMSPath) {
        let pl = GMSPolyline(path: path)
        pl.strokeColor = .systemGreen
        pl.strokeWidth = 5
        pl.map = mapView
    }

    // MARK: – Private helpers ---------------------------------------------------

    private func color(for wp: Waypoint, startID: UUID?, endID: UUID?) -> UIColor {
        return wp.id == startID ? .systemGreen :
               wp.id == endID   ? .systemRed   :
               wp.isPOI         ? .systemPurple :
                                  .systemBlue
    }
}
