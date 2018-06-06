import UIKit

class KeyboardShifter {

    public weak var delegate: KeyboardShifterDelegate?

    private struct KeyboardInfo {
        let sizeBegin: CGRect
        let sizeEnd: CGRect
        let duration: Double
        let options: UIViewAnimationOptions
    }

    func register() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(notification:)),
                                               name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(notification:)),
                                               name: .UIKeyboardDidHide, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let info = getKeyboardInfo(notification) else {
            return
        }

        delegate?.keyboard(self, willShow: info.sizeBegin, sizeEnd: info.sizeEnd, duration: info.duration,
                           options: info.options)
    }

    @objc func keyboardWillHide(notification: Notification) {
        guard let info = getKeyboardInfo(notification) else {
            return
        }

        delegate?.keyboard(self, willHide: info.sizeBegin, sizeEnd: info.sizeEnd, duration: info.duration,
                           options: info.options)
    }

    @objc func keyboardDidShow(notification: Notification) {
        delegate?.keyboardDidShow(self)
    }

    @objc func keyboardDidHide(notification: Notification) {
        delegate?.keyboardDidHide(self)
    }

    private func getKeyboardInfo(_ notification: Notification) -> KeyboardInfo? {
        guard let userInfo = notification.userInfo,
            let keyboardSizeBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyboardSizeEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue else {
                return nil
        }

        let options: UIViewAnimationOptions = {
            let animationCurve = UIViewAnimationCurve(rawValue: curve) ?? .easeInOut
            return UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
        } ()

        return KeyboardInfo(sizeBegin: keyboardSizeBegin, sizeEnd: keyboardSizeEnd,
                            duration: duration, options: options)
    }
}

// MARK: - Delegate
protocol KeyboardShifterDelegate: class {
    func keyboard(_ keyboardShifter: KeyboardShifter, willShow sizeBegin: CGRect, sizeEnd: CGRect,
                  duration: Double, options: UIViewAnimationOptions)
    func keyboard(_ keyboardShifter: KeyboardShifter, willHide sizeBegin: CGRect, sizeEnd: CGRect,
                  duration: Double, options: UIViewAnimationOptions)
    func keyboardDidShow(_ keyboardShifter: KeyboardShifter)
    func keyboardDidHide(_ keyboardShifter: KeyboardShifter)
}

// MARK: Default Implementations for Keyboard Shifter Delegate
extension KeyboardShifterDelegate {
    func keyboardDidShow(_ keyboardShifter: KeyboardShifter) { /* Do Nothing */ }
    func keyboardDidHide(_ keyboardShifter: KeyboardShifter) { /* Do Nothing */ }
}
