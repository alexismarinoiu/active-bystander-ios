import UIKit

class InboxScreenController: UITableViewController {
    // notTODO: Part of the model, should be moved at some point
    struct Message {
        let title: String
        let latestMessage: String
    }

    var messages: [Message] = []
    var requests: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadTheInboxScreen()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

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
        messageCell.threadTitleLabel.text = message.title
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
            let tableViewCell = sender as? MessageTableViewCell {
            segue.destination.navigationItem.title = tableViewCell.threadTitleLabel.text
        }
    }

    func appendMessage(thread: MThread, completionHandler: (() -> Void)?) {
        Environment.backend.read(MMessageRequest(threadId: thread.threadId, flag: true)) { (success, last: MMessage?) in
            guard success, let lastMessage = last else {
                return
            }

            self.messages.append(Message(title: thread.title, latestMessage: lastMessage.content))
            completionHandler?()
        }
    }

    func reloadTheInboxScreen() {
        Environment.backend.read(MThreadRequest()) { [weak `self` = self] (success, threads: [MThread]?) in
            guard success, let threads = threads else {
                return
            }

            let group = DispatchGroup()
            for thread in threads {
                if thread.status == .accepted {
                    group.enter()
                    self?.appendMessage(thread: thread) {
                        group.leave()
                    }
                } else {
                    self?.requests.append(Message(title: thread.title,
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
