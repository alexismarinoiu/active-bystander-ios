import UIKit
import WebKit

class FeedbackScreenController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let myURL = URL(string: "https://www.imperial.ac.uk/engineering/staff/human-resources/active-bystander/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
