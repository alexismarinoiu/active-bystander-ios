import UIKit

class SituationsController: UIViewController {

    var situations: [MSituation] = []
    @IBOutlet weak var situationTableView: UITableView!
    var fetchFlag: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        if fetchFlag {
            Environment.backend.read(MSituationRequest()) { [weak `self` = self] (success, situations: [MSituation]?) in
                guard success, let situations = situations else {
                    return
                }

                DispatchQueue.main.async {
                    self?.situations = situations
                    self?.situationTableView.reloadData()
                }
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "adviceSegue" {
            guard let destination = segue.destination as? AdviceScreenController,
                  let indexPath = situationTableView.indexPathForSelectedRow else {
                return
            }

            let situation = situations[indexPath.row]
            destination.html = situation.html!
        }

        if segue.identifier == "groupSegue" {
            guard let destination = segue.destination as? SituationsController,
                let indexPath = situationTableView.indexPathForSelectedRow else {
                return
            }

            let situation = situations[indexPath.row]
            destination.fetchFlag = false
            destination.situations = situation.children.sorted { $0.title < $1.title }
        }
    }

}

// MARK: - UITableViewDataSource Conformance
extension SituationsController: UITableViewDataSource {
    //number of row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return situations.count
    }

    //what are the cotent of each cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let situation = situations[indexPath.row]
        let cell: UITableViewCell
        if situation.children.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "adviceCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        }

        cell.textLabel?.text = situation.title
        return cell
    }

    // number of column
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SituationsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView.cellForRow(at: indexPath) != nil else {
            return
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
