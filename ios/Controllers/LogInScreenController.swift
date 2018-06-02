import UIKit

class LogInScreenController: UIViewController {

    private var shifter = KeyboardShifter()
    @IBOutlet var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        shifter.delegate = self
        shifter.register()
    }

}

extension LogInScreenController: KeyboardShifterDelegate {

    func keyboard(_ keyboardShifter: KeyboardShifter,
                  shiftedBy delta: CGFloat,
                  duration: Double,
                  options: UIViewAnimationOptions) {

        view.frame.origin.y += delta
        topConstraint?.constant -= delta

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: options,
                       animations: {},
                       completion: { [weak view = view] _ in
                           self.logo.layoutIfNeeded()
                           view?.layoutIfNeeded()
                       })
    }
}

extension LogInScreenController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1

        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return true
    }
}
