import UIKit

class LogInScreenController: UIViewController {

    private var shifter = KeyboardShifter()

    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var statusSpinnerContainer: UIView!
    @IBOutlet weak var loginStack: UIStackView!

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    var isInitialDismiss = true
    private var keyboardHeight = CGFloat(0)
    private var keyboardIsShowing = false

    override func viewDidLoad() {
        super.viewDidLoad()

        shifter.delegate = self
        shifter.register()

        usernameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)

        Environment.userAuth.updateStatus { [weak `self` = self] (status) in
            self?.updateDisplay(with: status)
        }
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        // Hide the keyboard
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        // Run the login action
        login()
    }

    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
}

extension LogInScreenController {
    func updateDisplay(with status: UserAuth.Status) {
        switch status {
        case .loggedOut: // Hide the spinner, show the login stack
            statusSpinnerContainer.layer.opacity = 1

            UIView.animate(withDuration: 0.5, animations: { [weak statusSpinnerContainer] in
                statusSpinnerContainer?.layer.opacity = 0
            }, completion: { [weak statusSpinnerContainer] _ in
                statusSpinnerContainer?.isHidden = true
                statusSpinnerContainer?.layer.opacity = 1
            })
            return
        case .pendingValidation: // Show the spinner, hide the login stack
            statusSpinnerContainer.isHidden = false
            statusSpinnerContainer.layer.opacity = 0

            UIView.animate(withDuration: 0.5, animations: { [weak statusSpinnerContainer] in
                statusSpinnerContainer?.layer.opacity = 1
            }, completion: { [weak statusSpinnerContainer] _ in
                statusSpinnerContainer?.layer.opacity = 1
            })
            return
        default:
            break
        }

        guard let storyboard = storyboard else {
            return
        }

        navigationController?.setViewControllers([
            storyboard.instantiateViewController(withIdentifier: "PrimaryScreen")
        ], animated: true)
    }

    func login() {
        guard let username = usernameField.text, let password = passwordField.text else {
            return
        }

        Environment.userAuth.logIn(with: username, password: password) { [weak `self` = self] (status) in
            self?.updateDisplay(with: status)
        }
        updateDisplay(with: Environment.userAuth.status)
    }
}

extension LogInScreenController: KeyboardShifterDelegate {

    func keyboard(_ keyboardShifter: KeyboardShifter, willShow sizeBegin: CGRect, sizeEnd: CGRect,
                  duration: Double, options: UIViewAnimationOptions) {
        if keyboardIsShowing {
            keyboardHeight = sizeEnd.height
        } else {
            // Record the keyboard height
            keyboardHeight += sizeEnd.height
        }

        // Does not support hardware keyboards
        view.frame.origin.y = -keyboardHeight

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {},
                       completion: { [weak view = view] _ in
            view?.layoutIfNeeded()
        })
    }

    func keyboardDidShow(_ keyboardShifter: KeyboardShifter) {
        keyboardIsShowing = true
        keyboardHeight = 0
    }

    func keyboard(_ keyboardShifter: KeyboardShifter, willHide sizeBegin: CGRect, sizeEnd: CGRect,
                  duration: Double, options: UIViewAnimationOptions) {
        // Does not support hardware keyboards
        view.frame.origin.y = CGFloat(0)

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {},
                       completion: { [weak view = view] _ in
            view?.layoutIfNeeded()
        })

        view.layoutIfNeeded()
    }

    func keyboardDidHide(_ keyboardShifter: KeyboardShifter) {
        keyboardIsShowing = false
    }
}

extension LogInScreenController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            login()
        }

        return true
    }

    @objc func textFieldDidChange() {
        loginButton.isEnabled = !(usernameField.text?.isEmpty ?? true) && !(passwordField.text?.isEmpty ?? true)
    }
}
