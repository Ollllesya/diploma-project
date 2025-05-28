//
//  AppDelegate.swift
//  Diploma
//
//  Created by Олеся Скидан on 17.02.2025.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("AIzaSyA1XMnhrc-Ig-HwuyUCkKcX0aUlaiB48S4")
        GMSPlacesClient.provideAPIKey("AIzaSyA1XMnhrc-Ig-HwuyUCkKcX0aUlaiB48S4")
        return true
    }
    
    func application(_ app: UIApplication,
                         open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

            guard url.scheme == "diploma",
                  url.host   == "route",
                  let id = UUID(uuidString: url.lastPathComponent),
                  let route = CoreDataManager.shared.route(id: id)
            else { return false }

            guard
                let tabBar = window?.rootViewController as? UITabBarController,
                let mapNav = tabBar.viewControllers?.first as? UINavigationController,
                let mapVC  = mapNav.viewControllers.first as? MapViewController
            else { return false }

            if mapVC.routeState != .idle {
                let ask = UIAlertController(
                    title: "Replace current route?",
                    message: "You have an unsaved route. Open the planned route instead?",
                    preferredStyle: .alert)
                ask.addAction(.init(title: "Cancel", style: .cancel))
                ask.addAction(.init(title: "Open",   style: .destructive) { _ in
                    mapVC.clearRoute()
                    mapVC.showRoute(route, fromCalendar: true)
                })
                mapVC.present(ask, animated: true)
            } else {
                mapVC.showRoute(route, fromCalendar: true)
            }

            tabBar.selectedIndex = 0
            return true
        }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
        lazy var persistentContainer: NSPersistentContainer = {
            // Назва має збігатися з .xcdatamodeld-файлом (без розширення)
            let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    fatalError("Unresolved CoreData error \(error), \(error.userInfo)")
                }
            }
            return container
        }()

        // MARK: - Core Data Saving support
        func saveContext () {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved CoreData error \(nserror), \(nserror.userInfo)")
                }
            }
        }


}

