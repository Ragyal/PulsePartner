//
//  MainViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 23.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var users = [
        User(userID: 1, image: "ProfilePicture", name: "Clarissa", age: "27", bpm: "92"),
        User(userID: 2, image: "ProfilePicture2", name: "Alina", age: "23", bpm: "98"),
        User(userID: 3, image: "ProfilePicture3", name: "Jenny", age: "19", bpm: "95")
    ]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var longTestLabel: UILabel!
    @IBOutlet weak var latTestLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locationManager = LocationManager()
        longTestLabel.text = "Lat: \(locationManager.determineMyCurrentLocation()[0])"
        latTestLabel.text = "Long: \(locationManager.determineMyCurrentLocation()[1])"
        distanceLabel.text = "Dist: \(locationManager.getDistance(from: CLLocation(latitude: 53.083552,longitude: 8.805238)))"
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
//        self.navigationController?.isNavigationBarHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as! MatchCell

        let user = users[indexPath.row]
        cell.insertContent(image: user.image,
                           name: user.name,
                           age: "\(user.age) Years old",
                           bpm: "\(user.bpm) BPM",
                           navigation: self.navigationController!)

        return cell
    }
}
