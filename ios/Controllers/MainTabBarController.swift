import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        (UIApplication.shared.delegate as? AppDelegate)?.notificationCenter
            .addObserver(self, selector: #selector(tabScreenRequest(notification:)),
                         name: .AVInboxTabScreenRequestNotification, object: nil)
    }

    @objc private func tabScreenRequest(notification: Notification) {
        selectedIndex = 1
        (UIApplication.shared.delegate as? AppDelegate)?.notificationCenter
            .post(name: .AVInboxThreadRequestNotification, object: nil, userInfo: notification.userInfo)
    }

}
