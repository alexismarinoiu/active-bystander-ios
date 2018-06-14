import UIKit
import MobileCoreServices

class ProfileEditScreenController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var allHelpAreas = [MHelpArea]()
    var selectedHelpAreas = [MHelpArea]()

    public weak var delegate: ProfileEditScreenControllerDelegate?

    lazy var picker: UIImagePickerController = { () -> UIImagePickerController in
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.mediaTypes = [kUTTypeImage] as [String]
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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
        let helpArea = allHelpAreas[indexPath.row]

        cell.textLabel?.text = helpArea.situation
        if (selectedHelpAreas.contains { $0.situationId == helpArea.situationId }) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allHelpAreas.count
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

        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

        if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
            //implement DELETE HTTP call
            // notTODO: Don't check on string!
            if let index = selectedHelpAreas.index(where: { $0.situation == cell.textLabel?.text }) {
                selectedHelpAreas.remove(at: index)
            }

            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            //implement the POST call
            cell.accessoryType = UITableViewCellAccessoryType.checkmark

            // notTODO: Don't check on string!
            if let text = cell.textLabel?.text,
                let helpArea = selectedHelpAreas.filter({ $0.situation == text }).first {
                selectedHelpAreas.append(helpArea)
            }
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
        delegate?.profileEditScreenController(self, updateHelpAreas: selectedHelpAreas)
        dismiss(animated: true, completion: nil)
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

protocol ProfileEditScreenControllerDelegate: class {
    func profileEditScreenController(_ editScreen: ProfileEditScreenController, updateHelpAreas helpAreas: [MHelpArea])
}
