//
//  DateSheetVC.swift
//  Diploma
//
//  Created by Olesia Skydan on 10.05.2025.
//


import UIKit

final class DateSheetVC: UIViewController {

    private let onAdd : (Date) -> Void
    private let picker = UIDatePicker()

    // MARK: init
    init(initial: Date = Date(),
         onAdd:   @escaping (Date) -> Void) {
        self.onAdd = onAdd
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
        if let sh = sheetPresentationController {        // iOS 15+
            sh.detents = [.medium()]                     // высота ≈ 50 % экрана
            sh.prefersGrabberVisible = true
        }
        picker.date = initial
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: UI
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // ───── 1. UIDatePicker ──────────────────────────────
        picker.datePickerMode = .dateAndTime
        picker.minuteInterval = 5
        // колёса на iPhone, inline-календарь на iPad (на большом экране удобнее)
        if UIDevice.current.userInterfaceIdiom == .phone {
            picker.preferredDatePickerStyle = .wheels
        } else {
            picker.preferredDatePickerStyle = .inline
        }

        // ───── 2. Кнопки ────────────────────────────────────
        let cancel = makeButton("Cancel") { [weak self] in
            self?.dismiss(animated: true)
        }
        let add = makeButton("Add") { [weak self] in
            guard let self else { return }
            self.onAdd(self.picker.date)
            self.dismiss(animated: true)
        }

        let btnStack = UIStackView(arrangedSubviews: [cancel, add])
        btnStack.axis         = .horizontal
        btnStack.distribution = .fillEqually
        btnStack.spacing      = 12

        // ───── 3. Layout ───────────────────────────────────
        [picker, btnStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            picker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            picker.heightAnchor.constraint(equalToConstant:
                    UIDevice.current.userInterfaceIdiom == .phone ? 260 : 320),

            btnStack.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 20),
            btnStack.leadingAnchor.constraint(equalTo: picker.leadingAnchor),
            btnStack.trailingAnchor.constraint(equalTo: picker.trailingAnchor),
            btnStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -16),
            btnStack.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func makeButton(_ title: String,
                            action: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight:
                     title == "Add" ? .semibold : .regular)
        b.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return b
    }
}
