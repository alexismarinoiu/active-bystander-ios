import Foundation

extension NSNotification.Name {
    static var AVLocationChangeNotification = Notification.Name(rawValue: "avLocationChangeNotification")
    static var AVLocationAuthorizationNotification = Notification.Name(rawValue: "avLocationAuthorizationNotification")
    static var AVAuthStatusChangeNotification = Notification.Name(rawValue: "avAuthStatusChange")
    static var AVInboxThreadRequestNotification = Notification.Name(rawValue: "avInboxThredRequestNotification")
}
