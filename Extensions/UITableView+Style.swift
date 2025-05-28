//
//  UITableView+Style.swift
//  Diploma
//
//  Created by Olesia Skidan on 09.04.2025.
//

import UIKit

extension UITableView {
    func applyCustomCardStyle(cornerRadius: CGFloat = 12) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 6
        self.layer.masksToBounds = false

        self.backgroundColor = .secondarySystemBackground
        self.separatorStyle = .singleLine
        self.separatorColor = UIColor.systemGray4
        self.tableFooterView = UIView()
    }
}
