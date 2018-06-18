import UIKit
import MobileCoreServices

class ProfileEditScreenController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!

    private var allSituations = [MSituation]()
    var selectedHelpAreas = [MHelpArea]()
    var profileImagePicture: UIImage?

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

        profileImage.image = profileImagePicture

        Environment.backend.read(MSituationRequest()) { [weak `self` = self] (success, situations: [MSituation]?) in
            guard success, let situations = situations else {
                return
            }

            DispatchQueue.main.async {
                self?.allSituations = (situations.flatMap { $0.children }).sorted { $0.title < $1.title }
                self?.tableView.reloadData()
            }
        }
    }
}

extension ProfileEditScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpAreaCell", for: indexPath)
        let situation = allSituations[indexPath.row]

        cell.textLabel?.text = situation.title
        if (selectedHelpAreas.contains { $0.situationId == situation.id }) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSituations.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "I can help with..."
        default:
            return nil
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

        let situation = allSituations[indexPath.row]
        if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
            let request = MHelpAreaRequest(situation: situation.title, situationId: situation.id)
            Environment.backend.delete(request) { (success, _: MHelpArea?) in
                guard success else {
                    return
                }
            }
            if let index = selectedHelpAreas.index(where: { $0.situationId == situation.id }) {
                selectedHelpAreas.remove(at: index)
            }

            cell.accessoryType = UITableViewCellAccessoryType.none
        } else {
            let request = MHelpArea(situation: situation.title, situationId: situation.id)
            Environment.backend.create(request) { (success, helpArea: MHelpArea?) in
                guard success, let helpArea = helpArea else {
                    return
                }

                DispatchQueue.main.async {
                    self.selectedHelpAreas.append(helpArea)
                }
            }
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
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
        guard let imageUrl = info[UIImagePickerControllerImageURL] as? URL,
            let backend = Environment.backend as? HttpBackendService,
            let imageData = try? Data(contentsOf: imageUrl) else {
                return
        }

        let uploadAlert = UIAlertController(title: "Uploading\n", message: nil, preferredStyle: .alert)
        let activityIndicator = { () -> UIActivityIndicatorView in
            let theBounds = uploadAlert.view.bounds
            let theOffset = CGFloat(30)
            let activity = UIActivityIndicatorView(frame: CGRect(x: theBounds.origin.x,
                                                                 y: theBounds.origin.y + theOffset,
                                                                 width: theBounds.width,
                                                                 height: theBounds.height - theOffset))
            activity.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            activity.isUserInteractionEnabled = false
            activity.hidesWhenStopped = true
            activity.activityIndicatorViewStyle = .gray
            return activity
        }()
        uploadAlert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        picker.present(uploadAlert, animated: true)

        backend.uploadProfilePicture(imageData: imageData, callback: {
            // swiftlint:disable closure_parameter_position
            [weak `self` = self, uploadAlert] (success, profilePicture) in
            // swiftlint:enable closure_parameter_position

            DispatchQueue.main.async { [uploadAlert] in
                uploadAlert.dismiss(animated: true, completion: {
                    picker.dismiss(animated: true, completion: nil)
                })

                guard let `self` = self, success,
                    let profilePicture = profilePicture,
                    let image = UIImage(fromEnvironmentStaticPath: profilePicture.path) else {
                    return
                }

                let roundedImage = image.rounded(in: self.profileImage)
                self.profileImage.image = roundedImage
                self.delegate?.profileEditScreenController(self, updateProfilePicture: roundedImage)
            }

        })
    }
}

protocol ProfileEditScreenControllerDelegate: class {
    func profileEditScreenController(_ editScreen: ProfileEditScreenController, updateHelpAreas helpAreas: [MHelpArea])
    func profileEditScreenController(_ editScreen: ProfileEditScreenController, updateProfilePicture picture: UIImage?)
}
