//
//  WaypointStore.swift
//  Diploma
//
//  Created by Олеся Скидан on 28.04.2025.
//

import Foundation

/// Персистентное хранилище точек маршрута + индексы start / end
final class WaypointStore {
    private let ud  = UserDefaults.standard
    
    private(set) var waypoints : [Waypoint] = []
    var startIndex : Int?
    var endIndex   : Int?
    
    // MARK: – load / save
    func load() {
        if
            let data = ud.data(forKey: "savedWaypoints"),
            let arr  = try? JSONDecoder().decode([Waypoint].self, from: data)
        { waypoints = arr }
        
        startIndex = ud.object(forKey: "startIndex") as? Int
        endIndex   = ud.object(forKey: "endIndex")   as? Int
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(waypoints) {
            ud.set(data, forKey: "savedWaypoints")
        }
        ud.set(startIndex, forKey: "startIndex")
        ud.set(endIndex,   forKey: "endIndex")
    }
    
    // MARK: – мутации (с сохранением)
    func append(_ wp: Waypoint) {
        waypoints.append(wp); save()
    }
    
    func remove(at i: Int) {
        waypoints.remove(at: i)
        if startIndex == i { startIndex = nil }
        if endIndex   == i { endIndex   = nil }
        if let s = startIndex, s > i { startIndex = s - 1 }
        if let e = endIndex,   e > i { endIndex   = e - 1 }
        save()
    }
    
    func clear() {
        waypoints.removeAll()
        startIndex = nil
        endIndex   = nil
        save()
    }
}
