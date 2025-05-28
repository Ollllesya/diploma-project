//
//  Untitled.swift
//  LoadRex
//
//  Created by Olesia Skydan 10.04.2025.
//

import UIKit
import CoreData


// MyTripsViewController.swift
import CoreData
import UIKit

final class MyTripsViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var anyTripsView: UIStackView!
    
    private var routes: [RouteModel] = []

    private lazy var ctx: NSManagedObjectContext = {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // «Серое» изображение (для не-выбранного состояния)
        let normal = UIImage(systemName: "heart")?
                     .withRenderingMode(.alwaysTemplate)

        // «Синее» (или то, которое хотите для selected)
        let selected = UIImage(systemName: "heart.fill")?
                       .withRenderingMode(.alwaysTemplate)

        tabBarItem = UITabBarItem(title: "Favourite",
                                  image: normal,
                                  selectedImage: selected)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(UINib(nibName: "MyTripsHistoryTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "MyTripsHistoryTableViewCell")
        tableView.separatorStyle = .none
        configureTabBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRoutes()
    }

    private func fetchRoutes() {
        let req = RouteModel.fetchRequest()
        req.predicate       = NSPredicate(format: "scheduled == NO")   // ← NEW
        req.sortDescriptors = [.init(key: #keyPath(RouteModel.createdAt), ascending: false)]
        routes = (try? ctx.fetch(req)) ?? []
        tableView.reloadData()
        updateEmptyState()
    }

    
    private func updateEmptyState() {
        let isEmpty = routes.isEmpty
        anyTripsView.isHidden = !isEmpty
        tableView.isHidden    =  isEmpty
    }
    private func configureTabBar() {
        // 1. создаём item
        let item = UITabBarItem(title: "Favourite",
                                image: UIImage(systemName: "heart"),
                                selectedImage: UIImage(systemName: "heart.fill"))

        // 2. настраиваем (если не пользуетесь глобальным appearance)
        item.setTitleTextAttributes([.foregroundColor: UIColor.gray],        for: .normal)
        item.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .selected)

        // 3. ОБЯЗАТЕЛЬНО присваиваем!
        self.tabBarItem = item
    }

}

// MARK: UITableViewDataSource/Delegate
extension MyTripsViewController: UITableViewDataSource, UITableViewDelegate,
                                 MyTripsHistoryCellDelegate {
    func didTapMap(for route: RouteModel) {
        let vc = MapTripDetailsViewController.instantiate(with: route)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
    

    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { routes.count }
    
    func tableView(_ tv: UITableView,
                   shouldHighlightRowAt indexPath: IndexPath) -> Bool { false }

    func tableView(_ tv: UITableView,
                   willSelectRowAt indexPath: IndexPath) -> IndexPath? { nil }

    func tableView(_ tv: UITableView,
                   cellForRowAt ip: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier:"MyTripsHistoryTableViewCell",
                                                for: ip) as? MyTripsHistoryTableViewCell else {
            fatalError("Nib not hooked")
        }
        let route = routes[ip.row]
        cell.configure(with: route)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete else { return }

        // 0. Берём нужный объект
        let route = routes[indexPath.row]              // ← ЭТОЙ строки не хватало

        // 1. Удаляем из Core Data
        do {
            try CoreDataManager.shared.delete(id: route.objectID)
        } catch {
            // если захотите – покажите алерт
            print("Delete failed:", error)
            return                                        // прерываем — не удаляем из UI
        }

        // 2. Удаляем из массива + анимируем таблицу
        routes.remove(at: indexPath.row)
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }) { _ in
            // 3. Проверяем, не опустела ли таблица
            self.updateEmptyState()
        }
    }



    func didTapDetails(for route: RouteModel) {
        let vc = TripDetailsViewController.instantiate(route: route)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }

    func didTapEdit(for route: RouteModel) {
        // ваша логіка «відкрити на мапі у режимі редагування»
    }
}
