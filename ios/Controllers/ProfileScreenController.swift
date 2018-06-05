import UIKit

class ProfileScreenController: UIViewController {

    @IBAction func logOutButtonPress(_ sender: UIButton) {
        Environment.userAuth.logOut()
    }

}
