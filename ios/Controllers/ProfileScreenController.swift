import UIKit

class ProfileScreenController: UIViewController {
    let helpArea = ["Sexual Harassment", "Verbal Assault", "Racism"]

    @IBOutlet weak var helpAreaTable: UITableView!

    @IBAction func logOutButtonPress(_ sender: UIButton) {
        Environment.userAuth.logOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        helpAreaTable.reloadData()
    }

}

extension ProfileScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpArea.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "helpAreaCell", for: indexPath)
        cell.textLabel?.text = helpArea[indexPath.row]
        return cell
    }

}
