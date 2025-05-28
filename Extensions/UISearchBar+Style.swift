//
//  UISearchBar+Style.swift
//  Diploma
//
//  Created by Olesia Skydan on 09.04.2025.
//

import UIKit


extension UISearchBar {
    func applyRoundedStyle(accentColor: UIColor = .systemBlue,
                           blur: Bool = true) {

        searchBarStyle = .minimal
        backgroundImage = UIImage()

        let textField = self.searchTextField

        textField.font = .systemFont(ofSize: 15, weight: .regular)
        textField.textColor = .label
        textField.tintColor = accentColor
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search for a place…",
            attributes: [.foregroundColor: UIColor.secondaryLabel ])

        let bgView: UIView
        if blur {
            let effect = UIBlurEffect(style: .systemMaterial)
            bgView = UIVisualEffectView(effect: effect)
        } else {
            bgView = UIView()
            bgView.backgroundColor = UIColor.secondarySystemBackground
        }
        bgView.isUserInteractionEnabled = false
        bgView.layer.cornerRadius = 14
        bgView.layer.masksToBounds = true

        if let tfSuperview = textField.superview {
            tfSuperview.insertSubview(bgView, at: 0)
            bgView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                bgView.leadingAnchor.constraint(equalTo: tfSuperview.leadingAnchor),
                bgView.trailingAnchor.constraint(equalTo: tfSuperview.trailingAnchor),
                bgView.topAnchor.constraint(equalTo: tfSuperview.topAnchor),
                bgView.bottomAnchor.constraint(equalTo: tfSuperview.bottomAnchor)
            ])
        }

        if let imgView = textField.leftView as? UIImageView {
            imgView.image = UIImage(systemName: "magnifyingglass")
            imgView.tintColor = .secondaryLabel
        }

        self.layer.cornerRadius = 14
        self.layer.masksToBounds = true

        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowOffset  = .init(width: 0, height: 1)
        self.layer.shadowRadius  = 3
    }
}
