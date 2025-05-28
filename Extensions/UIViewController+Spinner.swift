//
//  UIViewController+Spinner.swift
//  Diploma
//
//  Created by Olesia Skydan on 30.04.2025.
//

import UIKit

private var spinnerViewKey: UInt8 = 0

extension UIViewController {

    private var spinner: UIActivityIndicatorView {
        // «ленивое» создание с запоминанием через Associated Objects
        get {
            if let existing = objc_getAssociatedObject(self, &spinnerViewKey) as? UIActivityIndicatorView {
                return existing
            }
            let s = UIActivityIndicatorView(style: .large)
            s.hidesWhenStopped = true          // ⬅️ важный флаг, чтобы не убирать вручную
            s.color = .systemBlue              // контрастный цвет (можно любой)
            objc_setAssociatedObject(self, &spinnerViewKey, s, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return s
        }
    }

    /// Показываем индикатор по центру
    func showSpinner() {
        let s = spinner
        guard s.superview == nil else {        // уже на экране
            s.startAnimating()
            return
        }

        view.addSubview(s)
        s.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            s.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            s.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        s.startAnimating()
        view.isUserInteractionEnabled = false  // опционально блокируем тап-ы
    }

    /// Скрываем индикатор
    func hideSpinner() {
        spinner.stopAnimating()                // благодаря hidesWhenStopped он сам спрячется
        view.isUserInteractionEnabled = true
    }
}
