//
//  ViewController.swift
//  Diploma
//
//  Created by Olesia Skydan on 17.02.2025.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import SwiftyJSON
import EventKit


class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - UI Elements (IBOutlets)
    @IBOutlet weak var openingMenuView: UIView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var openingMenuHeight: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchField: UISearchBar!
    
    @IBOutlet weak var waypointTable: UITableView!
    @IBOutlet weak var pointsTableView: UITableView!
    @IBOutlet weak var anyPointsLabel: UILabel!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var routeLengthLabel: UILabel!
    
    @IBOutlet weak var buildRouteButton: UIButton!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var clearTheRouteButton: UIButton!
    @IBOutlet weak var planARouteButton: UIButton!
    
    private lazy var spinner = UIActivityIndicatorView(style: .large)
    
    private var previewMarker: GMSMarker?
    private lazy var places = PlacesService(apiKey: googleApiKey)
    private var popupManager: PopupManager!
    private var markerManager: MarkerManager!
    private var waypointManager = WaypointsManager()
    private lazy var poiFinder = POIFinder(apiKey: googleApiKey)
    private var currentPolyline: GMSPolyline?
    
    private var encodedPolyline: String?

    private var startIdx: Int? { waypointManager.index(of: waypointManager.startID) }
    private var endIdx  : Int? { waypointManager.index(of: waypointManager.endID)   }

    
    private func clearPreviewMarker() {
        previewMarker?.map = nil
        previewMarker = nil
    }
    
    private let locationManager = CLLocationManager()
    private var currentUserLocation: CLLocationCoordinate2D?
    private let sessionToken = UUID().uuidString
    private let googleApiKey = "AIzaSyA1XMnhrc-Ig-HwuyUCkKcX0aUlaiB48S4"
    
    private var searchResults: [PlaceResult] = []
    
    // MARK: - Waypoints & Route
    //    private var waypoints: [PlaceResult] = []
    private var markers: [GMSMarker] = []
    private var coordinates: [CLLocationCoordinate2D] = []
    
    
    // MARK: - UI State
    private var initialMenuHeight: CGFloat = 0
    var routeState: RouteState = .idle {
        didSet {
            updateUIForCurrentState()
        }
    }
    
    private func updateUIForCurrentState() {
        RouteUIState.apply(
            routeState,
            buildRouteButton: buildRouteButton,
            addToFavoritesButton: addToFavoritesButton,
            clearTheRouteButton: clearTheRouteButton,
            planARouteButton: planARouteButton,
            anyPointsLabel: anyPointsLabel,
            travelTimeLabel: travelTimeLabel,
            routeLengthLabel: routeLengthLabel,
            bottomStackView: bottomStackView
        )
        addToFavoritesButton.isHidden = (routeState != .routeBuilt)
        view.layoutIfNeeded()
    }
    
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    let arrowImage = UIImage(systemName: "arrowtriangle.up.fill")!
                         .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)

    private func configureMap() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
    }
    
    private func configureSearchField() {
        searchField.delegate = self
        searchField.applyRoundedStyle(accentColor: .systemBlue, blur: true)
    }
    
    private func configureGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        openingMenuView.addGestureRecognizer(panGesture)
    }
    
    private func configureTabBar() {
        let tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 0)
        tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        tabBarItem.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .selected)
        self.tabBarItem = tabBarItem
        tabBarController?.selectedIndex = 0
    }
    
    private func setupInitialViewState() {
        ButtonStyler.applyStyle(.filledYellow, to: buildRouteButton)
        ButtonStyler.applyStyle(.filledYellow, to: planARouteButton)
        ButtonStyler.applyStyle(.filledYellow, to: addToFavoritesButton)
        ButtonStyler.applyStyle(.filledYellow, to: clearTheRouteButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupInitialViewState()
        popupManager?.movePopupOnMapChange()
    }
    
    private func styleBottomMenu() {
        MapStyleManager.styleBottomMenu(view: openingMenuView, waypointTable: waypointTable)
    }
    
    private func stylePointsTable() {
        MapStyleManager.stylePointsTable(pointsTableView)
    }
    
    
    private func configureTables() {
        TableConfigurator.configure(
            tableView: waypointTable,
            type: .waypoints,
            delegate: self,
            dataSource: self
        )
        
        TableConfigurator.configure(
            tableView: pointsTableView,
            type: .searchPoints,
            delegate: self,
            dataSource: self
        )
    }

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        configureMap()
        configureSearchField()
        configureTables()
        configureTabBar()
        configureGestures()
        showSpinner()
        
        styleBottomMenu()
        loadWaypoints()
        popupManager = PopupManager(view: self.view, mapView: mapView)
        markerManager = MarkerManager(mapView: mapView)
        runPOIMigrationIfNeeded()
        setupDefaultPOIPreference()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        hideSpinner()
    }
    
    private func setupDefaultPOIPreference() {
        if UserDefaults.standard.object(forKey: POIPreferenceKey.shouldAskForPOI) == nil {
            UserDefaults.standard.shouldAskForAdditionalPOI = true
        }
        
        if UserDefaults.standard.object(forKey: POIPreferenceKey.manuallySelectingLastPoint) == nil {
            UserDefaults.standard.manuallySelectingLastPoint = false
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if !waypointManager.waypoints.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let minHeight: CGFloat = 70
        let maxHeight: CGFloat = 300
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            initialMenuHeight = openingMenuHeight.constant
            
        case .changed:
            var newHeight = initialMenuHeight - translation.y
            
            newHeight = max(minHeight, min(maxHeight, newHeight))
            
            openingMenuHeight.constant = newHeight
            
        case .ended, .cancelled:
            let mid = (minHeight + maxHeight) / 2
            let currentHeight = openingMenuHeight.constant
            let finalHeight = (currentHeight < mid) ? minHeight : maxHeight
            
            UIView.animate(withDuration: 0.3) {
                self.openingMenuHeight.constant = finalHeight
                self.view.layoutIfNeeded()
            }
            
        default:
            break
        }
    }
    
    private func recalcState() {
        switch (waypointManager.isEmpty,
                waypointManager.encodedPolyline?.isEmpty == false) {
        case (true, _):       routeState = .idle
        case (false, false):  routeState = .selectingPoints
        case (false, true):   routeState = .routeBuilt
        }
    }
    
    private func loadWaypoints() {
        waypointManager.load()
        waypointTable.reloadData()
        refreshMarkers()
        recalcState()
        if let enc = waypointManager.encodedPolyline,
           let path = GMSPath(fromEncodedPath: enc) {

            self.encodedPolyline = enc
            routeState = .routeBuilt
            mapView.clear()
            let pl = GMSPolyline(path: path)
            pl.strokeColor = .systemGreen
            pl.strokeWidth = 5
            pl.map = mapView
            mapView.animate(with: .fit(GMSCoordinateBounds(path: path), withPadding: 50))

            rebuildMarkers()
        } else if waypointManager.isEmpty {
            routeState = .idle
        } else {
            routeState = .selectingPoints
        }
        if let t = waypointManager.savedDuration,
           let d = waypointManager.savedDistance {

            travelTimeLabel.text  = "Time: \(t / 60) min"
            routeLengthLabel.text = d < 1000
                ? "Distance: \(d) m"
                : "Distance: \(d / 1000) km"
        }
    }
    
    // MARK: - UI actions
    @IBAction func clearTheRouteButtonTapped(_ sender: Any) {
        clearRoute()                     // одного вызова достаточно
    }

    // MARK: - Сброс маршрута
    func clearRoute() {

        // 1. Отменяем любые ещё работающие коллбеки
        places.cancelAllRunningRequests()          // ▸ добавьте такой метод-обёртку
    

        // 2. Карта и маркеры
        mapView.clear()
        markers.removeAll()
        clearPreviewMarker()                       // убираем «серую» булавку

        // 3. Сбрасываем Waypoints
        waypointManager.removeAll()                // очищает массив + startID / endID

        // 4. UI
        searchResults.removeAll()
        pointsTableView.isHidden = true
        waypointTable.reloadData()

        routeState = .idle
        updateUIForCurrentState()

        // 5. Сброс флагов
        UserDefaults.standard.manuallySelectingFirstPoint = false
        UserDefaults.standard.manuallySelectingLastPoint  = false
        UserDefaults.standard.shouldAskForAdditionalPOI   = true
    }


    @IBAction func buildRouteButtonTapped(_ sender: Any) {
        if waypointManager.isEmpty {
            AlertManager.showNoPointsAlert(on: self)
        }
        buildOptimisedRoute()
    }
    
    
    @IBAction func planARoute(_ sender: Any) {

        guard !waypointManager.isEmpty else { return }

        // ── 1. если уже есть tempRouteID – просто показываем выбор даты ──
        if let id = waypointManager.tempRouteID {
            presentDateSheet(for: id)
            return
        }

        // ── 2. формируем список точек ───────────────────────────────────
        var list = waypointManager.waypoints

        func continueWith(list: [Waypoint]) {
            // сохраняем scheduled-маршрут
            let title = DateFormatter.localizedString(from: Date(),
                                                      dateStyle: .medium,
                                                      timeStyle: .none)
            if let r = try? CoreDataManager.shared.createScheduledRoute(
                            title: title,
                            waypoints: list,
                            polyline : encodedPolyline) {

                waypointManager.tempRouteID = r.id
                presentDateSheet(for: r.id!)
            }
        }

        // ── 3. нужен ли Waypoint «My location»? ─────────────────────────
        if waypointManager.startID == nil, let loc = currentUserLocation {

            // адрес пользователя → создаём start-Waypoint
            humanAddress(for: loc) { [weak self] addr in
                guard let self else { return }
                var copy = list
                copy.insert(Waypoint(title: addr,
                                     placeId: "",
                                     coord : loc), at: 0)
                continueWith(list: copy)
            }

        } else {
            // старт уже выбран пользователем
            continueWith(list: list)
        }
    }

    // helper
    private func presentDateSheet(for id: UUID) {
        let sheet = DateSheetVC { [weak self] picked in
            self?.addEvent(date: picked, routeID: id)
        }
        present(sheet, animated: true)
    }

    
    
    @IBAction func addToFavoritesButtonTapped(_ sender: Any) {
        saveCurrentRoute()
    }
    
    private func rebuildMarkers() {
        markers.forEach { $0.map = nil }
        markers.removeAll()

        // 2. старт-маркер
        if let s = startIdx {
            addMarker(for: waypointManager.waypoints[s])          // 🔄 idx больше не нужен
        } else if let loc = currentUserLocation {
            let m = GMSMarker(position: loc)
            m.icon = GMSMarker.markerImage(with: .systemGreen)
            m.title = "Start"
            m.map = mapView
            markers.append(m)
        }

        // 3. остальные
        for wp in waypointManager.waypoints where wp.id != waypointManager.startID {
            addMarker(for: wp)
        }
    }


    /// Показывает сохранённый маршрут (из Calendar или Favourite)
    func showRoute(_ saved: RouteModel, fromCalendar: Bool = false) {

        //------------------------------------------------------------
        // 0. загружаем waypoints в менеджер
        //------------------------------------------------------------
        waypointManager.replaceAll(with: saved.orderedWaypoints)   // точки
        waypointManager.startID         = nil                      // «My location» ≙ старт
        waypointManager.endID           = nil
        waypointManager.encodedPolyline = saved.polyline
        waypointManager.save()

        //------------------------------------------------------------
        // 1. очищаем карту
        //------------------------------------------------------------
        mapView.clear()
        markers.forEach { $0.map = nil }
        markers.removeAll()

        //------------------------------------------------------------
        // 2. линия маршрута (если была сохранена)
        //------------------------------------------------------------
        if let enc = saved.polyline,
           let path = GMSPath(fromEncodedPath: enc) {

            let pl = GMSPolyline(path: path)
            pl.strokeColor = .systemGreen
            pl.strokeWidth = 5
            pl.map = mapView
            mapView.animate(with: .fit(GMSCoordinateBounds(path: path), withPadding: 50))
        }

        //------------------------------------------------------------
        // 3. булавки для каждой точки
        //------------------------------------------------------------
        let only = waypointManager.waypoints.count == 1

        for (idx, wp) in waypointManager.waypoints.enumerated() {
            let m = GMSMarker(position: wp.coord)
            m.userData = wp.id

            let color: UIColor =
                  only        ? .systemGreen                    // одна точка => start+end
                : idx == 0   ? .systemGreen
                : idx == waypointManager.waypoints.count - 1
                             ? .systemRed
                : wp.isPOI   ? .systemPurple
                : .systemBlue

            m.icon  = GMSMarker.markerImage(with: color)
            m.title = only ? "\(wp.title) (start/end)" : wp.title
            m.map   = mapView
            markers.append(m)
        }

        //------------------------------------------------------------
        // 4. обновляем таблицу и UI-состояние
        //------------------------------------------------------------
        waypointTable.reloadData()
        routeState = fromCalendar ? .fromCalendar : .routeBuilt
        updateUIForCurrentState()
    }


    private func addEvent(date: Date, routeID: UUID) {

        let store = EKEventStore()
        store.requestAccess(to: .event) { [weak self] granted, err in
            guard let self else { return }

            guard granted else {
                self.showInfo("Open Settings → Privacy → Calendars to allow access.")
                return
            }
            if let err { self.showInfo("Error \(err.localizedDescription)"); return }

            let ev = EKEvent(eventStore: store)
            ev.title     = "Planned trip"
            ev.startDate = date
            ev.endDate   = date.addingTimeInterval(3600)
            ev.url       =  URL(string: "diploma://route/\(routeID.uuidString)")
            ev.calendar  = store.defaultCalendarForNewEvents

            do {
                try store.save(ev, span: .thisEvent)
                self.showInfo("Added to Calendar ✅")
            } catch {
                self.showInfo("Save failed: \(error.localizedDescription)")
            }
        }
    }

    private func showInfo(_ msg: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }


    private func addMarker(for wp: Waypoint) {                    // 🔄 без idx
        let m = GMSMarker(position: wp.coord)
        m.userData = wp.id                                        // ⬅︎ запоминаем UUID

        m.icon = GMSMarker.markerImage(
            with:  wp.id == waypointManager.startID ? .systemGreen :
                   wp.id == waypointManager.endID   ? .systemRed   :
                   wp.isPOI                         ? .systemPurple :
                                                       .systemBlue
        )
        m.title = wp.title
        m.map   = mapView
        markers.append(m)
    }

    private func runPOIMigrationIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "didFixPOI") else { return }

        // обновляем isPOI, не трогая UUID, а затем одним вызовом replaceAll
        let migrated = waypointManager.waypoints.map { wp -> Waypoint in
            var copy = wp
            if copy.title.lowercased().contains("(poi)") {
                copy.isPOI = true
            }
            return copy
        }

        // были ли изменения?
        if migrated != waypointManager.waypoints {
            waypointManager.replaceAll(with: migrated)   // ← один вызов, всё сохранит
        }

        UserDefaults.standard.set(true, forKey: "didFixPOI")
    }


    // MARK: –- SAVE
    func saveCurrentRoute() {
        guard !waypointManager.isEmpty else { return }

        // 1. проверяем, есть ли вообще POI-точки
        let hasPOI = waypointManager.waypoints.contains { $0.isPOI }

        // 2. если есть – спрашиваем, включать ли их
        if hasPOI {
            AlertManager.askIncludePOI(on: self) { [weak self] includePOI in
                self?.showTitleAlert(includePOI: includePOI)
            }
        } else {
            // 3. иначе сразу переходим к вводу названия
            showTitleAlert(includePOI: false)
        }
    }

    /// Запрос названия и фактическое сохранение
    private func showTitleAlert(includePOI: Bool) {
        AlertManager.askRouteTitle(on: self) { [weak self] title in
            guard let self else { return }
            
            var list = includePOI
            ? waypointManager.waypoints
            : waypointManager.waypoints.filter { !$0.isPOI }
            
            if waypointManager.startID == nil,
               let loc = currentUserLocation {
                
                humanAddress(for: loc) { [weak self] addr in
                    guard let self else { return }
                    list.insert(Waypoint(title: addr,
                                         placeId: "",
                                         coord : loc), at: 0)
                }
                
                do {
                    try CoreDataManager.shared.createRoute(title:   title,
                                                           waypoints: list,
                                                           polyline : encodedPolyline)
                    clearRoute()
                } catch {
                    print("CoreData save error:", error)
                }
            }
        }
    }



    
    // MARK: - Построение оптимизированного маршрута
    // MARK: - Построение оптимизированного маршрута
    private func buildOptimisedRoute() {

        // 1. нет точек — нечего строить
        guard !waypointManager.isEmpty else { return }

        // 2. запоминаем выбор пользователя до сортировки
        let oldStart = waypointManager.startID
        let oldEnd   = waypointManager.endID

        // 3. получаем оптимальный порядок
        let plan = RouteOptimizer.build(
            waypoints : waypointManager.waypoints,
            startID   : waypointManager.startID,
            endID     : waypointManager.endID,
            userOrigin: currentUserLocation
        )

        // 4. создаём локальную копию и гарантируем, что последняя точка не POI
        var ordered = plan.ordered
        if ordered.last?.isPOI == true,
           let idx = ordered.lastIndex(where: { !$0.isPOI }) {
            ordered.swapAt(idx, ordered.count - 1)
        }

        // 5. передаём в менеджер (одним вызовом, без прямой мутации)
        waypointManager.replaceAll(with: ordered)

        // 6. назначаем start / end
        waypointManager.startID = UserDefaults.standard.manuallySelectingFirstPoint ? oldStart : nil
        waypointManager.endID   = UserDefaults.standard.manuallySelectingLastPoint  ? oldEnd
                              : waypointManager.waypoints.last?.id        // ← точно не POI

        waypointTable.reloadData()

        // 7. формируем список для Directions: старт уже сидит в origin
        var apiWaypoints = waypointManager.waypoints
        if waypointManager.startID != nil { apiWaypoints.removeFirst() }

        // 8. запрашиваем Directions
        showSpinner()
        DirectionsService.buildRoute(
            apiKey     : googleApiKey,
            origin     : plan.origin,
            orderedWPs : apiWaypoints
        ) { [weak self] result in
            guard let self else { return }; self.hideSpinner()
            guard let res = result else { self.showDirectionsError(); return }

            self.drawRoute(
                polyline   : res.polyline,
                order      : Array(0..<self.waypointManager.waypoints.count),
                origin     : plan.origin,
                destination: self.waypointManager.waypoints.last!.coord
            )

            self.waypointManager.encodedPolyline = res.polyline
            self.waypointManager.saveMeta(duration: Int(res.duration),
                                          distance: Int(res.distance))

            self.travelTimeLabel.text  = "Time: \(Int(res.duration/60)) min"
            self.routeLengthLabel.text = Int(res.distance) < 1_000
                ? "Distance: \(Int(res.distance)) m"
                : "Distance: \(Int(res.distance/1000)) km"

            self.routeState = .routeBuilt
        }

        // 9. предлагаем добавить POI
        askAboutAddAdditionalPoint()
    }



    
    /// Рисует линию маршрута и расставляет маркеры
    private func drawRoute(polyline   : String,
                           order      : [Int],                 // порядок waypoints после оптимизации
                           origin     : CLLocationCoordinate2D,
                           destination: CLLocationCoordinate2D) {

        // ───── 1. линия  ────────────────────────────────────────────────────────────
        mapView.clear()

        if let path = GMSPath(fromEncodedPath: polyline) {
            encodedPolyline = polyline

            let pl = GMSPolyline(path: path)
            currentPolyline = pl
            waypointManager.encodedPolyline = polyline
            waypointManager.save()

            pl.strokeColor = .systemGreen
            pl.strokeWidth = 5
            pl.map = mapView
            
            // path — ваш GMSPath, pl — GMSPolyline
            if let path = GMSPath(fromEncodedPath: polyline) {
                   addDirectionArrows(path: path)
               }


            let bounds = GMSCoordinateBounds(path: path)
            mapView.animate(with: .fit(bounds, withPadding: 50))
        }
        

        // ───── 2. очищаем старые маркеры  ───────────────────────────────────────────
        markers.forEach { $0.map = nil }
        markers.removeAll()

        // ───── 3. старт-маркер, когда пользователь НЕ фиксировал startID ───────────
        if waypointManager.startID == nil {
            let s = GMSMarker(position: origin)
            s.icon  = GMSMarker.markerImage(with: .systemGreen)
            s.title = "Start"
            s.map   = mapView
            markers.append(s)
        }

        // ───── 4. переставляем waypoints по `order`  ───────────────────────────────
        reorderWaypoints(by: order)

        // ───── 5. создаём маркеры для каждой точки  ────────────────────────────────
        for (seq, wpIdx) in order.enumerated() {
            guard wpIdx >= 0 && wpIdx < waypointManager.waypoints.count else { continue }

            let wp     = waypointManager.waypoints[wpIdx]
            let marker = GMSMarker(position: wp.coord)
            marker.userData = wp.id                       // запоминаем UUID

            // цвет в зависимости от выбора пользователя
            let color: UIColor =
                (wp.id == waypointManager.startID) ? .systemGreen :
                (wp.id == waypointManager.endID)   ? .systemRed   :
                wp.isPOI                           ? .systemPurple :
                                                     .systemBlue

            marker.icon  = GMSMarker.markerImage(with: color)
            marker.title = "\(seq). \(wp.title)"
            marker.map   = mapView
            markers.append(marker)
        }
    }

    private func reorderWaypoints(by order: [Int]) {
        waypointManager.reorder(by: order)
        waypointTable.reloadData()
    }


    private func showDirectionsError() {
        AlertManager.showRouteErrorAlert(on: self)
    }

    private func drawPolyline(encoded: String) {
        mapView.clear()
        markers.forEach { $0.map = mapView }

        guard let path = GMSPath(fromEncodedPath: encoded) else { return }
        let pl = GMSPolyline(path: path)
        pl.strokeColor = .systemGreen
        pl.strokeWidth = 5
        pl.map = mapView

        let bounds = GMSCoordinateBounds(path: path)
        mapView.animate(with: .fit(bounds, withPadding: 40))
    }
    
    private func findPOIAndRebuild(for query: String) {
        
        guard let lastPolyline = currentPolyline?.path?.encodedPath() else { return }
        
        poiFinder.nearestPOI(to: lastPolyline, query: query) { [weak self] wp in
            guard
                let self, var poi = wp
            else { return }
            
            poi.isPOI = true
            self.waypointManager.add(poi)
            self.waypointManager.save()
            
            let marker = GMSMarker(position: poi.coord)
            marker.icon = GMSMarker.markerImage(with: .systemPurple)
            marker.map  = self.mapView
            self.markers.append(marker)
            
            self.waypointTable.reloadData()
            
            self.buildOptimisedRoute()
            
            self.askAboutAddAdditionalPoint()
        }
    }
    
    private func askAboutAddAdditionalPoint() {
        if UserDefaults.standard.shouldAskForAdditionalPOI {
            AlertManager.showShouldAddPOIConfirmation(on: self,
                onYes: { [weak self] in
                AlertManager.showPOIInputAlert(on: self!, onAdd: { query in
                        self?.findPOIAndRebuild(for: query)
                }, onCancel: {
                    UserDefaults.standard.shouldAskForAdditionalPOI = false
                })
                },
                onNo: { [weak self] in
                    UserDefaults.standard.shouldAskForAdditionalPOI = false
                }
            )
        }
    }
    
    private func humanAddress(for coord: CLLocationCoordinate2D,
                              completion: @escaping (String) -> Void) {
        GMSGeocoder().reverseGeocodeCoordinate(coord) { resp, _ in
            let addr = resp?.firstResult()?.lines?.joined(separator: ", ")
                      ?? "Current location"
            completion(addr)
        }
    }


}



extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location not authorized")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }
        self.currentUserLocation = userLocation.coordinate
        let camera = GMSCameraPosition.camera(
            withLatitude: userLocation.coordinate.latitude,
            longitude: userLocation.coordinate.longitude,
            zoom: 15
        )
        if routeState == .routeBuilt || routeState == .selectingPoints {
            rebuildMarkers()
        }
        mapView.animate(to: camera)
        hideSpinner()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        guard let popup = self.popupManager.popupView,
              let anchor = popupManager.popupAnchor else { return }

        let pt = mapView.projection.point(for: anchor)
        popup.center = CGPoint(x: pt.x,
                               y: pt.y - popup.bounds.height/2 - 12)
    }

}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTapAt coord: CLLocationCoordinate2D) {

        if searchField.isFirstResponder {
            searchField.resignFirstResponder()
            pointsTableView.isHidden = true
            return
        }

        clearPreviewMarker()

        let marker = GMSMarker(position: coord)
        marker.icon = GMSMarker.markerImage(with: .systemGray)
        marker.map  = mapView
        previewMarker = marker

        mapView.animate(toLocation: coord)

        GMSGeocoder().reverseGeocodeCoordinate(coord) { [weak self] resp, _ in
            guard let self = self else { return }
            let address = resp?.firstResult()?.lines?.joined(separator: ", ") ?? "Pinned location"

            DispatchQueue.main.async {
                self.popupManager.showPopup(title: address,
                                             address: nil,
                                             hours: nil,
                                             rating: nil,
                                             anchor: coord,
                                             onAdd: { [weak self] in
                    guard let self = self else { return }
                    marker.icon = GMSMarker.markerImage(with: .systemRed)
                    self.addWaypoint(title: address,
                                     placeId: "",
                                     coord: coord)
                    self.clearPreviewMarker()
                }, onCancel: { [weak self] in
                    guard let self = self else { return }
                    self.clearPreviewMarker()
                })
            }
        }
    }

    func mapView(_ mapView: GMSMapView,
                 didTapPOIWithPlaceID id: String,
                 name: String,
                 location: CLLocationCoordinate2D) {

        if searchField.isFirstResponder {
            searchField.resignFirstResponder()
            pointsTableView.isHidden = true
        }

        clearPreviewMarker()
        let marker = GMSMarker(position: location)
        marker.icon = GMSMarker.markerImage(with: .systemGray)
        marker.map  = mapView
        previewMarker = marker

        mapView.animate(toLocation: location)

        let fields: GMSPlaceField = [.formattedAddress, .rating, .openingHours]
        GMSPlacesClient.shared().fetchPlace(fromPlaceID: id,
                                            placeFields: fields,
                                            sessionToken: nil) { [weak self] place, _ in
            guard let self = self else { return }

            let address = place?.formattedAddress
            let rating  = place?.rating
            let hours   = place?.openingHours?.weekdayText?.first

            DispatchQueue.main.async {
                self.popupManager.showPopup(title: name,
                                             address: address,
                                             hours: hours,
                                             rating: rating.map(Double.init),
                                             anchor: location,
                                             onAdd: { [weak self] in
                    guard let self = self else { return }
                    marker.icon = GMSMarker.markerImage(with: .systemRed)
                    self.addWaypoint(title: name,
                                     placeId: id,
                                     coord: location)
                    self.clearPreviewMarker()
                }, onCancel: { [weak self] in
                    guard let self = self else { return }
                    self.clearPreviewMarker()
                })

            }
        }
    }
    
    private func addWaypoint(title: String,
                             placeId: String,
                             coord: CLLocationCoordinate2D) {

        let wp = Waypoint(title: title, placeId: placeId, coord: coord)
        waypointManager.add(wp)
        waypointTable.reloadData()
        routeState = .selectingPoints
    }
    
}


// MARK: - UISearchBarDelegate
extension MapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
            guard !text.isEmpty,
                  let loc = currentUserLocation else {
                searchResults.removeAll()
                pointsTableView.isHidden = true
                pointsTableView.reloadData()
                return
            }

            places.autocomplete(query: text, around: loc) { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .failure:
                        self.searchResults = []
                    case .success(let list):
                        self.searchResults = list
                    }
                    self.pointsTableView.reloadData()
                    self.pointsTableView.isHidden = self.searchResults.isEmpty
                }
            }
        }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MapViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pointsTableView {
            return searchResults.count
        } else if tableView == waypointTable {
            return waypointManager.waypoints.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == pointsTableView {
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PointTableViewCell",
                    for: indexPath
                  ) as? PointTableViewCell else {
                fatalError("Could not dequeue MyTripsHistoryTableViewCell")
            }
            cell.titleLabel.text = searchResults[indexPath.row].name
            return cell

        } else if tableView == waypointTable {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "WaypointTableViewCell",
                for: indexPath
            ) as? WaypointTableViewCell else {
                fatalError("Could not dequeue MyTripsHistoryTableViewCell")
            }
            let wp       = waypointManager.waypoints[indexPath.row]
            let isStart  = wp.id == waypointManager.startID        // 🔄
            let isEnd    = wp.id == waypointManager.endID          // 🔄

            cell.iconView.tintColor =  isStart ? .systemGreen
                                      : isEnd   ? .systemRed
                                      : wp.isPOI ? .systemPurple
                                      : .systemBlue

            cell.titleLabel.text = wp.title +
                                   (wp.isPOI ? "  (poi)" :
                                    isStart ? "  (start)" :
                                    isEnd   ? "  (end)"   : "")


            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == pointsTableView {
            let place = searchResults[indexPath.row]
            self.searchField.text = ""
            searchField.resignFirstResponder()
            pointsTableView.isHidden = true

            places.coordinates(for: place.placeId) { [weak self] result in
                guard let self else { return }

                DispatchQueue.main.async {
                    switch result {

                    case .failure(let error):
                        AlertManager.showError(error, on: self)

                    case .success(let coord):
                        self.handlePickedCoordinate(coord,
                                                    title:    place.name,
                                                    placeId:  place.placeId)
                    }
                }
            }
            return
        }
        let wp = waypointManager.waypoints[indexPath.row]
        let isStart = wp.id == waypointManager.startID
        let isEnd   = wp.id == waypointManager.endID

            let alert = UIAlertController(
                title: "Waypoint",
                message: waypointManager.waypoints[indexPath.row].title,
                preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.routeState = self.waypointManager.isEmpty ? .idle : .selectingPoints
                self.removeWaypoint(at: indexPath.row)
            })

            alert.addAction(UIAlertAction(
                title: isStart ? "Remove start status" : "Make start",
                   style: .default) { _ in

                       if isStart {
                           // ───────── пользователь снял старт ─────────
                           self.waypointManager.startID = nil
                           UserDefaults.standard.manuallySelectingFirstPoint = false
                       } else {
                           // ───────── пользователь назначил старт ─────
                           self.waypointManager.startID = wp.id
                           UserDefaults.standard.manuallySelectingFirstPoint = true
                           // если тот же wp был финишем – убираем
                           if self.waypointManager.startID == self.waypointManager.endID {
                               self.waypointManager.endID = nil
                           }
                       }

                       self.refreshMarkers()
                       self.waypointTable.reloadData()
                       self.waypointManager.save()
            })
            if !wp.isPOI {
                alert.addAction(UIAlertAction(
                    title: isEnd ? "Remove end status" : "Make end",
                    style: .default) { _ in
                        self.waypointManager.endID = isEnd ? nil : wp.id      // 🔄
                        UserDefaults.standard.manuallySelectingLastPoint = !isEnd
                        if self.waypointManager.endID == self.waypointManager.startID {
                            self.waypointManager.startID = nil
                        }
                        self.refreshMarkers()
                        self.waypointTable.reloadData()
                        self.waypointManager.save()
                        self.routeState = self.waypointManager.isEmpty ? .idle : .selectingPoints
                })
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
    }
    
    private func removeWaypoint(at idx: Int) {
        waypointManager.remove(at: idx)
        waypointTable.reloadData()
        refreshMarkers()
        waypointManager.save()
        if waypointManager.isEmpty { routeState = .idle }
    }

    
    private func refreshMarkers() {
        for marker in markers {
            guard let id = marker.userData as? UUID else { continue }
            let wp = waypointManager.waypoints.first { $0.id == id }
            let color: UIColor =
                id == waypointManager.startID ? .systemGreen :
                id == waypointManager.endID   ? .systemRed   :
                wp?.isPOI == true             ? .systemPurple :
                                                .systemBlue
            marker.icon = GMSMarker.markerImage(with: color)
        }
    }

    
    private func handlePickedCoordinate(_ coord: CLLocationCoordinate2D,
                                        title:   String,
                                        placeId: String)
    {
        clearPreviewMarker()
        let preview = GMSMarker(position: coord)
        preview.icon = GMSMarker.markerImage(with: .systemGray)
        preview.map  = mapView
        previewMarker = preview

        mapView.animate(toLocation: coord)

        self.popupManager.showPopup(title: title,
                                     address: nil,
                                     hours: nil,
                                     rating: nil,
                                     anchor: coord,
                                     onAdd: { [weak self] in
            guard let self else { return }

            preview.icon = GMSMarker.markerImage(with: .systemRed)
            self.addWaypoint(title: title, placeId: placeId, coord: coord)
            self.clearPreviewMarker()
        }, onCancel: { [weak self] in
            guard let self else { return }
            
            self.clearPreviewMarker()
        })

    }


}

extension MapViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension MapViewController {

    /// Расставляет стрелки вдоль path каждые `step` метров
    func addDirectionArrows(path: GMSPath,
                             step meters: CLLocationDistance = 120) {

        // 1. убираем старые «arrow»-маркеры
        markers.removeAll { m in
            (m.userData as? String) == "arrow"
        }

        // 2. обходим сегменты polyline
        var pending = meters
        for i in 1..<path.count() {
            let a = path.coordinate(at: i-1)
            let b = path.coordinate(at: i)
            let segLen = GMSGeometryDistance(a, b)

            var distOnSeg = pending
            while distOnSeg <= segLen {
                // точка на сегменте
                let ratio = distOnSeg / segLen
                let lat = a.latitude  + (b.latitude  - a.latitude)  * ratio
                let lng = a.longitude + (b.longitude - a.longitude) * ratio
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lng)

                // угол сегмента
                let heading = GMSGeometryHeading(a, b)

                // маркер-стрелка
                let m = GMSMarker(position: coord)
                m.icon      = arrowImage
                m.rotation  = heading
                m.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                m.isFlat      = true
                m.userData  = "arrow"        // чтобы потом было легко удалить
                m.map       = mapView
                markers.append(m)

                distOnSeg += meters
            }
            pending = distOnSeg - segLen
        }
    }
}

