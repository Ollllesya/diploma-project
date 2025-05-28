//
//  SceneDelegate.swift
//  Diploma
//
//  Created by Олеся Скидан on 17.02.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func scene(_ scene: UIScene,
               openURLContexts ctx: Set<UIOpenURLContext>) {

        guard let url = ctx.first?.url,
              url.scheme == "diploma",
              url.host   == "route",
              let id     = UUID(uuidString: url.lastPathComponent),
              let route  = CoreDataManager.shared.route(id: id)
        else { return }

        // 1. берём все окна этой сцены
        guard let winScene = scene as? UIWindowScene else { return }
        let windows = winScene.windows

        // 2. ищем MapViewController в любой ветке
        let mapVC = windows
            .compactMap { $0.rootViewController?.find(of: MapViewController.self) }
            .first

        guard let map = mapVC else {
            print("MapViewController not found in VC hierarchy"); return
        }

        // 3. выводим маршрут
        if map.routeState != .idle {
            let alert = UIAlertController(title: "Replace current route?",
                                          message: "Unsaved route will be lost.",
                                          preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Open",   style: .destructive){ _ in
                map.clearRoute(); map.showRoute(route, fromCalendar: true)
            })
            map.present(alert, animated: true)
        } else {
            map.showRoute(route, fromCalendar: true)
        }

        // 4. если MapVC сидит внутри TabBar – переключаем вкладку
        if let tab = map.tabBarController,
           let idx = tab.viewControllers?.firstIndex(where: {
                $0.find(of: MapViewController.self) === map }) {
            tab.selectedIndex = idx
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

//  UIViewController+Find.swift
import UIKit

extension UIViewController {
    /// Рекурсивно ищет VC нужного типа во всей иерархии
    func find<T: UIViewController>(of type: T.Type) -> T? {
        if let vc = self as? T { return vc }

        for child in children {
            if let found = child.find(of: T.self) { return found }
        }
        if let presented = presentedViewController {
            if let found = presented.find(of: T.self) { return found }
        }
        return nil
    }
}
