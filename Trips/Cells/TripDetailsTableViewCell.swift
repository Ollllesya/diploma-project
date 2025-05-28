//
//  TripDetailsTableViewCell.swift
//  Diploma
//
//  Created by Олеся Скидан on 02.05.2025.
//

import UIKit

final class TripDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContentView.layer.cornerRadius = 12
        cellContentView.layer.masksToBounds = true

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
