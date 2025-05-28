//
//  UIStyler.swift
//  Diploma
//
//  Created by Олеся Скидан on 28.04.2025.
//

import UIKit
enum UIStyler {
    static func makeCapsule(_ btn: UIButton, color: UIColor) {
        var cfg = btn.configuration ?? .filled()
        cfg.baseBackgroundColor = color
        cfg.baseForegroundColor = .white
        cfg.cornerStyle         = .capsule
        btn.configuration       = cfg
        btn.layer.cornerRadius  = btn.bounds.height/4
        btn.clipsToBounds       = true
    }
}
