//
//  ButtonStyler.swift
//  Diploma
//
//  Created by Olesia Skydan on 30.04.2025.
//

import UIKit

enum ButtonType {
    case filledYellow
}

class ButtonStyler {
    static func applyStyle(_ type: ButtonType, to button: UIButton) {
        switch type {
        case .filledYellow:
            guard let yellow = UIColor(named: "yellowCustomColor") else { return }
            var config = button.configuration ?? .filled()
            config.baseBackgroundColor = yellow
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            button.configuration = config
            button.layer.cornerRadius = button.bounds.height / 4
            button.clipsToBounds = true
        }
    }
}
