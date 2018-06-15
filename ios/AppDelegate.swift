import UIKit
import CoreLocation
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    public private(set) var locationManager: CLLocationManager?
    public let notificationCenter = NotificationCenter()
    public let userNotifications = UNUserNotificationCenter.current()
    private var backgroundInvocation = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.other
        locationManager.distanceFilter = 5
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        self.locationManager = locationManager

        // Check if we are running normally or in the background to receive location updates
        if let hasLocation = launchOptions?[.location] as? NSNumber,
            hasLocation.boolValue {
            backgroundInvocation = true
            NSLog("AV: Woke up from location change")
            updateMonitoring(significant: true)
            return true
        }

        // Set up the window and storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = {
            let window = UIWindow()
            window.backgroundColor = .white
            window.rootViewController = storyboard.instantiateInitialViewController()
            window.makeKeyAndVisible()
            return window
        }()

        // Request the location permission
        locationManager.requestAlwaysAuthorization()

        // swiftlint:disable unused_closure_parameter
        userNotifications.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        }
        // swiftlint:enable unused_closure_parameter
        userNotifications.delegate = self

        notificationCenter.addObserver(self, selector: #selector(didUserLoginAuthorizationUpdate(_:)),
                                       name: .AVAuthStatusChangeNotification, object: nil)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types
        // of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the
        // application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        updateMonitoring(significant: true)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        updateMonitoring(significant: false)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        // See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registering with device token \(deviceToken)")
        let request = MNotificationRegistration(token: deviceToken.base64EncodedString())
        Environment.backend.update(request) { (_, _: MNotificationRegistration?) in
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let threadId = userInfo["threadId"] as? String,
            let title = userInfo["title"] as? String,
            let statusString = userInfo["status"] as? String,
            let status = MThread.Status(rawValue: statusString) else {
            completionHandler(.failed)
            return
        }

        let thread = MThread(threadId: threadId, status: status, title: title, creator: true, threadImage: nil)

        notificationCenter.post(name: .AVInboxTabScreenRequestNotification, object: nil, userInfo: [0: thread])
        completionHandler(.newData)
    }

    @objc func didUserLoginAuthorizationUpdate(_ notification: Notification) {
        guard let status = notification.userInfo?[0] as? UserAuth.Status else {
            return
        }

        if status == .loggedIn {
            updateMonitoring(significant: false)
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            locationManager?.stopUpdatingLocation()
            locationManager?.stopMonitoringSignificantLocationChanges()
        }
    }

}

extension AppDelegate {
    func updateMonitoring(significant: Bool) {
        let enabled =
            UserDefaults.this.isLocationEnabled && CLLocationManager.authorizationStatus() == .authorizedAlways
        if enabled && !significant {
            // Don't let significant location updates disturb the accurate updates
            locationManager?.stopMonitoringSignificantLocationChanges()
            locationManager?.startUpdatingLocation()
        } else if enabled && significant && CLLocationManager.significantLocationChangeMonitoringAvailable() {
            // Don't turn off accurate location service as this can still be used for some time
            // Turn on the significant monitoring service so that the app gets resumed every now and then
            locationManager?.startMonitoringSignificantLocationChanges()
        } else {
            // Turn off both location services
            locationManager?.stopUpdatingLocation()
            locationManager?.stopMonitoringSignificantLocationChanges()
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateMonitoring(significant: backgroundInvocation)
        notificationCenter.post(name: .AVLocationAuthorizationNotification, object: self, userInfo: [0: status])
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        notificationCenter.post(name: .AVLocationChangeNotification, object: self, userInfo: [0: locations])
        guard let lastLocation = locations.last else {
            return
        }

        // notTODO: Change MLocation generation with authentication
        let request = lastLocation.coordinate.toMLocation(username: "nv516")
        Environment.backend.update(request) { (success, _: MLocation?) in
            print("Location Request: \(success)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorised.
            manager.stopMonitoringSignificantLocationChanges()
            return
        }
    }
}

extension AppDelegate {
    func showLoginViewController() {
        guard !backgroundInvocation else {
            return
        }

        // Base navigation controller
        guard let rootNav = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else {
            return
        }

        // Ensure that the LogInScreen doesn't show twice
        guard !rootNav.childViewControllers.contains(where: { (controller) -> Bool in
            return controller is LogInScreenController
        }), let storyboard = rootNav.storyboard else {
            return
        }

        rootNav.setViewControllers([
            storyboard.instantiateViewController(withIdentifier: "LoginController")
        ], animated: true)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        guard let threadId = userInfo["threadId"] as? String,
            let title = userInfo["title"] as? String,
            let statusString = userInfo["status"] as? String,
            let status = MThread.Status(rawValue: statusString) else {
            completionHandler([])
            return
        }
        let thread = MThread(threadId: threadId, status: status, title: title, creator: true, threadImage: nil)
        notificationCenter.post(name: .AVInboxActiveMessageNotification, object: nil,
                                userInfo: [0: thread, 1: completionHandler])
        completionHandler([.alert])
    }
}
