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
import CoreData

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIButton!

    var allMatches = [MatchWithImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = UserManager.sharedInstance.user {
            updateImage(user: user)
        }
        UserManager.sharedInstance.addObserver(self)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        MatchManager.sharedInstance.addObserver(self)

        let img = UIImage()
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
//        self.navigationController?.isNavigationBarHidden = true

        LocationManager.sharedInstance.startUpdatingLocation()
    }

    @IBAction func onLogout(_ sender: Any) {
        LocationManager.sharedInstance.stopUpdatingLocation()
        UserManager.sharedInstance.logout()
    }

    func updateImage(user: FullUser) {
        var placeholder = self.profilePicture.image(for: .normal)
        if placeholder == nil {
            placeholder = user.gender == "m" ?
                UIImage(named: "PlaceholderImageMale") :
                UIImage(named: "PlaceholderImageFemale")
        }
        self.profilePicture.kf.setImage(with: URL(string: user.image), for: .normal, placeholder: placeholder)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath else {
            return
        }
        guard let destinationVC = segue.destination as? ChatViewController else {
            return
        }
        destinationVC.user = self.allMatches[indexPath.row]
        guard let cell = self.tableView.cellForRow(at: indexPath) as? MatchCell else {
            return
        }
        destinationVC.messageCounter = cell.messageCounter
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMatches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.rowHeight = 110
        let cell = ( self.tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as? MatchCell )!
        let user = self.allMatches[indexPath.row]
        cell.insertContent(match: user)
        
//        cell.profilePicture.image = resizedImage
        return cell
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        // Pass the indexPath as sender
        //        let user = self.allMatches[indexPath.row]
        self.performSegue(withIdentifier: "ChatSegue", sender: indexPath)
    }
}

extension MainViewController: UserObserver {
    func userData(didUpdate user: FullUser?) {
        guard let user = user else {
            return
        }
        updateImage(user: user)
    }
}

extension MainViewController: MatchObserver {
    func matchData(didUpdate matches: [MatchWithImage]?) {
        if let matches = matches {
            self.allMatches = matches
            self.tableView.reloadData()
        }
    }
}
