import UIKit

class MessageScreenController: UIViewController {

    private var shifter = KeyboardShifter()
    @IBOutlet var topConstraint: NSLayoutConstraint!
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
        Message(me: true, text: "Good thanks, how about you????????????????????????????????????????????????????????"),
        Message(me: false, text: "Good. Btw have you heard of.........................................."),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        shifter.delegate = self
        shifter.register()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (tableView.contentSize.height - tableView.bounds.size.height > 0) {
            let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height)
            tableView.setContentOffset(bottomOffset, animated: true)
        }
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


extension MessageScreenController: KeyboardShifterDelegate {
    
    func keyboard(_ keyboardShifter: KeyboardShifter, shiftedBy delta: CGFloat, duration: Double, options: UIViewAnimationOptions) {
        view.frame.origin.y += delta
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: options,
                       animations: {},
                       completion: { [weak view = view] _ in
                        view?.layoutIfNeeded()
        })
    }
}

extension MessageScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: msg.me ? "sender" : "receiver", for: indexPath) as! MessageScreenMessageView
        cell.textField.text = msg.text
        cell.textView.layer.cornerRadius = 20
        let textWidth = cell.textField.frame.size.width
        if textWidth > cell.frame.size.width {
            
        }
        let newSize = cell.textField.sizeThatFits(CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude))
//        print (cell.frame.size.width)
//        print (newSize.width)
        cell.textView.frame.size = CGSize(width: max(textWidth, newSize.width), height: newSize.height)
        
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
