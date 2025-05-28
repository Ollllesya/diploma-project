//
//  POIFinder.swift
//  Diploma
//
//  Created by Olesia Skydan on 29.04.2025.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON
import GoogleMaps

final class POIFinder {

    private let apiKey: String
    init(apiKey: String) { self.apiKey = apiKey }

    /// Возвращает ближайшее место `query` к polyline маршрута
    func nearestPOI(to encodedPolyline: String,
                    query: String,
                    completion: @escaping (Waypoint?) -> Void) {

        // 1. получаем декодированный путь
        guard let path = GMSPath(fromEncodedPath: encodedPolyline) else {
            completion(nil); return
        }

        // 2. рассчитываем центр + «радиус» маршрута
        let bounds = GMSCoordinateBounds(path: path)
        let center = CLLocationCoordinate2D(
            latitude : (bounds.northEast.latitude  + bounds.southWest.latitude)/2,
            longitude: (bounds.northEast.longitude + bounds.southWest.longitude)/2)

        // 3. Places Nearby Search (rankby=distance)
        let url = """
        https://maps.googleapis.com/maps/api/place/nearbysearch/json?\
        location=\(center.latitude),\(center.longitude)&\
        rankby=distance&\
        keyword=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&\
        key=\(apiKey)
        """

        AF.request(url).responseData { resp in
            guard
                let data = try? resp.result.get(),
                let json = try? JSON(data: data),
                let first = json["results"].arrayValue.first
            else { completion(nil); return }

            let placeId = first["place_id"].stringValue
            let name    = first["name"].stringValue
            let loc     = first["geometry"]["location"]
            let coord   = CLLocationCoordinate2D(latitude: loc["lat"].doubleValue,
                                                 longitude: loc["lng"].doubleValue)

            completion(Waypoint(title: name,
                                placeId: placeId,
                                coord: coord,
                                isPOI: true))
        }
    }
}
