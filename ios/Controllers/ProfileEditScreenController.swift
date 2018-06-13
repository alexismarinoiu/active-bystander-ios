import UIKit
import MobileCoreServices

class ProfileEditScreenNavigationController: UINavigationController {

}

class ProfileEditScreenController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var allHelpAreas: [String] = []
    var selectedHelpAreas: [String] = []

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
        Environment.backend.read(MSituationRequest()) { [weak `self` = self] (success, situations: [MSituation]?) in
            guard success, let situations = situations else {
                return
            }

            DispatchQueue.main.async {
                self?.allHelpAreas = situations.map {$0.id}
                self?.tableView.reloadData()
            }
        }

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
        let helpAreaText = allHelpAreas[indexPath.row]

        cell.textLabel?.text = helpAreaText
        if selectedHelpAreas.contains(helpAreaText) {
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
            selectedHelpAreas = selectedHelpAreas.filter {$0 != cell.textLabel?.text}
            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            if !selectedHelpAreas.contains((cell.textLabel?.text)!) {selectedHelpAreas.append((cell.textLabel?.text)!)}
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
    func profileEditScreenController(_ editScreen: ProfileEditScreenController, updateHelpAreas helpAreas: [String])
}
