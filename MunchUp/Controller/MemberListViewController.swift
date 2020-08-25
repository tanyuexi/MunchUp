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
    
    
    var days = 0.0
    var ageThreshold: [Int: Date] = [:]
    var memberArray : [FamilyMember] = []
    var dailyTotalServes: [String: Double] = [:]
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shopButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(K.documentDir)

        tableView.dataSource = self
        tableView.delegate = self
        
        //if days not set, let days = 7
        days = getDays()
        if days == 0 {
            updateDays(7)
            days = 7.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadFamilyMembers(to: &memberArray)
        tableView.reloadData()
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
    
    
    func yearsBeforeToday(_ years: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let component = DateComponents(year: -years)
        return calendar.date(byAdding: component, to: today)!
    }
    
    func olderRangeInAgeZone(_ date: Date) -> Bool {
        for i in [4, 9, 12, 14, 19] {
            let diff = Calendar.current.dateComponents([.year], from: date, to: ageThreshold[i]!)
            if diff.year! == 0 {
                return true
            }
        }
        return false
    }
    
    func calculateDailyTotalServes() {
        
        dailyTotalServes = [:]
        
        for i in [1, 2, 4, 9, 12, 14, 19, 51, 70] {
            ageThreshold[i] = yearsBeforeToday(i)
        }

        //calculate total serves
        for member in memberArray {
            var ageZone = 0
            let olderRange = olderRangeInAgeZone(member.dateOfBirth!)
            if member.pregnant || member.breastfeeding {
                if member.dateOfBirth! <= ageThreshold[19]! {
                    ageZone = 19
                } else {
                    ageZone = 1
                }
            } else {
                for i in ageThreshold.keys.sorted() {
                    if member.dateOfBirth! <= ageThreshold[i]! {
                        ageZone = i
                    }
                }
            }
            
            //if less than 1 yrs old, next member
            if ageZone == 0 {continue}
            
            var key = "\(ageZone) "
            key += member.female ? "F": "M"
            if member.pregnant {key += "P"}
            if member.breastfeeding {key += "B"}
            
            for group in K.foodGroups {
                if dailyTotalServes[group] == nil {
                    dailyTotalServes[group] = 0.0
                }
                
                dailyTotalServes[group]! += K.dailyServes[group]![key]!
                
                if (member.additional || olderRange),
                    group != K.foodGroups[5] {   //oil
                    
                    dailyTotalServes[group]! += K.dailyServes[K.additionalString]![key]!/5
                }
            }
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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToMemberDetailVC",
            let destinationVC = segue.destination as? EditMemberTableViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            if indexPath.row < memberArray.count {
                destinationVC.selectedMember = [memberArray[indexPath.row]]
            }
        } else if segue.identifier == "GoToShoppingListVC",
            let destinationVC = segue.destination as? ShoppingListViewController {
            
            calculateDailyTotalServes()
            destinationVC.dailyTotalServes = dailyTotalServes
            
        } 
    }
}



