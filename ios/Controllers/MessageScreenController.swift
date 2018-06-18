import UIKit
import UserNotifications

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
        let sequenceNumber: Int
    }

    private(set) var messages: [Message] = []

    private var cellHeights = [CGFloat]()

    override func viewDidLoad() {
        super.viewDidLoad()

        shifter.delegate = self
        shifter.register()

        self.refreshMessages { [weak `self` = self] in
            self?.scrollToBottom(animated: false)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // Register for active notification updates
        (UIApplication.shared.delegate as? AppDelegate)?.notificationCenter
            .addObserver(self, selector: #selector(remoteNotificationReceived(notification:)),
                         name: .AVInboxActiveMessageNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        (UIApplication.shared.delegate as? AppDelegate)?.notificationCenter
            .removeObserver(self, name: .AVInboxActiveMessageNotification, object: nil)
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

        textInput.text = ""

        // Increment the sequence number
        let newSeq = lastSequenceNumber + 1
        messages.append(Message(isMe: true, text: "", sequenceNumber: newSeq))
        // Correct updating of sequence number
        let request = MMessageSendRequest(seq: newSeq, content: text, threadId: thread.threadId)
        Environment.backend.update(request) { [weak `self` = self] (success, message: MMessage?) in
            if !success {
                print("Sending message failed: \(message.debugDescription)")
            }

            self?.refreshMessages {
                self?.scrollToBottom(animated: true)
            }
        }
    }

    @IBAction func messageViewPressed(_ sender: UITapGestureRecognizer) {
        textInput.resignFirstResponder()
    }

    @objc func remoteNotificationReceived(notification: Notification) {
        guard let thread = notification.userInfo?[0] as? MThread,
            thread.threadId == self.thread.threadId,
            let notificationCompletionHandler =
            notification.userInfo?[1] as? ((UNNotificationPresentationOptions) -> Void) else {
            return
        }

        // Suppress alerts if this is the active thread
        notificationCompletionHandler([])
        self.refreshMessages { [weak `self` = self] in
            self?.scrollToBottom(animated: true)
        }
    }
}

extension MessageScreenController {
    func refreshMessages(_ didReload: (() -> Void)? = nil) {
        let messageRequest = MMessageRequest(threadId: thread.threadId, queryLastMessage: false)
        Environment.backend.read(messageRequest) { [weak weakSelf = self] (status, loadedMessages: [MMessage]?) in
            guard let `self` = weakSelf else {
                return
            }

            guard status, let loadedMessages = loadedMessages else {
                DispatchQueue.main.async {
                    self.messages = []
                    self.messageTableView.reloadData()
                }
                return
            }

            let newMessages = loadedMessages.map {
                Message(isMe: $0.sender == Environment.userAuth.username, text: $0.content, sequenceNumber: $0.seq)
            }

            DispatchQueue.main.async { [weak `self` = self] in
                guard let `self` = self, self.messages != newMessages else {
                    return
                }

                self.messages = newMessages
                self.messageTableView.reloadData()
                didReload?()
            }
        }
    }

    private var lastSequenceNumber: Int {
        return messages.reversed().lazy.filter { $0.isMe }.map { $0.sequenceNumber }.first ?? 0
    }

    private func scrollToBottom(animated: Bool) {
        messageTableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0),
                                     at: .bottom, animated: animated)
    }
}

// MARK: - Table View Delegate
extension MessageScreenController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= cellHeights.count {
            // Extend the array
            cellHeights.append(contentsOf: [CGFloat](repeating: UITableViewAutomaticDimension,
                                                     count: indexPath.row + 1 - cellHeights.count))
        }

        cellHeights[indexPath.row] = cell.bounds.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= cellHeights.count {
            return UITableViewAutomaticDimension
        }

        return cellHeights[indexPath.row]
    }
}

// MARK: - Keyboard Shifting Delegate
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

// MARK: - Table View Data Source
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

extension MessageScreenController.Message: Equatable {
    static func == (_ lhs: MessageScreenController.Message, _ rhs: MessageScreenController.Message) -> Bool {
        return lhs.isMe == rhs.isMe && lhs.sequenceNumber == rhs.sequenceNumber && lhs.text == rhs.text
    }
}
