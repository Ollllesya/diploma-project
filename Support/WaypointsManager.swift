//
//  WaypointsManager.swift
//  Diploma
//
//  Created by Olesia Skydan on 29.04.2025.
//

import Foundation
import CoreLocation

/// Хранит waypoints + выбор start / end + метаданные маршрута
final class WaypointsManager {

    // MARK: – Public stored properties
    private(set) var waypoints: [Waypoint] = []
    var tempRouteID: UUID?

    /// UUID начальной и конечной точек (nil ⇒ не выбрано)
    var startID: UUID?
    var endID  : UUID?

    var savedDuration: Int?
    var savedDistance: Int?

    /// Закодированная полилиния (сохраняется сразу при изменении)
    var encodedPolyline: String? {
        didSet { ud.set(encodedPolyline, forKey: polyKey) }
    }

    var isEmpty: Bool { waypoints.isEmpty }

    // MARK: – Private
    private let ud        = UserDefaults.standard
    private let wpKey     = "savedWaypoints"
    private let startKey  = "startUUID"
    private let endKey    = "endUUID"
    private let polyKey   = "savedPolyline"
    private let timeKey   = "savedDuration"
    private let distKey   = "savedDistance"

    // MARK: – CRUD
    func add(_ wp: Waypoint) {
        waypoints.append(wp)
        invalidatePolyline()
        save()
    }

    func remove(at idx: Int) {
        let removed = waypoints.remove(at: idx)

        if removed.id == startID { startID = nil }
        if removed.id == endID   { endID   = nil }

        invalidatePolyline()
        save()
    }

    /// Переупорядочить по массиву индексов `order`
    func reorder(by order: [Int]) {
        let original = waypoints
        waypoints = order
            .filter { $0 >= 0 && $0 < original.count }
            .map   { original[$0] }

        // ID-выборы остаются валидными: Waypoint.id не меняется
        invalidatePolyline()
        save()
    }

    /// Текущий индекс Waypoint-а по его UUID
    func index(of id: UUID?) -> Int? {
        guard let id else { return nil }
        return waypoints.firstIndex { $0.id == id }
    }

    // MARK: – Метаданные
    func saveMeta(duration: Int, distance: Int) {
        savedDuration = duration
        savedDistance = distance
        ud.set(duration, forKey: timeKey)
        ud.set(distance,  forKey: distKey)
    }

    // MARK: – Persistence
    func save() {
        guard let data = try? JSONEncoder().encode(waypoints) else { return }

        ud.set(data,                                forKey: wpKey)
        ud.set(startID?.uuidString,                 forKey: startKey)
        ud.set(endID?.uuidString,                   forKey: endKey)
        // poly- / meta- / dist сохранялись в своих сеттерах
    }

    func load() {
        // waypoints
        if let data = ud.data(forKey: wpKey),
           let saved = try? JSONDecoder().decode([Waypoint].self, from: data) {
            waypoints = saved
        }

        // IDs
        if let s = ud.string(forKey: startKey) { startID = UUID(uuidString: s) }
        if let e = ud.string(forKey: endKey)   { endID   = UUID(uuidString: e) }

        // polyline & meta
        encodedPolyline = ud.string(forKey: polyKey)
        savedDuration   = ud.object(forKey: timeKey) as? Int
        savedDistance   = ud.object(forKey: distKey) as? Int
    }

    func removeAll() {
        waypoints.removeAll()
        startID = nil
        endID   = nil
        encodedPolyline = nil
        save()
    }
    

    /// Полностью заменяет массив точек (используется после оптимизации)
    func replaceAll(with list: [Waypoint]) {
        waypoints = list
        invalidatePolyline()   // полилиния больше неактуальна
        save()
    }


    // MARK: – Helpers
    private func invalidatePolyline() {
        encodedPolyline = nil        // setter сам сохранит в UserDefaults
    }
}
