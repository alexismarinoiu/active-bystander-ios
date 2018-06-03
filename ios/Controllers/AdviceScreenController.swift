import UIKit
import WebKit

class AdviceScreenController: UIViewController {
    var html = "<html><header><title>ERROR</title></header><body>There's no HTML provided.</body></html>"
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.loadHTMLString(html, baseURL: nil)
    }
}
