import UIKit

class HomeScreenController: UIViewController {

    // swiftlint:disable line_length
    static let strings = [
        "directAction": " Directly intervene, for example, by asking the person to stop. Immediately act or call out negative behaviour, explaining why it is not OK.",
        "delay": " Wait for the situation to pass and check, with individual. Take action at a later stage when you have had time to consider. It’s never too late to act.",
        "distraction": " Indirectly intervene, for example, de-escalating by interrupting or changing the subject or focus. Useful where the direct approach may be harmful to the target or bystander.",
        "delegation": " Inform a more senior member of staff, for example, your Head of Department, Director or Manager. Use someone with the social power or authority to deal with it."
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

        switch identifier {
        case "directAction":
            segue.destination.navigationItem.title = "Direct Action"
            fourDsController.textBodyDescription = HomeScreenController.strings[identifier]!
            fourDsController.view.backgroundColor = UIColor(red: 0, green: 61/255, blue: 113/255, alpha: 1)
        case "delay":
            segue.destination.navigationItem.title = "Delay"
            fourDsController.textBodyDescription = HomeScreenController.strings[identifier]!
            fourDsController.view.backgroundColor = UIColor(red: 0, green: 187/255, blue: 200/255, alpha: 1)
        case "distraction":
            segue.destination.navigationItem.title = "Distraction"
            fourDsController.textBodyDescription = HomeScreenController.strings[identifier]!
            fourDsController.view.backgroundColor = UIColor(red: 0, green: 15/255, blue: 52/255, alpha: 1)
        case "delegation":
            segue.destination.navigationItem.title = "Delegation"
            fourDsController.textBodyDescription = HomeScreenController.strings[identifier]!
            fourDsController.view.backgroundColor = UIColor(red: 243/255, green: 45/255, blue: 75/255, alpha: 1)
        default:
            return
        }
    }

}
