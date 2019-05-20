//
//  UserManager.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 01.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Firebase

class UserManager {

    // Singleton
    static let sharedInstance = UserManager()

    let auth: Auth
    let fStore: Firestore
    let fStorage: Storage

    var isLoggedIn: Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }

    private init() {
        auth = Auth.auth()
        fStore = Firestore.firestore()
        fStorage = Storage.storage()
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

                    // Upload the file to the path "images/rivers.jpg"
                    _ = pictureRef.putData(data, metadata: metadata) { (metadata, _) in
                        guard metadata != nil else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        // You can also access to download URL after upload.
                        pictureRef.downloadURL { (url, _) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                return
                            }

                            self.fStore.collection("users").document(uid).setData([
                                "username": userData.username,
                                "email": userData.email,
                                "age": userData.age,
                                "weight": userData.weight,
                                "fitnessLevel": userData.fitnessLevel,
                                "gender": userData.gender,
                                "preferences": userData.preferences,
                                "profile_picture": downloadURL.absoluteString
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
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
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }

    func getProfilePicture(url: String, completion: @escaping (UIImage) -> Void) {
            let imageRef = self.fStorage.reference(forURL: url)
            imageRef.getData(maxSize: 10 * 1024 * 1024, completion: {( data, error) in
                if let error = error {
                    print("Error: \(error)")
                } else {
                    if let imageData = data {
                        completion(UIImage(data: imageData)!)
                    }
                }
            })
    }
}
