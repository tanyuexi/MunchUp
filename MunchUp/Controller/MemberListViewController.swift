//
//  FamilyMembersViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/17.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class MemberListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shopButton: UIButton!
    
    var memberArray : [FamilyMember] = []
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        tableView.dataSource = self
        tableView.delegate = self
        
        //initialize settings
        if !defaults.bool(forKey: NSLocalizedString("Settings initialized", comment: "plist")) {
            defaults.set(7, forKey: NSLocalizedString("Days", comment: "plist"))
            defaults.set(true, forKey: NSLocalizedString("Settings initialized", comment: "plist"))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadFamilyMembers()
        disableShopButton(with: memberArray.count == 0)
    }
    
    func disableShopButton(with disable: Bool){
        if disable {
            shopButton.isEnabled = false
            shopButton.backgroundColor = .systemGray
        } else {
            shopButton.isEnabled = true
            shopButton.backgroundColor = .systemRed
        }
    }
}

//MARK: - TableView Data Source

extension MemberListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberArray.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < memberArray.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.memberCellID, for: indexPath)
            let familyMember = memberArray[indexPath.row]
            cell.textLabel?.text = familyMember.name
            cell.detailTextLabel?.text = ""
            if familyMember.pregnant {
                cell.detailTextLabel?.text! += "🤰"
            }
            if familyMember.breastfeeding {
                cell.detailTextLabel?.text! += "🤱"
            }
            if familyMember.additional {
                cell.detailTextLabel?.text! += "🏃"
            }
            let diff = Calendar.current.dateComponents([.year], from: familyMember.dateOfBirth!, to: Date())
            let yrsLocalize = NSLocalizedString("yrs", comment: "a unit for age")
            cell.detailTextLabel?.text! += "\(diff.year!) \(yrsLocalize)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.addingMemberCellID, for: indexPath)
            return cell
        }
    }
}

//MARK: - TableView Delegate Methods

extension MemberListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToMemberDetailVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(memberArray[indexPath.row])
            memberArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            do {
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToMemberDetailVC",
            let destinationVC = segue.destination as? EditMemberTableViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            if indexPath.row < memberArray.count {
                destinationVC.selectedMember = [memberArray[indexPath.row]]
            }
        } else if segue.identifier == "GoToShoppingListVC",
            let destinationVC = segue.destination as? ShoppingListViewController {
            destinationVC.memberArray = memberArray
        }
    }
}

//MARK: - Model Manupulation Methods

extension MemberListViewController {

    func loadFamilyMembers() {
        let request : NSFetchRequest<FamilyMember> = FamilyMember.fetchRequest()
        let sortByAge = NSSortDescriptor(key: "dateOfBirth", ascending: true)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByAge, sortByName]
        do{
            memberArray = try context.fetch(request)
        } catch {
            print("Error loading FamilyMembers \(error)")
        }
        tableView.reloadData()
    }
    
}
