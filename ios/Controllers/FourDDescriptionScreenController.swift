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

}
