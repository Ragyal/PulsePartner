//
//  MatchManager.swift
//  PulsePartner
//
//  Created by yannik grotkop on 17.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Firebase

class MatchManager {

    static let sharedInstance = MatchManager()
    let fStore: Firestore
    let fStorage: Storage
    var allMatches = [MatchWithImage]()

    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()
    }

    func loadMatches(completion: @escaping ([MatchWithImage]) -> Void) {
        guard let uid = UserManager.sharedInstance.uid else {
            return
        }
        
        fStore.collection("users").document(uid).collection("matches").getModels(Match.self) { matches, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.allMatches = []
            guard let matches = matches else {
                completion(self.allMatches)
                return
            }
            for match in matches {
                let url = match.image
                UserManager.sharedInstance.getProfilePicture(url: url) { file in
                    let matchWithImage = MatchWithImage(matchData: match, image: file)
                    self.allMatches.append(matchWithImage)
                    
                    if self.allMatches.count == matches.count {
                        completion(self.allMatches)
                    }
                }
            }
        }
    }
}
