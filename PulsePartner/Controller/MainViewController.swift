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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIButton!

    var users = [
        User(userID: 1, image: "ProfilePicture", name: "Clarissa", age: "27", bpm: "92"),
        User(userID: 2, image: "ProfilePicture2", name: "Alina", age: "23", bpm: "98"),
        User(userID: 3, image: "ProfilePicture3", name: "Jenny", age: "19", bpm: "95")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        UserManager.sharedInstance.getProfilePicture(withView: self)
//        let locationManager = LocationManager.sharedInstance
//        longTestLabel.text = "Lat: \(locationManager.determineMyCurrentLocation()[0])"
//        latTestLabel.text = "Long: \(locationManager.determineMyCurrentLocation()[1])"
//        let distance = locationManager.getDistance(from: CLLocation(latitude: 53.083552, longitude: 8.805238))
//        distanceLabel.text = "Dist: \(distance)"

        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
//        self.navigationController?.isNavigationBarHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.reloadData()
    }

    @IBAction func onLogout(_ sender: Any) {
        UserManager.sharedInstance.logout()
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
