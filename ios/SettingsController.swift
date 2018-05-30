//
//  SettingsController.swift
//  ios
//
//  Created by Alexis on 28/05/2018.
//  Copyright © 2018 avocado. All rights reserved.
//

import UIKit
import CoreLocation

class SettingsController: UITableViewController {
    
    private weak var locationTrackingCell: SettingsSwitchCell?
    private weak var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            locationManager = appDelegate.locationManager
            appDelegate.notificationCenter.addObserver(self,
                                                       selector: #selector(locationManagerChangedAuthorization(notification:)),
                                                       name: .AVLocationAuthorizationNotification, object: nil)
        }
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0 && indexPath.item == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "switch", for: indexPath)
            let switchCell = cell as! SettingsSwitchCell
            locationTrackingCell = switchCell
            switchCell.kind = .locationTracking
            switchCell.titleLabel.text = switchCell.kind?.label
            switchCell.action = { [weak lm = locationManager] (isOn: Bool) -> Void in
                if isOn {
                    lm?.requestAlwaysAuthorization()
                }
                UserDefaults.this.isLocationEnabled = isOn
            }
            switchCell.toggleSwitch.isOn = UserDefaults.this.isLocationEnabled
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("General", comment: "")
        }
        return nil
    }
    
}

extension SettingsController {
    
    @objc func locationManagerChangedAuthorization(notification: Notification) {
        guard let status = notification.userInfo?[0] as? CLAuthorizationStatus else {
            return
        }
        
        if !CLLocationManager.locationServicesEnabled() || status != .authorizedAlways  {
            UserDefaults.this.isLocationEnabled = false
            if locationTrackingCell?.kind == .locationTracking {
                locationTrackingCell?.toggleSwitch.isOn = false
            }
        }
    }
}

class SettingsSwitchCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    var action: ((Bool) -> Void)?
    var kind: Kind?
    
    enum Kind {
        case locationTracking
        
        var label: String {
            switch self {
            case .locationTracking:
                return NSLocalizedString("Location Tracking", comment: "")
            }
        }
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        action?(sender.isOn)
    }
}
