//
//  SettingsController.swift
//  ios
//
//  Created by Alexis on 28/05/2018.
//  Copyright © 2018 avocado. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

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
            switchCell.titleLabel.text = NSLocalizedString("Location tracking", comment: "")
            switchCell.action = { (isOn: Bool) -> Void in
                print("Hello World \(isOn)")
            }
            switchCell.toggleSwitch.isOn = false
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
