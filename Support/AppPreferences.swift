//
//  AppPreferences.swift
//  Diploma
//
//  Created by Olesia Skydan on 30.04.2025.
//

import Foundation

final class AppPreferences {
    private enum Keys {
        static let shouldAskForAdditionalPOI = "shouldAskForAdditionalPOI_preference"
    }

    static var shouldAskForAdditionalPOI: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.shouldAskForAdditionalPOI)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.shouldAskForAdditionalPOI)
        }
    }
}
