//
//  UserManager.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 01.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Firebase
import CoreLocation

class UserManager {

    // Singleton
    static let shared = UserManager()

    let auth: Auth
    let fStore: Firestore
    let fStorage: Storage

    var userDataListener: ListenerRegistration?

    var authenticated: Bool { return Auth.auth().currentUser != nil ? true : false }
    var uid: String? { return Auth.auth().currentUser?.uid }
    var user: FullUser? {
        didSet { stateDidChange() }
    }
    var fcmToken: String? {
        didSet { updateUserFCMToken() }
    }

    private var observations = [ObjectIdentifier: Observation]()

    private init() {
        auth = Auth.auth()
        fStore = Firestore.firestore()
        fStorage = Storage.storage()

        auth.addStateDidChangeListener({ (_, user) in
            guard let uid = user?.uid else {
                self.userDataListener?.remove()
                self.user = nil
                return
            }
            self.userDataListener = self.fStore.collection("users").document(uid)
                .addSnapshotListener { (snapshot, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    guard let snapshot = snapshot else {
                        return
                    }

                    self.user = FullUser(modelData: FirestoreModelData(snapshot: snapshot))

                    guard var user = self.user else {
                        return
                    }
                    guard let token = self.fcmToken else {
                        return
                    }

                    if user.fcmToken == token {
                        return
                    }

                    user.fcmToken = token

                    self.fStore.collection("users").document(user.documentID).setModel(user) { err in
                        if let err = err {
                            print("Error writing token in document: \(err.localizedDescription)")
                        } else {
                            print("Token in document successfully written!")
                        }
                    }
                }
        })
    }

    public func createUser(withUserData userData: UserRegisterData,
                           image: UIImage?,
                           sender: UIViewController,
                           completion: @escaping (Bool) -> Void) {

        self.auth.createUser(withEmail: userData.email, password: userData.password) { (user, error) in
            if error == nil {
                guard let uid = user?.user.uid else {
                    completion(false)
                    return
                }
                // Data in memory
                if let data = image?.pngData() {
                    // Create a reference to the file you want to upload
                    let pictureRef = self.fStorage.reference().child("profilePictures/\(uid).png")

                    let metadata = StorageMetadata()
                    metadata.contentType = "image/png"

                    // Upload the file to the path "profilePictures/UID.png"
                    _ = pictureRef.putData(data, metadata: metadata) { (metadata, err) in
                        guard metadata != nil else {
                            print(err?.localizedDescription ?? "Error occured during upload.")
                            return
                        }
                        // You can also access to download URL after upload.
                        pictureRef.downloadURL { (url, err) in
                            guard let downloadURL = url else {
                                print(err?.localizedDescription ?? "Error occured while catching image URL.")
                                return
                            }

                            let user = FullUser(userID: uid, registerData: userData, imageURL: downloadURL)

                            self.fStore.collection("users").document(user.documentID).setModel(user) { err in
                                if let err = err {
                                    print("Error writing document: \(err.localizedDescription)")
                                    completion(false)
                                } else {
                                    print("Document successfully written!")
                                    completion(true)
                                }
                            }
                        }
                    }
                }

            } else {
                let alertController = UIAlertController(title: "Error",
                                                        message: error?.localizedDescription,
                                                        preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)

                alertController.addAction(defaultAction)
                sender.present(alertController, animated: true, completion: nil)
                completion(false)
            }
        }
    }

    public func signIn(withEmail email: String,
                       password: String,
                       sender: UIViewController,
                       completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
            if error == nil {
                UIApplication.shared.registerForRemoteNotifications()
                completion(true)
            } else {
                let alertController = UIAlertController(title: "Error",
                                                        message: error?.localizedDescription,
                                                        preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                alertController.addAction(defaultAction)
                sender.present(alertController, animated: true, completion: nil)
                completion(false)
            }
        }
    }

    public func logout() {
        if user?.fcmToken != nil {
            if var user = user {
                user.fcmToken = nil

                self.fStore.collection("users").document(user.documentID).setModel(user) { err in
                    if let err = err {
                        print("Error removing token from document: \(err.localizedDescription)")
                    } else {
                        print("Token successfully removed from document!")
                    }
                }
            }
        }

        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

        UIApplication.shared.unregisterForRemoteNotifications()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }

    func updateProfilePicture(image: UIImage) {
        guard var user: FullUser = self.user else {
            return
        }
        guard let uid = user.documentID else {
            return
        }
        // Data in memory
        if let data = image.pngData() {
            // Create a reference to the file you want to upload
            let pictureRef = self.fStorage.reference().child("profilePictures/\(uid).png")

            let metadata = StorageMetadata()
            metadata.contentType = "image/png"

            // Upload the file to the path "profilePictures/UID.png"
            _ = pictureRef.putData(data, metadata: metadata) { (metadata, err) in
                guard metadata != nil else {
                    print(err?.localizedDescription ?? "Error occured during upload.")
                    return
                }
                // You can also access to download URL after upload.
                pictureRef.downloadURL { (url, err) in
                    guard let downloadURL = url else {
                        print(err?.localizedDescription ?? "Error occured while catching image URL.")
                        return
                    }

                    user.image = downloadURL.absoluteString

                    self.fStore.collection("users").document(user.documentID).setModel(user) { err in
                        if let err = err {
                            print("Error writing document: \(err.localizedDescription)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
    }

    func updateMatchData(coordinates: CLLocationCoordinate2D) {
        guard let user = self.user else {
            return
        }
        HealthKitManager.shared.readHeartRateData { file in
            let matchData: MatchData = MatchData(user: user, heartrate: Int(file), coordinates: coordinates)

            self.fStore.collection("matchData").document(user.documentID).setModel(matchData) { err in
                if let err = err {
                    print("Error writing MatchData: \(err)")
                } else {
                    print("MatchData successfully written!")
                }
            }
        }

    }
}

private extension UserManager {
    struct Observation {
        weak var observer: UserObserver?
    }
}

extension UserManager {
    func addObserver(_ observer: UserObserver) {
        let oid = ObjectIdentifier(observer)
        observations[oid] = Observation(observer: observer)
        observer.userData(didUpdate: user)
    }

    func removeObserver(_ observer: UserObserver) {
        let oid = ObjectIdentifier(observer)
        observations.removeValue(forKey: oid)
    }
}

private extension UserManager {
    func stateDidChange() {
        for (oid, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: oid)
                continue
            }

            observer.userData(didUpdate: user)
        }
    }

    func updateUserFCMToken() {
        guard var user = self.user else {
            return
        }
        if user.fcmToken == self.fcmToken {
            return
        }

        user.fcmToken = self.fcmToken

        self.fStore.collection("users").document(user.documentID).setModel(user) { err in
            if let err = err {
                print("Error writing token in document: \(err.localizedDescription)")
            } else {
                print("Token in document successfully written!")
            }
        }
    }
}
