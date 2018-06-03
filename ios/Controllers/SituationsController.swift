import UIKit

class SituationsController: UIViewController {

    private var situations: [MSituation] = []
    @IBOutlet weak var situationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        BackendServices.get(MSituationRequest()) { [weak `self` = self] (success, situations: [MSituation]?) in
            guard success, let situations = situations else {
                return
            }

            DispatchQueue.main.async {
                self?.situations = situations
                self?.situationTableView.reloadData()
            }
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

// MARK: - UITableViewDataSource Conformance
extension SituationsController: UITableViewDataSource {
    //number of row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return situations.count
    }

    //what are the cotent of each cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "adviceCell", for: indexPath)

        let situation = situations[indexPath.row]
        cell.textLabel?.text  = situation.id
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
