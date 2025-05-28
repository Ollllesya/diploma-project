//
//  DirectionsService.swift
//  Diploma
//
//  Created by Olesia Skydan on 28.04.2025.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

enum DirectionsService {

    struct Result {
        let polyline: String
        let duration: TimeInterval   // sec
        let distance: Double         // m
    }

    static func buildRoute(
        apiKey      : String,
        origin      : CLLocationCoordinate2D,
        orderedWPs  : [Waypoint],
        completion  : @escaping (Result?)->Void)
    {
        guard let last = orderedWPs.last else { completion(nil); return }

        let mid   = orderedWPs.dropLast()                // без фінішу
            .map { "\($0.coord.latitude),\($0.coord.longitude)" }
            .joined(separator: "|")

        var comps = URLComponents(string:
          "https://maps.googleapis.com/maps/api/directions/json")!
        comps.queryItems = [
            .init(name: "origin",
                  value: "\(origin.latitude),\(origin.longitude)"),
            .init(name: "destination",
                  value: "\(last.coord.latitude),\(last.coord.longitude)"),
            .init(name: "mode", value: "driving"),
            .init(name: "key",  value: apiKey)
        ]
        if !mid.isEmpty {
            comps.queryItems!.append(.init(name: "waypoints", value: mid)) 
        }

        AF.request(comps).responseData { resp in
            guard let data = try? resp.result.get(),
                  let json = try? JSON(data: data),
                  json["status"].stringValue == "OK",
                  let route = json["routes"].array?.first else {
                completion(nil); return
            }

            let legSum = route["legs"].arrayValue
            let totalTime = legSum.reduce(0.0) { $0 + $1["duration"]["value"].doubleValue }
            let totalDist = legSum.reduce(0.0) { $0 + $1["distance"]["value"].doubleValue }

            completion(Result(polyline: route["overview_polyline"]["points"].stringValue,
                              duration: totalTime,
                              distance: totalDist))
        }
    }
}
