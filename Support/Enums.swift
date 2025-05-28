//
//  RouteState.swift
//  Diploma
//
//  Created by Olesia Skydan on 25.04.2025.
//


import Foundation
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import SwiftyJSON

enum RouteState {
    case idle
    case selectingPoints
    case routeBuilt
    case fromCalendar
}
