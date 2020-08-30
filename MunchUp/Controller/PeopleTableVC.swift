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
    
    
    var days = 0.0
    var peopleArray : [People] = []
    var dailyTotalServes: [String: Double] = [:]
    
    
//    @IBOutlet weak var shopButton: UIButton!
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print(getFilePath(directory: true)!)
//
//        tableView.dataSource = self
//        tableView.delegate = self
//        
//
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        loadPeople(to: &memberArray)
//        tableView.reloadData()
//        disableShopButton(with: memberArray.count == 0)
//    }
//    
//    
//    func disableShopButton(with disable: Bool){
//        if disable {
//            shopButton.isEnabled = false
//            shopButton.backgroundColor = .systemGray
//        } else {
//            shopButton.isEnabled = true
//            shopButton.backgroundColor = .systemRed
//        }
//    }
//    
//    
//
//    
//}
//
////MARK: - TableView Data Source
//
//extension PeopleTableVC: UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return memberArray.count + 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if indexPath.row < memberArray.count {
//            let cell = tableView.dequeueReusableCell(withIdentifier: K.memberCellID, for: indexPath)
//            let People = memberArray[indexPath.row]
//            cell.textLabel?.text = People.name
//            cell.detailTextLabel?.text = ""
//            if People.pregnant {
//                cell.detailTextLabel?.text! += "🤰"
//            }
//            if People.breastfeeding {
//                cell.detailTextLabel?.text! += "🤱"
//            }
//            if People.additional {
//                cell.detailTextLabel?.text! += "🏃"
//            }
//            let diff = Calendar.current.dateComponents([.year], from: People.dateOfBirth!, to: Date())
//            let yrsLocalize = NSLocalizedString("yrs", comment: "a unit for age")
//            cell.detailTextLabel?.text! += "\(diff.year!) \(yrsLocalize)"
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: K.addingMemberCellID, for: indexPath)
//            return cell
//        }
//    }
//}
//
////MARK: - TableView Delegate Methods
//
//extension PeopleTableVC: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        performSegue(withIdentifier: "GoToMemberDetailVC", sender: self)
//    }
//
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "GoToMemberDetailVC",
//            let destinationVC = segue.destination as? EditMemberTableViewController,
//            let indexPath = tableView.indexPathForSelectedRow {
//            
//            if indexPath.row < memberArray.count {
//                destinationVC.selectedMember = [memberArray[indexPath.row]]
//            }
//        } else if segue.identifier == "GoToShoppingListVC",
//            let destinationVC = segue.destination as? ShoppingListViewController {
//            
//            calculateDailyTotalServes()
//            destinationVC.dailyTotalServes = dailyTotalServes
//            
//        } 
//    }
}



