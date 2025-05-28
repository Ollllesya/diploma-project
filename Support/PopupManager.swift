//
//  PopupManager.swift
//  Diploma
//
//  Created by Olesia Skydan on 29.04.2025.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Alamofire
import SwiftyJSON

final class PopupManager {
    private weak var view: UIView?
    private weak var mapView: GMSMapView?
    var popupView: PinPopupView?
    var popupAnchor: CLLocationCoordinate2D?
    
    init(view: UIView, mapView: GMSMapView) {
        self.view = view
        self.mapView = mapView
    }
    
    func showPopup(title: String,
                   address: String?,
                   hours: String?,
                   rating: Double?,
                   anchor: CLLocationCoordinate2D,
                   onAdd: @escaping () -> Void,
                   onCancel: @escaping () -> Void) {

        popupView?.removeFromSuperview()

        let popup = PinPopupView(title: title,
                                 address: address,
                                 hours: hours,
                                 rating: rating)

        popup.onAdd    = { onAdd();  self.hidePopup() }
        popup.onCancel = { onCancel();  self.hidePopup() }
        popup.alpha = 0
        view?.addSubview(popup)
        popupView   = popup
        popupAnchor = anchor

        guard let mapView = mapView else { return }
        let pt = mapView.projection.point(for: anchor)
        popup.center = CGPoint(x: pt.x, y: pt.y)
        view?.layoutIfNeeded()

        let finalCenter = CGPoint(x: pt.x,
                                  y: pt.y - popup.bounds.height/2 - 12)

        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: [.curveEaseOut]) {
            popup.center = finalCenter
            popup.alpha = 1
        }
    }
    
    func hidePopup() {
        guard let popup = popupView else { return }
        UIView.animate(withDuration: 0.2, animations: {
            popup.alpha = 0
        }) { _ in
            popup.removeFromSuperview()
            self.popupView   = nil
            self.popupAnchor = nil
        }
    }
    
    func movePopupOnMapChange() {
        guard let popup = popupView, let anchor = popupAnchor, let mapView = mapView else { return }
        let pt = mapView.projection.point(for: anchor)
        popup.center = CGPoint(x: pt.x, y: pt.y - popup.bounds.height/2 - 12)
    }
}
