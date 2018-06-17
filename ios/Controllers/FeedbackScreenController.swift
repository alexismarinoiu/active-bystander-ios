import UIKit
import WebKit

class FeedbackScreenController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    let abURL = "https://www.imperial.ac.uk/engineering/staff/human-resources/active-bystander/"

    override func viewDidLoad() {
        super.viewDidLoad()

        let webViewURL = URL(string: abURL)
        let myRequest = URLRequest(url: webViewURL!)
        webView.navigationDelegate = self
        webView.load(myRequest)
    }
}

extension FeedbackScreenController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.url?.absoluteString == abURL {
            // swiftlint:disable line_length
            let javaScript = "var form = document.getElementsByClassName(\"qualtrics-widget responsive-iframe\")[0]; form.scrollIntoView();"
            // swiftlint:enable line_length
            webView.evaluateJavaScript(javaScript, completionHandler: nil)
        }
    }
}
