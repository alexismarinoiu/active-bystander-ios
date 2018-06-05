import UIKit

class HomeScreenController: UIViewController {

    // swiftlint:disable line_length
    static let strings = [
        "directAction": NSLocalizedString("Directly intervene, for example, by asking the person to stop. Immediately act or call out negative behaviour, explaining why it is not OK.", comment: ""),
        "delay": NSLocalizedString("Wait for the situation to pass and check, with individual. Take action at a later stage when you have had time to consider. It’s never too late to act.", comment: ""),
        "distraction": NSLocalizedString("Indirectly intervene, for example, de-escalating by interrupting or changing the subject or focus. Useful where the direct approach may be harmful to the target or bystander.", comment: ""),
        "delegation": NSLocalizedString("Inform a more senior member of staff, for example, your Head of Department, Director or Manager. Use someone with the social power or authority to deal with it.", comment: "")
    ]
    // swiftlint:enable line_length

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
            let fourDsController = segue.destination as? FourDDescriptionScreenController else {
            return
        }

        fourDsController.textBodyDescription = HomeScreenController.strings[identifier]!

        switch identifier {
        case "directAction":
            segue.destination.navigationItem.title = "Direct Action"
            fourDsController.view.backgroundColor = #colorLiteral(red: 0, green: 0.2392156863, blue: 0.4431372549, alpha: 1)
        case "delay":
            segue.destination.navigationItem.title = "Delay"
            fourDsController.view.backgroundColor = #colorLiteral(red: 0, green: 0.7333333333, blue: 0.7843137255, alpha: 1)
        case "distraction":
            segue.destination.navigationItem.title = "Distraction"
            fourDsController.view.backgroundColor = #colorLiteral(red: 0, green: 0.05882352941, blue: 0.2039215686, alpha: 1)
        case "delegation":
            segue.destination.navigationItem.title = "Delegation"
            fourDsController.view.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.1764705882, blue: 0.2941176471, alpha: 1)
        default:
            return
        }
    }

}
