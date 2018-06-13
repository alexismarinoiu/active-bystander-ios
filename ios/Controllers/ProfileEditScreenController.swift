import UIKit
import MobileCoreServices

class ProfileEditScreenNavigationController: UINavigationController {

}

class ProfileEditScreenController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var helpArea: [String] = []

    lazy var picker: UIImagePickerController = { () -> UIImagePickerController in
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.mediaTypes = [kUTTypeImage] as [String]
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ProfileEditScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpAreaCell", for: indexPath)
        cell.textLabel?.text = helpArea[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpArea.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Help Area"
        default:
            return ""
        }
    }
}

extension ProfileEditScreenController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
    }
}

// MARK: - Actions
extension ProfileEditScreenController {
    // Cancel
    @IBAction func cancelButtonPress(_ sender: UINavigationItem) {
        dismiss(animated: true, completion: nil)
    }

    // Done
    @IBAction func doneButtonPress(_ sender: UINavigationItem) {
        // notTODO: Save
    }

    @IBAction func profilePicturePress(_ sender: UITapGestureRecognizer) {
        present(picker, animated: true, completion: nil)
    }
}

extension ProfileEditScreenController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        picker.dismiss(animated: true, completion: nil)
        // notTODO: Implement
    }
}
