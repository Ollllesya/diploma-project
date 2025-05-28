//
//  DeepLinkRouter.swift
//  Diploma
//
//  Created by Olesia Skydan on 04.05.2025.
//

import UIKit

final class DeepLinkRouter {

    static let shared = DeepLinkRouter()        // singleton
    private init() {}

    func handle(_ url: URL) {
        // diploma://route/<uuid>
        guard url.scheme == "diploma",
              url.host   == "route",
              let id     = UUID(uuidString: url.lastPathComponent),
              let route  = CoreDataManager.shared.route(id: id)
        else { return }

        // --- находим MapViewController (он на 0-й вкладке TabBar) ---
        guard
            let tab = UIApplication.shared.windows.first?.rootViewController
                    as? UITabBarController,
            let nav = tab.viewControllers?.first as? UINavigationController,
            let mapVC = nav.viewControllers.first as? MapViewController
        else { return }

        // --- если пользователь что-то строил вручную — очищаем ---
        mapVC.clearRoute()

        // --- загружаем сохранённый маршрут ---
        mapVC.showRoute(route)

        // и переключаемся на вкладку «Карта»
        tab.selectedIndex = 0
    }
}
