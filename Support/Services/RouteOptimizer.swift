//
//  RouteOptimizer.swift
//  Diploma
//
//  Created by Olesia Skydan on 28.04.2025.
//

import CoreLocation

struct RoutePlan {
    let ordered : [Waypoint]
    let origin  : CLLocationCoordinate2D      // user-location або точка «Start»
}


enum RouteOptimizer {

    /// Строит упорядоченный маршрут «жадным» (nearest–neighbour) методом
    ///
    /// - Parameters:
    ///   - waypoints:   исходный список точек
    ///   - startID:     UUID точки-старта (nil ⇒ старт — текущее местоположение)
    ///   - endID:       UUID точки-финиша (nil ⇒ финиш = последняя точка после оптимизации)
    ///   - userOrigin:  координата пользователя, если старт не указан
    static func build(waypoints  : [Waypoint],
                      startID    : UUID?,
                      endID      : UUID?,
                      userOrigin : CLLocationCoordinate2D?) -> RoutePlan
    {
        precondition(!waypoints.isEmpty, "Waypoints must not be empty")

        //----------------------------------------------------------------------
        // 0. пул непосещённых точек — храним **индексы**, а не сами структуры
        //----------------------------------------------------------------------
        var pool = Array(waypoints.indices)

        //----------------------------------------------------------------------
        // 1. определяем стартовую координату и (опционально) вырезаем точку-старт
        //----------------------------------------------------------------------
        var startIdxInOriginal: Int?
        let originCoord: CLLocationCoordinate2D

        if let sid = startID,
           let sIdx = waypoints.firstIndex(where: { $0.id == sid }) {

            startIdxInOriginal = sIdx
            originCoord        = waypoints[sIdx].coord
            pool.removeAll { $0 == sIdx }          // убираем дубликат из пула

        } else {
            originCoord = userOrigin ?? waypoints[pool[0]].coord
        }

        //----------------------------------------------------------------------
        // 2. если финиш зафиксирован — тоже вынимаем его из пула
        //----------------------------------------------------------------------
        var endIdxInOriginal: Int?
        if let eid = endID,
           let ePos = pool.firstIndex(where: { waypoints[$0].id == eid }) {
            endIdxInOriginal = pool.remove(at: ePos)
        }

        //----------------------------------------------------------------------
        // 3. жадный обход пула (nearest neighbour)
        //----------------------------------------------------------------------
        var routeIdx: [Int] = []
        var current = originCoord

        while !pool.isEmpty {
            // ищем ближайший индекс в pool
            var nearest = 0
            var bestDist = current.distance(to: waypoints[pool[0]].coord)

            for i in 1..<pool.count {
                let d = current.distance(to: waypoints[pool[i]].coord)
                if d < bestDist { bestDist = d; nearest = i }
            }

            let nextIdx = pool.remove(at: nearest)
            routeIdx.append(nextIdx)
            current = waypoints[nextIdx].coord
        }

        //----------------------------------------------------------------------
        // 4. вставляем старт (если был) и финиш (если был)
        //----------------------------------------------------------------------
        if let sIdx = startIdxInOriginal {
            routeIdx.insert(sIdx, at: 0)           // теперь старт — первый в массиве
        }

        if let eIdx = endIdxInOriginal {
            routeIdx.append(eIdx)                  // финиш всегда последний
        }

        //----------------------------------------------------------------------
        // 5. формируем упорядоченный массив Waypoint-ов и возвращаем план
        //----------------------------------------------------------------------
        let ordered = routeIdx.map { waypoints[$0] }
        return RoutePlan(ordered: ordered, origin: originCoord)
    }
}

// MARK: – расстояние между координатами (быстрый хелпер)
private extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        let a = CLLocation(latitude:  latitude,       longitude: longitude)
        let b = CLLocation(latitude:  other.latitude, longitude: other.longitude)
        return a.distance(from: b)   // ≈ метры
    }
}
