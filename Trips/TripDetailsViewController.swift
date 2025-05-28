//
//  TripDetailsViewController.swift
//  Diploma
//
//  Created by Olesia Skydan on 01.05.2025.
//

import UIKit

// TripDetailsViewController.swift
import UIKit

final class TripDetailsViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private var waypoints: [Waypoint] = []

    // MARK: instantiation helper
    static func instantiate(route: RouteModel) -> TripDetailsViewController {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(
                    identifier: "TripDetailsViewController") as! TripDetailsViewController
        vc.waypoints = route.orderedWaypoints
        vc.title     = route.title
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension   // якщо хочеш автозріст
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.register(UINib(nibName: "MyTripDetailsTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "MyTripDetailsTableViewCell")
        tableView.separatorStyle = .none

    }
}

extension TripDetailsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int {
        waypoints.count
    }

    func tableView(_ tv: UITableView,
                   cellForRowAt ip: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier:"MyTripDetailsTableViewCell",
                                                for: ip) as? MyTripDetailsTableViewCell else {
            fatalError("Nib not hooked")
        }
        

        let wp = waypoints[ip.row]
        let isStart = ip.row == 0  
        cell.configure(with: wp,
                       index: ip.row,
                       total: waypoints.count)
        print("Rendering: \(waypoints[ip.row].title)")
        return cell
    }
}
