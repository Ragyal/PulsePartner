//
//  MainViewController.swift
//  PulsePartner
//
//  Created by yannik grotkop on 23.04.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tabV = UITableView()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIButton!

    var allMatches = [User]() {
        didSet {
            print("Hello \(allMatches.count)")
        }
    }

    static let sharedInstance = MainViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        UserManager.sharedInstance.getProfilePicture(withView: self)
//        let locationManager = LocationManager.sharedInstance
//        longTestLabel.text = "Lat: \(locationManager.determineMyCurrentLocation()[0])"
//        latTestLabel.text = "Long: \(locationManager.determineMyCurrentLocation()[1])"
//        let distance = locationManager.getDistance(from: CLLocation(latitude: 53.083552, longitude: 8.805238))
//        distanceLabel.text = "Dist: \(distance)"
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        allMatches = MatchManager.sharedInstance.getMatches()
        print("Start download")
        MatchManager.sharedInstance.loadMatches {
            // Data for UITableView is populated from the CatManager singleton
            print("reload Table")
            self.allMatches = MatchManager.sharedInstance.allMatches
            self.tableView.reloadData()
        }
        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
//        self.navigationController?.isNavigationBarHidden = true
    }

    func reload(userList: [User]) {
        for user in userList {
            allMatches.append(user)
        }
    }

    @IBAction func onLogout(_ sender: Any) {
        UserManager.sharedInstance.logout()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMatches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as! MatchCell

        let user = self.allMatches[indexPath.row]
        cell.insertContent(image: user.image,
                            name: user.name,
                            age: String(user.age),
                            bpm: String(user.bpm),
                            navigation: self.navigationController!)
        return cell
    }
}
