import UIKit

class MessageScreenController: UIViewController {

    var thread: MThread!
    private var shifter = KeyboardShifter()
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var bottomStack: UIStackView!

    private var keyboardHeight = CGFloat(0)
    private var keyboardIsShowing = false

    struct Message {
        let isMe: Bool
        let text: String
    }

    private(set) var messages: [Message] = []
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        messageTableView.dataSource = self
        shifter.delegate = self
        shifter.register()

        self.refreshMessages()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Start the polling timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak `self` = self] _ in
            self?.refreshMessages()
        }

        let contentOffset = messageTableView.contentSize.height - messageTableView.bounds.size.height
        if contentOffset > 0 {
            let bottomOffset = CGPoint(x: 0, y: contentOffset)
            messageTableView.setContentOffset(bottomOffset, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // End the polling timer
        timer?.invalidate()
        timer = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendPressed(_ sender: Any) {
        guard textInput.text?.isEmpty != true,
            let text = textInput.text else {
            return
        }

        messages.append(Message(isMe: true, text: text))
        self.messageTableView.reloadData()
        textInput.text = ""
    }

    @IBAction func messageViewPressed(_ sender: UITapGestureRecognizer) {
        textInput.resignFirstResponder()
    }
}

extension MessageScreenController {
    func refreshMessages() {
        let messageRequest = MMessageRequest(threadId: thread.threadId, queryLastMessage: false)
        Environment.backend.read(messageRequest) { [weak weakSelf = self] (status, loadedMessages: [MMessage]?) in
            guard let `self` = weakSelf else {
                return
            }

            guard status, let loadedMessages = loadedMessages else {
                self.messages = []
                self.messageTableView.reloadData()
                return
            }

            self.messages = loadedMessages.map {
                Message(isMe: $0.sender == Environment.userAuth.username, text: $0.content)
            }

            DispatchQueue.main.async { [weak `self` = self] in
                self?.messageTableView.reloadData()
            }
        }
    }
}

extension MessageScreenController: KeyboardShifterDelegate {
    func keyboard(_ keyboardShifter: KeyboardShifter, willShow sizeBegin: CGRect, sizeEnd: CGRect,
                  duration: Double, options: UIViewAnimationOptions) {
        guard let window = view.window else {
            return
        }

        if keyboardIsShowing {
            keyboardHeight = sizeEnd.height
        } else {
            // Record the keyboard height
            keyboardHeight += sizeEnd.height
        }

        let shiftAmount = -keyboardHeight + (window.frame.maxY - bottomStack.frame.maxY)
        messageTableView.contentInset.top = -shiftAmount
        view.frame.origin.y = shiftAmount

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {},
                       completion: { [weak view = view] _ in
            view?.layoutIfNeeded()
        })
    }

    func keyboardDidShow(_ keyboardShifter: KeyboardShifter) {
        keyboardHeight = 0
        keyboardIsShowing = true
    }

    func keyboard(_ keyboardShifter: KeyboardShifter, willHide sizeBegin: CGRect, sizeEnd: CGRect,
                  duration: Double, options: UIViewAnimationOptions) {
        messageTableView.contentInset.top = 0
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

extension MessageScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.item]
        let identifier = msg.isMe ? "sender" : "receiver"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier,
                                                       for: indexPath) as? MessageScreenMessageView else {
            // This should never run
            return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        }

        cell.textField.text = msg.text
        cell.textView.layer.cornerRadius = 20
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}

class MessageScreenMessageView: UITableViewCell {
    @IBOutlet var textField: UILabel!
    @IBOutlet var textView: UIView!
}
