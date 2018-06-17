import UIKit
import WebKit

class FeedbackScreenController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    static let webViewURL =
        URL(string: "https://www.imperial.ac.uk/engineering/staff/human-resources/active-bystander/")!

    override func viewDidLoad() {
        super.viewDidLoad()

        let myRequest = URLRequest(url: FeedbackScreenController.webViewURL)
        webView.navigationDelegate = self
        webView.load(myRequest)
    }
}

extension FeedbackScreenController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url == FeedbackScreenController.webViewURL {
            let jscpt = "document.getElementsByClassName(\"qualtrics-widget responsive-iframe\")[0].scrollIntoView();"
            webView.evaluateJavaScript(jscpt, completionHandler: nil)
        }
    }
}
