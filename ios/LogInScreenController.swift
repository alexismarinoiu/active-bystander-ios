import UIKit

class LogInScreenController: UIViewController {
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginStackView: UIStackView!
    
    var bottomConstraintConstant: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardShown(notification:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardHidden(notification:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
        
        bottomConstraintConstant = bottomConstraint.constant
    }

    private func keyboardInfo(_ notification: NSNotification) -> (size: CGRect, duration: Double, curve: UIViewAnimationOptions)? {
        guard let userInfo = notification.userInfo,
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue else {
                return nil
        }
        
        let theCurve = (UIViewAnimationCurve(rawValue: curve) ?? .easeInOut).toOptions
        return (size: keyboardSize, duration: duration, curve: theCurve)
    }
    
    @objc func keyboardShown(notification: NSNotification) {
        guard let info = keyboardInfo(notification) else {
            return
        }
        
        bottomConstraint.constant += info.size.height
    
        UIView.animate(withDuration: info.duration,
                       delay: 0,
                       options: info.curve,
                       animations: {}) { [weak `self` = self] _ in
            self?.loginStackView.layoutIfNeeded()
        }
    }
    
    @objc func keyboardHidden(notification: NSNotification) {
        guard let info = keyboardInfo(notification) else {
            return
        }
        
        bottomConstraint.constant = bottomConstraintConstant
        
        UIView.animate(withDuration: info.duration,
                       delay: 0,
                       options: info.curve,
                       animations: {}) { [weak `self` = self] _ in
            self?.loginStackView.layoutIfNeeded()
        }
    }
}

fileprivate extension UIViewAnimationCurve {
    var toOptions: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(rawValue << 16))
    }
}
