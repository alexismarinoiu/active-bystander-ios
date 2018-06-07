import UIKit

class InboxScreenController: UITableViewController {
    struct Message {
        let thread: MThread
        let latestMessage: String
    }

    private var messages: [Message] = []
    private var requests: [Message] = []

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadTheInboxScreen()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak `self` = self] _ in
            self?.reloadTheInboxScreen()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath)
        guard let messageCell = cell as? MessageTableViewCell else {
            return cell
        }

        let message = (indexPath.section == 0 ? requests : messages)[indexPath.item]
        messageCell.threadTitleLabel.text = message.thread.title
        messageCell.latestMessageLabel.text = message.latestMessage
        if let image = UIImage(named: "oldman") {
            messageCell.setThreadImage(image)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Connection Requests", comment: "")
        }

        return NSLocalizedString("Messages", comment: "")
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

    private func appendMessage(thread: MThread, completionHandler: (() -> Void)?) {
        Environment.backend.read(MMessageRequest(threadId: thread.threadId,
                                                 queryLastMessage: true)) { (success, last: MMessage?) in
            guard success, let lastMessage = last else {
                self.messages.append(Message(thread: thread,
                                             latestMessage: NSLocalizedString("No Messages Sent", comment: "")))
                completionHandler?()
                return
            }

            self.messages.append(Message(thread: thread, latestMessage: lastMessage.content))
            completionHandler?()
        }
    }

    func reloadTheInboxScreen() {
        Environment.backend.read(MThreadRequest()) { [weak `self` = self] (success, threads: [MThread]?) in
            guard success, let threads = threads else {
                return
            }

            let group = DispatchGroup()

            self?.messages = []
            self?.requests = []

            for thread in threads {
                if thread.status == .accepted {
                    group.enter()
                    self?.appendMessage(thread: thread) {
                        group.leave()
                    }
                } else {
                    self?.requests.append(Message(thread: thread,
                                                  latestMessage: "I need help. I am about 100 metres away."))
                }
            }

            group.wait()

            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var threadTitleLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var threadImage: UIImageView!

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
}
