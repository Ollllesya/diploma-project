//
//  MapСonfigurator.swift
//  Diploma
//
//  Created by Olesia Skydan on 30.04.2025.
//

import UIKit

class MapStyleManager {
    
    static func styleBottomMenu(view: UIView, waypointTable: UITableView) {
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        
        waypointTable.backgroundColor = .clear
        waypointTable.separatorColor = .separator
    }
    
    static func stylePointsTable(_ tableView: UITableView) {
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 14
        tableView.layer.masksToBounds = true
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.1
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowRadius = 6
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    }
}
