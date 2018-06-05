import UIKit

class MessageScreenController: UIViewController {

    private var shifter = KeyboardShifter()
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textInput: UITextField!

    struct Message {
        let isMe: Bool
        let text: String
    }

    var messages: [Message] = [
        Message(isMe: true, text: "Hello"),
        Message(isMe: false, text: "Hello")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        messageTableView.dataSource = self
        shifter.delegate = self
        shifter.register()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBegan))
        messageTableView.addGestureRecognizer(tapGesture)
    }

    @objc func tapBegan () {
        self.view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        let contentOffset = messageTableView.contentSize.height - messageTableView.bounds.size.height
        if contentOffset > 0 {
            let bottomOffset = CGPoint(x: 0, y: contentOffset)
            messageTableView.setContentOffset(bottomOffset, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendPressed(_ sender: Any) {
        if textInput.text?.isEmpty == true {
            return
        }

        messages.append(contentsOf: [Message(isMe: true, text: textInput.text!)])
        self.messageTableView.reloadData()
        textInput.text = ""
    }

}

extension MessageScreenController: KeyboardShifterDelegate {
    func keyboard(_ keyboardShifter: KeyboardShifter,
                  shiftedBy delta: CGFloat,
                  duration: Double,
                  options: UIViewAnimationOptions) {
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
