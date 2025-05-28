//
//  UserDefaults+Extension.swift
//  Diploma
//
//  Created by Olesia Skydan on 30.04.2025.
//

import Foundation
import UIKit

enum POIPreferenceKey {
    static let shouldAskForPOI = "shouldAskForAdditionalPOI"
    static let manuallySelectingLastPoint = "manuallySelectingLastPoint"
    static let manuallySelectingFirstPoint = "manuallySelectingFirstPoint"
}

extension UserDefaults {
    var shouldAskForAdditionalPOI: Bool {
        get { bool(forKey: POIPreferenceKey.shouldAskForPOI) }
        set { set(newValue, forKey: POIPreferenceKey.shouldAskForPOI) }
    }
    
    var manuallySelectingLastPoint: Bool {
        get { bool(forKey: POIPreferenceKey.manuallySelectingLastPoint) }
        set { set(newValue, forKey: POIPreferenceKey.manuallySelectingLastPoint) }
    }

    var manuallySelectingFirstPoint: Bool {
        get { bool(forKey: POIPreferenceKey.manuallySelectingFirstPoint) }
        set { set(newValue, forKey: POIPreferenceKey.manuallySelectingFirstPoint) }
    }
}
