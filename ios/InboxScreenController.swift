import UIKit

class InboxScreenController: UITableViewController {
    
    // Part of the model, should be moved at some point
    
    struct Message {
        let title: String
        let latestMessage: String
    }

    var messages: [Message] = []
    var requests: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Some dummy data for now
        messages.append(contentsOf: [
            Message(title: "Harold Jr", latestMessage: "Hello"),
            Message(title: "Mark Zuckerberg", latestMessage: "Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc Zucc"),
            Message(title: "Tester Testington", latestMessage: "Another Test")
            ])
        
        requests.append(contentsOf: [
            Message(title: "Annoying Orange", latestMessage: "Hey! Hey Apple! Hey!"),
            Message(title: "Vulnerable Person", latestMessage: "\"Vulnerable Person\" has requested to connect with you.")
            ])
        
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as! MessageTableViewCell
        let message = (indexPath.section == 0 ? requests : messages)[indexPath.item]
        cell.threadTitleLabel.text = message.title
        cell.latestMessageLabel.text = message.latestMessage
        if let image = UIImage(named: "oldman") {
            cell.setThreadImage(image)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Connection Requests", comment: "")
        }
        
        return NSLocalizedString("Messages", comment: "")
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
