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
    
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
            switchCell.titleLabel.text = NSLocalizedString("Location Tracking", comment: "")
            switchCell.action = { [weak lm = locationManager] (isOn: Bool) -> Void in
                if isOn {
                    lm?.requestAlwaysAuthorization()
                    if !CLLocationManager.locationServicesEnabled() ||
                        CLLocationManager.authorizationStatus() != .authorizedAlways  {
                        switchCell.toggleSwitch.isOn = false
                        return
                    }
                }
                UserDefaults.standard.set(isOn, forKey: UserDefaultsConstants.locationEnabled)
            }
            switchCell.toggleSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsConstants.locationEnabled)
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

class SettingsSwitchCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    var action: ((Bool) -> Void)?
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        action?(sender.isOn)
    }
}
