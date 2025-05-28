//
//  PointTableViewCell.swift
//  Diploma
//
//  Created by Olesia Skydan on 24.04.2025.
//

import UIKit

final class PointTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        iconView.image = UIImage(systemName: "mappin.and.ellipse")
        iconView.tintColor = .systemBlue

        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let alpha: CGFloat = highlighted ? 0.6 : 1
        UIView.animate(withDuration: 0.15) { self.contentView.alpha = alpha }
    }
}
