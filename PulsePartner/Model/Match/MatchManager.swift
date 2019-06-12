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

    var matchDataListener: ListenerRegistration?
    var matches: [MatchWithImage]? {
        didSet { stateDidChange() }
    }
    private var observations = [ObjectIdentifier: Observation]()
    var allMatches = [MatchWithImage]()

    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()

        UserManager.sharedInstance.addObserver(self)
    }

    func matchesListener(snapshot: QuerySnapshot?, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }

        var matches: [MatchWithImage] = []
        guard let snapshot = snapshot else {
            return
        }

        for doc in snapshot.documents {
            guard let match = Match(modelData: FirestoreModelData(snapshot: doc)) else {
                    print("Critical error mapping data to Match obejcts!")
                    return
            }
            let url = match.image
            UserManager.sharedInstance.getProfilePicture(url: url) { file in
                let matchWithImage = MatchWithImage(matchData: match, image: file)
                matches.append(matchWithImage)

                if matches.count == snapshot.documents.count {
                    self.matches = matches
                }
            }
        }
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

extension MatchManager: UserObserver {
    func userData(didUpdate user: FullUser?) {
        guard let user = user else {
            matchDataListener?.remove()
            return
        }
        self.matchDataListener = fStore.collection("users").document(user.documentID).collection("matches")
            .addSnapshotListener(matchesListener)
    }
}

private extension MatchManager {
    struct Observation {
        weak var observer: MatchObserver?
    }
}

extension MatchManager {
    func addObserver(_ observer: MatchObserver) {
        let oid = ObjectIdentifier(observer)
        observations[oid] = Observation(observer: observer)
        observer.matchData(didUpdate: matches)
    }

    func removeObserver(_ observer: MatchObserver) {
        let oid = ObjectIdentifier(observer)
        observations.removeValue(forKey: oid)
    }
}

private extension MatchManager {
    func stateDidChange() {
        for (oid, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: oid)
                continue
            }

            observer.matchData(didUpdate: matches)
        }
    }
}
