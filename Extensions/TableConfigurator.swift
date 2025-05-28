//
//  TableConfigurator.swift
//  Diploma
//
//  Created by Olesia Skydan on 30.04.2025.
//

import UIKit

enum TableType {
    case waypoints
    case searchPoints
}

class TableConfigurator {
    static func configure(
        tableView: UITableView,
        type: TableType,
        delegate: UITableViewDelegate,
        dataSource: UITableViewDataSource
    ) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension

        switch type {
        case .waypoints:
            tableView.register(
                UINib(nibName: "WaypointTableViewCell", bundle: nil),
                forCellReuseIdentifier: "WaypointTableViewCell"
            )
        case .searchPoints:
            tableView.register(
                UINib(nibName: "PointTableViewCell", bundle: nil),
                forCellReuseIdentifier: "PointTableViewCell"
            )
            tableView.isHidden = true
        }
    }
}
