import UIKit
import UserNotifications

class InboxScreenController: UITableViewController {
    struct Message {
        let thread: MThread
        var latestMessage: String?
    }

    private var messages: [Message] = []
    private var requests: [Message] = []
    private let pendingQueue = DispatchQueue(label: "uk.avocado.Bystander.InboxPending", qos: .userInitiated,
                                             attributes: [], autoreleaseFrequency: .inherit, target: nil)

    override init(style: UITableViewStyle) {
        super.init(style: style)
        postInit()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        postInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }

    private func postInit() {
        (UIApplication.shared.delegate as? AppDelegate)?.notificationCenter
            .addObserver(self, selector: #selector(transitionToThread(notification:)),
                         name: .AVInboxThreadRequestNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Register for active notification updates
        (UIApplication.shared.delegate as? AppDelegate)?.notificationCenter
            .addObserver(self, selector: #selector(remoteNotificationReceived(notification:)),
                         name: .AVInboxActiveMessageNotification, object: nil)
        reloadInboxScreen()
    }

    override func viewDidDisappear(_ animated: Bool) {
        (UIApplication.shared.delegate as? AppDelegate)?.notificationCenter
            .removeObserver(self, name: .AVInboxActiveMessageNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return requests.count
        case 1:
            return messages.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = (indexPath.section == 0 ? requests : messages)[indexPath.item]
        let type: String
        if indexPath.section != 0 {
            type = "message"
        } else {
            type = "messagePending"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: type, for: indexPath)
        guard let messageCell = cell as? MessageTableViewCell else {
            return cell
        }

        messageCell.threadId = message.thread.threadId
        messageCell.threadTitleLabel.text = message.thread.title
        messageCell.latestMessageLabel.text = message.latestMessage
        if let threadImage = message.thread.threadImage, let image = Environment.staticImage(threadImage) {
            messageCell.setThreadImage(image)
        } else {
            messageCell.setThreadImage(#imageLiteral(resourceName: "default-profile"))
        }
        messageCell.delegate = self

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !requests.isEmpty else {
            return nil
        }

        if section == 0 {
            return NSLocalizedString("Connection Requests", comment: "")
        }

        return NSLocalizedString("Messages", comment: "")
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Environment.backend.delete(MThreadConversationDeleteRequest(
                threadId: messages[indexPath.row].thread.threadId)) {(success, thread: MThread?) in
                if !success {
                    print("Deleting conversation failed: \(thread.debugDescription)")
                }
                self.reloadInboxScreen()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InboxToMessage",
            let destination: MessageScreenController = segue.destination as? MessageScreenController,
            let indexPath = tableView.indexPathForSelectedRow,
            let tableViewCell = sender as? MessageTableViewCell {
            destination.navigationItem.title = tableViewCell.threadTitleLabel.text

            destination.thread = (indexPath.section == 1 ? messages : requests)[indexPath.row].thread
        }
    }

    private func getLastMessage(for thread: MThread, completionHandler: ((String) -> Void)?) {
        Environment.backend.read(MMessageRequest(threadId: thread.threadId,
                                                 queryLastMessage: true)) { (success, last: MMessage?) in
            guard success, let lastMessage = last else {
                completionHandler?(NSLocalizedString("No Messages Sent", comment: ""))
                return
            }

            completionHandler?(lastMessage.content)
        }
    }

    func reloadInboxScreen() {
        Environment.backend.read(MThreadRequest()) { [weak `self` = self] (success, threads: [MThread]?) in
            guard success, let threads = threads else {
                return
            }

            var pendingMessages = [Message]()
            var pendingRequests = [Message]()

            let group = DispatchGroup()
            for thread in threads {
                var index = -1
                // Create the messages in the order of threads to prevent reordering
                self?.pendingQueue.sync {
                    if !thread.creator && thread.status != .accepted {
                        pendingRequests.append(Message(thread: thread, latestMessage: nil))
                        index = pendingRequests.count - 1
                    } else {
                        pendingMessages.append(Message(thread: thread, latestMessage: nil))
                        index = pendingMessages.count - 1
                    }
                }

                group.enter()
                self?.getLastMessage(for: thread, completionHandler: { (message) in
                    // We enqueue appends to the pending queue to avoid concurrent accesses
                    // while allowing fetches to happen concurrently
                    self?.pendingQueue.async {
                        if !thread.creator && thread.status != .accepted {
                            pendingRequests[index].latestMessage = message
                        } else {
                            pendingMessages[index].latestMessage = message
                        }
                        group.leave()
                    }
                })
            }

            group.wait()
            self?.pendingQueue.sync {
                DispatchQueue.main.sync {
                    // Reassign messages array only on main thread.
                    guard let `self` = self else {
                        return
                    }

                    var shouldReload = false
                    if self.messages != pendingMessages {
                        self.messages = pendingMessages
                        shouldReload = true
                    }

                    if self.requests != pendingRequests {
                        self.requests = pendingRequests
                        shouldReload = true
                    }

                    if shouldReload {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    @objc func transitionToThread(notification: Notification) {
        guard let messageScreen =
            storyboard?.instantiateViewController(withIdentifier: "MessageScreen") as? MessageScreenController,
            let thread = notification.userInfo?[0] as? MThread else {
            return
        }

        messageScreen.thread = thread
        messageScreen.title = thread.title
        navigationController?.popToRootViewController(animated: false)
        navigationController?.pushViewController(messageScreen, animated: true)
    }

    @objc func remoteNotificationReceived(notification: Notification) {
        if let notificationCompletionHandler =
            notification.userInfo?[1] as? ((UNNotificationPresentationOptions) -> Void) {
            // Suppress notification from showing up
            notificationCompletionHandler([])
        }

        reloadInboxScreen()
    }
}

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var threadTitleLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var threadImage: UIImageView!
    @IBOutlet weak var buttonItems: UIView?

    var threadId: String?
    weak var delegate: MessageTableViewCellDelegate?

    /// Helper method to set the image of the thread and
    //  round it off in the process
    ///
    /// - Parameter newThreadImage: Image to set
    func setThreadImage(_ newThreadImage: UIImage) {
        UIGraphicsBeginImageContext(threadImage.bounds.size)
        let path = UIBezierPath(roundedRect: threadImage.bounds,
                                cornerRadius: threadImage.frame.size.width / 2)
        path.addClip()
        newThreadImage.draw(in: threadImage.bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        threadImage.image = finalImage
    }

    @IBAction func acceptThreadPressed(_ sender: UIButton) {
        guard let threadId = threadId else {
            return
        }
        Environment.backend.update(MAcceptRequest(threadId)) { [weak `self` = self] (_, thread: MThread?) in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.delegate?.messageTableViewCell(self, didRespondToRequest: thread)
            }
        }
    }

    @IBAction func rejectThreadPressed(_ sender: UIButton) {
        guard let threadId = threadId else {
            return
        }
        Environment.backend.delete(MDeclineRequest(threadId)) { [weak `self` = self] (_, thread: MThread?) in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }
                self.delegate?.messageTableViewCell(self, didRespondToRequest: thread)
            }
        }
    }
}

protocol MessageTableViewCellDelegate: class {
    func messageTableViewCell(_ cell: MessageTableViewCell, didRespondToRequest thread: MThread?)
}

extension InboxScreenController: MessageTableViewCellDelegate {
    func messageTableViewCell(_ cell: MessageTableViewCell, didRespondToRequest thread: MThread?) {
        reloadInboxScreen()
    }
}

extension InboxScreenController.Message: Equatable {
    static func == (lhs: InboxScreenController.Message, rhs: InboxScreenController.Message) -> Bool {
        return lhs.latestMessage == rhs.latestMessage && lhs.thread == rhs.thread
    }

}

class ButtonItemContainerView: UIView {
    @IBOutlet weak var tickButton: UIButton! {
        didSet {
            tickButton.layer.borderColor = tickButton.backgroundColor?.cgColor
            tickButton.layer.borderWidth = 1
            tickButton.layer.cornerRadius = 5
            tickButton.layer.borderColor = #colorLiteral(red: 0.02745098039, green: 0.8274509804, blue: 0.3019607843, alpha: 1)
        }
    }
    @IBOutlet weak var crossButton: UIButton! {
        didSet {
            crossButton.layer.borderColor = crossButton.backgroundColor?.cgColor
            crossButton.layer.borderWidth = 1
            crossButton.layer.cornerRadius = 5
            crossButton.layer.borderColor = #colorLiteral(red: 0.9607843137, green: 0, blue: 0.03529411765, alpha: 1)
        }
    }
}
