import UIKit

class MessageScreenController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    struct Message {
        let me: Bool
        let text: String
    }
    
    var messages: [Message] = [
        Message(me: true, text: "Hello"),
        Message(me: true, text: "Hello"),
        Message(me: true, text: "Hello"),
        Message(me: true, text: "Hello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello\nHello"),
        Message(me: false, text: "What's up?"),
        Message(me: true, text: "Hello"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
//        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MessageScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: msg.me ? "sender" : "receiver", for: indexPath) as! MessageScreenMessageView
        cell.textField.text = msg.text
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
}

//extension MessageScreenController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 99
//    }
//}

class MessageScreenMessageView: UITableViewCell {
    @IBOutlet var textField: UILabel!
//
//    radi
}
