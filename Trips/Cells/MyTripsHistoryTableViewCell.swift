//
//  MyTripsHistoryTableViewCell.swift
//  LoadRex
//
//  Created by Olesia Skydan on 10.04.2025.
//

import UIKit

protocol MyTripsHistoryCellDelegate: AnyObject {
    func didTapDetails(for route: RouteModel)
    func didTapEdit    (for route: RouteModel)
    func didTapMap     (for route: RouteModel)
}

final class MyTripsHistoryTableViewCell: UITableViewCell {

    @IBOutlet private weak var cellContentView: UIView!
    @IBOutlet private weak var routeName : UILabel!
    @IBOutlet private weak var routeDate : UILabel!

    weak var delegate : MyTripsHistoryCellDelegate?
    private var model : RouteModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cellContentView.layer.cornerRadius = 12
        cellContentView.clipsToBounds      = true
    }

    func configure(with route: RouteModel) {
        self.model = route
        routeName.text = route.title
        let df = DateFormatter(); df.dateStyle = .medium; df.timeStyle = .short
        routeDate.text = df.string(from: route.createdAt ?? .now)
    }

    @IBAction private func detailsTapped(_ sender: UIButton) {
        delegate?.didTapDetails(for: model)
    }

//    @IBAction private func editTapped(_ sender: UIButton) {
//        delegate?.didTapEdit(for: model)
//    }
    @IBAction func mapButtonTapped(_ sender: Any) {
        delegate?.didTapMap(for: model)
    }
}
