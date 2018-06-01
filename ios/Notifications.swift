//
//  Notifications.swift
//  ios
//
//  Created by Nik on 30/05/2018.
//  Copyright © 2018 avocado. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static var AVLocationChangeNotification = Notification.Name(rawValue: "avLocationChangeNotification")
    static var AVLocationAuthorizationNotification = Notification.Name(rawValue: "avLocationAuthorizationNotification")
}
