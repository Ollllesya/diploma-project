//
//  TripDetailsViewController.swift
//  Diploma
//
//  Created by Olesia Skydan on 01.05.2025.
//


import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import SwiftyJSON

final class MapTripDetailsViewController: UIViewController {

    @IBOutlet private weak var mapView: GMSMapView!


    private var route : RouteModel!

    // MARK: - instantiation helper
    static func instantiate(with route: RouteModel) -> MapTripDetailsViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
                    identifier: "MapTripDetailsViewController") as! MapTripDetailsViewController
        vc.route = route
        return vc
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = route.title
        configureMap()
        drawRoute()
    }

    // MARK: - Private helpers
    private func configureMap() {
        mapView.isMyLocationEnabled        = true
        mapView.settings.myLocationButton  = true
        mapView.settings.compassButton     = true
    }
    

    private func drawRoute() {

        let wps = route.orderedWaypoints


        for (idx, wp) in wps.enumerated() {
            let m = GMSMarker(position: wp.coord)
            m.icon = GMSMarker.markerImage(
                          with: idx == 0              ? .systemGreen :  
                                idx == wps.count - 1  ? .systemRed   :
                                wp.isPOI              ? .systemPurple :
                                                      .systemBlue)
            m.title = wp.title
            m.map   = mapView
        }
        
        if let encoded = route.polyline,
           let path    = GMSPath(fromEncodedPath: encoded) {
            let pl = GMSPolyline(path: path)
            pl.strokeColor = .systemGreen
            pl.strokeWidth = 5
            pl.map = mapView
            mapView.animate(with: .fit(GMSCoordinateBounds(path: path), withPadding: 40))
        } else {
            buildPolylineViaDirections(for: wps)
        }
    }

    private func buildPolylineViaDirections(for wps: [Waypoint]) {

        guard wps.count > 1 else { return }

        DirectionsService.buildRoute(
            apiKey     : "<YOUR-API-KEY>",
            origin     : wps.first!.coord,
            orderedWPs : Array(wps.dropFirst())) { [weak self] result in
                guard
                    let self,
                    let res = result,
                    let path = GMSPath(fromEncodedPath: res.polyline)
                else { return }

                let pl = GMSPolyline(path: path)
                pl.strokeColor = .systemGreen
                pl.strokeWidth = 5
                pl.map = self.mapView
                self.mapView.animate(with: .fit(GMSCoordinateBounds(path: path),
                                                withPadding: 40))
        }
    }
}
