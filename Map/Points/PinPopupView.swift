//
//  PinPopupView.swift
//  Diploma
//
//  Created by Olesia Skydan on 25.04.2025.
//

import UIKit

final class PinPopupView: UIView {

    // MARK: subviews
    private let titleLabel   = UILabel()
    private let addressLabel = UILabel()
    private let hoursLabel   = UILabel()
    private let ratingLabel  = UILabel()
    private let addButton    = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    // callbacks
    var onAdd:    (() -> Void)?
    var onCancel: (() -> Void)?

    // MARK: init
    init(title: String,
         address: String?,
         hours: String?,
         rating: Double?) {

        super.init(frame: .zero)
        configureUI()

        titleLabel.text   = title
        addressLabel.text = address
        hoursLabel.text   = hours
        ratingLabel.text  = rating.flatMap { String(format: "★ %.1f", $0) }

        addressLabel.isHidden = address == nil
        hoursLabel.isHidden   = hours   == nil
        ratingLabel.isHidden  = rating  == nil
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: private
    private func configureUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.secondarySystemBackground
        layer.cornerRadius = 16
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset  = .init(width: 0, height: 3)
        layer.shadowRadius  = 6

        // label styles
        [titleLabel, addressLabel, hoursLabel, ratingLabel].forEach {
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 15)
            $0.textColor = .label
        }
        titleLabel.font = .boldSystemFont(ofSize: 16)
        ratingLabel.textColor = .systemOrange

        // buttons
        addButton.setTitle("Add", for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        [addButton, cancelButton].forEach {
            $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            $0.backgroundColor  = UIColor.systemBlue.withAlphaComponent(0.12)
            $0.layer.cornerRadius = 8
            $0.heightAnchor.constraint(equalToConstant: 34).isActive = true
        }
        addButton.addAction(UIAction { [weak self] _ in self?.onAdd?() },    for: .touchUpInside)
        cancelButton.addAction(UIAction { [weak self] _ in self?.onCancel?() }, for: .touchUpInside)

        let btnStack = UIStackView(arrangedSubviews: [addButton, cancelButton])
        btnStack.axis = .horizontal
        btnStack.spacing = 12
        btnStack.distribution = .fillEqually

        let vStack = UIStackView(arrangedSubviews: [
            titleLabel, addressLabel, hoursLabel, ratingLabel, btnStack
        ])
        vStack.axis = .vertical
        vStack.spacing = 8
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.setCustomSpacing(14, after: ratingLabel)

        addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            widthAnchor.constraint(lessThanOrEqualToConstant: 280)        // max-ширина
        ])
    }
}
