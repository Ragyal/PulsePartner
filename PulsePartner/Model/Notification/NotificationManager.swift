//
//  NotificationManager.swift
//  PulsePartner
//
//  Created by Ove von Stackelberg on 14.06.19.
//  Copyright © 2019 PulsePartner. All rights reserved.
//

import Foundation
import Firebase
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    // Singleton
    static let shared = NotificationManager()
}

extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}
