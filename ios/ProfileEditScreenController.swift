import UIKit

class ProfileEditScreenController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension ProfileEditScreenController {
    // Cancel
    @IBAction func cancelButtonPress(_ sender: UINavigationItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Done
    @IBAction func doneButtonPress(_ sender: UINavigationItem) {
        // TODO: Save
    }
}
