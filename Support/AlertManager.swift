//
//  AlertManager.swift
//  Diploma
//
//  Created by Olesia Skydan on 28.04.2025.
//

import UIKit

final class AlertManager {

    static func showNoPointsAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "No Points",
            message: "Please add some points first to build a route.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }

    static func showRouteErrorAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Route error",
            message: "Google Directions could not build a route.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }

    static func showError(_ error: Error, on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
    
    static func showShouldAddPOIConfirmation(on vc: UIViewController,
                                             onYes: @escaping () -> Void,
                                             onNo: @escaping () -> Void) {
        let alert = UIAlertController(title: "Would you like to add a point of interest?",
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "No", style: .cancel) { _ in onNo() })
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in onYes() })

        vc.present(alert, animated: true)
    }

    
    static func showPOIInputAlert(on viewController: UIViewController,
                                   onAdd: @escaping (String) -> Void,
                                   onCancel: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Add a stop to visit?",
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addTextField { tf in
            tf.placeholder = "e.g. pharmacy, McDonalds…"
            tf.autocapitalizationType = .none
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            onCancel?()
        })

        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard
                let query = alert.textFields?.first?.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                !query.isEmpty
            else { return }
            onAdd(query)
        })

        viewController.present(alert, animated: true)
    }
    
    static func askIncludePOI(on vc: UIViewController,
                                 completion: @escaping (Bool) -> Void) {

           let alert = UIAlertController(
               title: "Save POI stops?",
               message: "Add intermediate POI stops to the route you’re saving?",
               preferredStyle: .alert)

           alert.addAction(.init(title: "With POI",    style: .default) { _ in completion(true)  })
           alert.addAction(.init(title: "Without POI", style: .default) { _ in completion(false) })
           alert.addAction(.init(title: "Cancel",      style: .cancel))

           vc.present(alert, animated: true)
       }

       static func askRouteTitle(on vc: UIViewController,
                                 completion: @escaping (String) -> Void) {

           let alert = UIAlertController(title: "Save route",
                                         message: "Enter a title",
                                         preferredStyle: .alert)
           alert.addTextField { $0.placeholder = "My trip…" }

           alert.addAction(.init(title: "Cancel", style: .cancel))
           alert.addAction(.init(title: "Save",   style: .default) { _ in
               let t = alert.textFields?.first?.text?
                           .trimmingCharacters(in: .whitespacesAndNewlines)
                       ?? "Route"
               completion(t)
           })

           vc.present(alert, animated: true)
       }
}
