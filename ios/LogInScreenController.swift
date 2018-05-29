import UIKit

class LogInScreenController: UIViewController {
    
    private var shifter = KeyboardShifter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shifter.delegate = self
        shifter.register()
    }

}

extension LogInScreenController: KeyboardShifterDelegate {
    
    func keyboard(_ keyboardShifter: KeyboardShifter, shiftedBy delta: CGFloat, duration: Double, options: UIViewAnimationOptions) {
        view.frame.origin.y += delta
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: options, animations: {}) { [weak view = view] _ in
                        view?.layoutIfNeeded()
        }
    }
}
