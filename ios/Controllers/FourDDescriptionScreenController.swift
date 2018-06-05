//
//  FourDDescriptionScreenController.swift
//  ios
//
//  Created by Seoin Chai on 05/06/2018.
//  Copyright © 2018 avocado. All rights reserved.
//

import UIKit

class FourDDescriptionScreenController: UIViewController {

    @IBOutlet weak var textBody: UILabel?
    var textBodyDescription = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        textBody?.text = textBodyDescription
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
