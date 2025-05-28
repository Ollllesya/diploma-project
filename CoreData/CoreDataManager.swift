//
//  CoreDataManager.swift
//  Diploma
//
//  Created by Olesia Skydan on 01.05.2025.
//

import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()
    private init() {}

    // ───── контейнер ───────────────────────────────────────────────────
    lazy var container: NSPersistentContainer = {
        let c = NSPersistentContainer(name: "Model")   // .xcdatamodeld
        c.loadPersistentStores { _, error in
            if let err = error { fatalError("CoreData error: \(err)") }
        }
        return c
    }()
    var ctx: NSManagedObjectContext { container.viewContext }

    // ───── СОЗДАНИЕ МАРШРУТОВ ──────────────────────────────────────────

    /// Создать «обычный» маршрут (scheduled = false)
    @discardableResult
    func createRoute(title: String,
                     waypoints: [Waypoint],
                     polyline : String? = nil) throws -> RouteModel {

        try createRouteInternal(title      : title,
                                waypoints  : waypoints,
                                polyline   : polyline,
                                scheduled  : false)
    }

    /// Создать маршрут ТОЛЬКО для календаря (scheduled = true)
    @discardableResult
    func createScheduledRoute(title: String,
                              waypoints: [Waypoint],
                              polyline : String?,
                              id: UUID? = nil) throws -> RouteModel {

        try createRouteInternal(title      : title,
                                waypoints  : waypoints,
                                polyline   : polyline,
                                scheduled  : true,
                                id         : id)
    }

    /// Общая реализация
    private func createRouteInternal(title     : String,
                                     waypoints : [Waypoint],
                                     polyline  : String?,
                                     scheduled : Bool,
                                     id        : UUID? = nil) throws -> RouteModel {

        let route = RouteModel(context: ctx)
        route.id        = id ?? UUID()
        route.title     = title
        route.createdAt = Date()
        route.editing   = false
        route.polyline  = polyline
        route.scheduled = scheduled       // ← ключевое отличие

        waypoints.enumerated().forEach { idx, wp in
            let m = WaypointModel(context: ctx)
            m.fill(from: wp, order: Int16(idx))
            route.addToWaypoints(m)
        }
        try ctx.save()
        return route
    }

    // ───── ЧТЕНИЕ / УДАЛЕНИЕ ──────────────────────────────────────────

    /// Вернуть маршруты. По-умолчанию scheduled == false (т.е. «Favourite»)
    func fetchRoutes(includeScheduled: Bool = false) throws -> [RouteModel] {
        let req = RouteModel.fetchRequest()
        if !includeScheduled {
            req.predicate = NSPredicate(format: "scheduled == NO")
        }
        req.sortDescriptors = [.init(key: #keyPath(RouteModel.createdAt),
                                     ascending: false)]
        return try ctx.fetch(req)
    }

    /// Удалить маршрут по objectID
    func delete(id objectID: NSManagedObjectID) throws {
        let obj = try ctx.existingObject(with: objectID)
        ctx.delete(obj)
        try ctx.save()
    }

    /// Найти маршрут по UUID
    func route(id: UUID) -> RouteModel? {
        let req = RouteModel.fetchRequest()
        req.predicate  = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        return try? ctx.fetch(req).first
    }

    /// Полное обновление waypoints / polyline
    func update(route: RouteModel,
                with waypoints: [Waypoint],
                polyline: String? = nil) throws {

        route.waypoints?.forEach { ctx.delete($0 as! NSManagedObject) }

        waypoints.enumerated().forEach { idx, wp in
            let m = WaypointModel(context: ctx)
            m.fill(from: wp, order: Int16(idx))
            route.addToWaypoints(m)
        }
        if let poly = polyline { route.polyline = poly }
        try ctx.save()
    }
}
