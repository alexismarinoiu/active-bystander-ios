import UIKit
import CoreLocation

class ProfileScreenController: UIViewController {
    private let helpArea = ["Sexual Harassment", "Verbal Assault", "Racism"]
    private weak var locationTrackingCell: SettingsSwitchCell?
    private weak var locationManager: CLLocationManager?

    @IBOutlet weak var helpAreaTable: UITableView!

    @IBAction func logOutButtonPress(_ sender: UIButton) {
        Environment.userAuth.logOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        helpAreaTable.reloadData()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            locationManager = appDelegate.locationManager
            let selector = #selector(locationManagerChangedAuthorization(notification:))
            appDelegate.notificationCenter.addObserver(self, selector: selector,
                                                       name: .AVLocationAuthorizationNotification, object: nil)
        }
    }
}

extension ProfileScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? helpArea.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "helpAreaCell", for: indexPath)
            cell.textLabel?.text = helpArea[indexPath.row]
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath)
        guard let switchCell = cell as? SettingsSwitchCell else {
            return cell
        }

        locationTrackingCell = switchCell
        switchCell.kind = .locationTracking
        switchCell.titleLabel.text = switchCell.kind?.label
        switchCell.action = { [weak locationManager] (isOn: Bool) -> Void in
            if isOn {
                locationManager?.requestAlwaysAuthorization()
            }
            UserDefaults.this.isLocationEnabled = isOn
        }
        switchCell.toggleSwitch.isOn = UserDefaults.this.isLocationEnabled
        return switchCell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Help Area"
        default:
            return "General"
        }
    }
}

extension ProfileScreenController {
    @objc func locationManagerChangedAuthorization(notification: Notification) {
        guard let status = notification.userInfo?[0] as? CLAuthorizationStatus else {
            return
        }

        if !CLLocationManager.locationServicesEnabled() || status != .authorizedAlways {
            UserDefaults.this.isLocationEnabled = false
            if locationTrackingCell?.kind == .locationTracking {
                locationTrackingCell?.toggleSwitch.isOn = false
            }
        }
    }
}
