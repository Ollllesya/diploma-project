//
//  MyTripsHistoryTableViewCell.swift
//  LoadRex
//
//  Created by Olesia Skydan on 10.04.2025.
//

import UIKit

final class MyTripDetailsTableViewCell: UITableViewCell {

    @IBOutlet private weak var cellContentView: UIView!
    @IBOutlet weak var routeName : UILabel!
    @IBOutlet private weak var routeDate : UILabel!
    @IBOutlet weak var pointStatus: UILabel!
    private var model : RouteModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cellContentView.layer.cornerRadius = 12
        cellContentView.clipsToBounds      = true
    }

    func configure(with wp: Waypoint,
                       index: Int,
                       total: Int,
                       created: Date? = nil)
    {
            routeName.text = wp.title

            var text  = ""
            var color = UIColor.label

            if wp.isPOI {
                text  = "POI"
                color = .systemPurple
            } else if index == 0 {             
                text  = "Start"
                color = .systemGreen
            } else if index == total - 1 {
                text  = "End"
                color = .systemRed
            } else {
                text  = "Via"
                color = .systemBlue
            }
            pointStatus.text      = text
            pointStatus.textColor = color
        }

    @IBAction private func detailsTapped(_ sender: UIButton) {

    }

    @IBAction private func editTapped(_ sender: UIButton) {
    }
}
