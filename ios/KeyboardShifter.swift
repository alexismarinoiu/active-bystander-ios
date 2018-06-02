import UIKit

class KeyboardShifter {

    public weak var delegate: KeyboardShifterDelegate?

    func register() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardMoved(notification:)),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardMoved(notification:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(notification:)),
                                               name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(notification:)),
                                               name: .UIKeyboardDidHide, object: nil)
    }

    @objc func keyboardMoved(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardSizeBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardSizeEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue else {
                return
        }

        let options: UIViewAnimationOptions = {
            let animationCurve = UIViewAnimationCurve(rawValue: curve) ?? .easeInOut
            return UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
        } ()
        let delta = keyboardSizeEnd.origin.y - keyboardSizeBegin.origin.y

        delegate?.keyboard(self, shiftedBy: delta, duration: duration, options: options)
    }

    @objc func keyboardDidShow(notification: Notification) {
        delegate?.keyboardDidShow(self)
    }

    @objc func keyboardDidHide(notification: Notification) {
        delegate?.keyboardDidHide(self)
    }
}

// MARK: - Delegate
protocol KeyboardShifterDelegate: class {
    func keyboard(_ keyboardShifter: KeyboardShifter,
                  shiftedBy delta: CGFloat,
                  duration: Double,
                  options: UIViewAnimationOptions)
    func keyboardDidShow(_ keyboardShifter: KeyboardShifter)
    func keyboardDidHide(_ keyboardShifter: KeyboardShifter)
}

// MARK: Default Implementations for Keyboard Shifter Delegate
extension KeyboardShifterDelegate {
    func keyboardDidShow(_ keyboardShifter: KeyboardShifter) { /* Do Nothing */ }
    func keyboardDidHide(_ keyboardShifter: KeyboardShifter) { /* Do Nothing */ }
}
