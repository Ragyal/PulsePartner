//
//  MatchManager.swift
//  PulsePartner
//
//  Created by yannik grotkop on 17.05.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Firebase

class MatchManager {

    // Singleton
    static let shared = MatchManager()

    let fStore: Firestore
    let fStorage: Storage

    var matchDataListener: ListenerRegistration?
    var matches: [Match]? {
        didSet { stateDidChange() }
    }
    private var observations = [ObjectIdentifier: Observation]()

    private init() {
        fStore = Firestore.firestore()
        fStorage = Storage.storage()

        UserManager.shared.addObserver(self)
    }

    /**
     A snapshot listener that can be attached to collection queries.
     Maps snapshots documents to Match objects and updates property matches.
     - Parameters:
        - snapshot: The latest QuerySnapshot.
        - error: Possible errors.
     */
    func matchesListener(snapshot: QuerySnapshot?, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }

        var matches: [Match] = []
        guard let snapshot = snapshot else {
            return
        }

        for doc in snapshot.documents {
            guard let match = Match(modelData: FirestoreModelData(snapshot: doc)) else {
                    print("Critical error mapping data to Match objects!")
                    return
            }
            matches.append(match)
        }
        self.matches = matches
    }
}

extension MatchManager: UserObserver {
    /**
     Implements UserObserver protocol.
     Adds an matchDataListener if user is defined.
     - Parameters:
        - user: Latest user object.
     */
    func userData(didUpdate user: FullUser?) {
        guard let user = user else {
            matchDataListener?.remove()
            matches = nil
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
    /**
     Adds an MatchOberserver to observations list and send current value of the observable.
     - Parameters:
        - observer: The MatchObserver protocol implementing observer.
     */
    func addObserver(_ observer: MatchObserver) {
        let oid = ObjectIdentifier(observer)
        observations[oid] = Observation(observer: observer)
        observer.matchData(didUpdate: matches)
    }

    /**
     Removes an MatchOberserver from observations list.
     - Parameters:
        - observer: The MatchObserver protocol implementing observer.
     */
    func removeObserver(_ observer: MatchObserver) {
        let oid = ObjectIdentifier(observer)
        observations.removeValue(forKey: oid)
    }
}

private extension MatchManager {
    /**
     Gets called when the property matches gets set/updated and notifies all observers.
     Dereferenced/deleted observers are being removed.
     */
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
