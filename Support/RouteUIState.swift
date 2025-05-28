//
//  RouteUIState.swift
//  Diploma
//
//  Created by Olesia Skydan on 30.04.2025.
//

import UIKit

enum RouteUIState {
    static func apply(_ state: RouteState,
                      buildRouteButton: UIButton,
                      addToFavoritesButton: UIButton,
                      clearTheRouteButton: UIButton,
                      planARouteButton: UIButton,
                      anyPointsLabel: UILabel,
                      travelTimeLabel: UILabel,
                      routeLengthLabel: UILabel,
                      bottomStackView: UIStackView) {

        switch state {
        case .idle:
            buildRouteButton.isHidden = false
            addToFavoritesButton.isHidden = true
            clearTheRouteButton.isHidden = true
            planARouteButton.isHidden = true
            anyPointsLabel.text = "You don't have any points"
            travelTimeLabel.isHidden = true
            routeLengthLabel.isHidden = true
            anyPointsLabel.textAlignment = .center
            anyPointsLabel.isHidden = false
            bottomStackView.distribution = .fillEqually

        case .selectingPoints:
            buildRouteButton.isHidden = false
            addToFavoritesButton.isHidden = true
            clearTheRouteButton.isHidden = false
            planARouteButton.isHidden = true
            anyPointsLabel.isHidden = true
            travelTimeLabel.isHidden = true
            routeLengthLabel.isHidden = true
            travelTimeLabel.text = "Time: —"
            routeLengthLabel.text = "Distance: —"
            bottomStackView.distribution = .fillProportionally

        case .routeBuilt:
            addToFavoritesButton.isHidden = false
            clearTheRouteButton.isHidden = false
            planARouteButton.isHidden = false
            travelTimeLabel.isHidden = false
            routeLengthLabel.isHidden = false
            anyPointsLabel.isHidden = true
            
        case .fromCalendar:
            buildRouteButton.isHidden = true
            addToFavoritesButton.isHidden = false
            clearTheRouteButton.isHidden = false
            planARouteButton.isHidden = false
            travelTimeLabel.isHidden = false
            routeLengthLabel.isHidden = false
            anyPointsLabel.isHidden = true
        }
    }
}
