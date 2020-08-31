//
//  PeopleTableVC.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/17.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class PeopleTableVC: UITableViewController {
    
    
    var peopleArray : [People] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func refresh(){
        print("refresh")
        loadPeople(to: &peopleArray)
        tableView.reloadData()
    }
    
}

//MARK: - TableView Data Source

extension PeopleTableVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peopleArray.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < peopleArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.peopleCellID, for: indexPath)
            let People = peopleArray[indexPath.row]
            cell.textLabel?.text = String(format: "%d. %@",
                                          indexPath.row + 1,
                                          People.name ?? "")
            cell.detailTextLabel?.text = ""
            if People.pregnant {
                cell.detailTextLabel?.text! += "🤰"
            }
            if People.breastfeeding {
                cell.detailTextLabel?.text! += "🤱"
            }
            if People.additional {
                cell.detailTextLabel?.text! += "🏃"
            }
            let diff = Calendar.current.dateComponents([.year], from: People.dateOfBirth!, to: Date())
            let yrsLocalize = NSLocalizedString("yrs", comment: "a unit for age")
            cell.detailTextLabel?.text! += "\(diff.year!) \(yrsLocalize)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.addPeopleCellID, for: indexPath)
            return cell
        }
    }
}

//MARK: - TableView Delegate Methods

extension PeopleTableVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "GoToEditPeopleVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToEditPeopleVC",
            let editVC = segue.destination as? EditPeopleTableVC,
            let indexPath = tableView.indexPathForSelectedRow {

            editVC.peopleVC = self
            if indexPath.row < peopleArray.count {
                editVC.selectedMember = [peopleArray[indexPath.row]]
            }
        }
    }
}



