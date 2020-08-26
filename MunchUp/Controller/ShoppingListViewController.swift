//
//  ShoppingListViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/26.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListViewController: UITableViewController {
    
    var days = 0.0
    var itemArray: [OtherItem] = []
    var dailyTotalServes: [String: Double] = [:]
    
    let foodIcon = ["🥬","🍎","🍗","🍞","🥛","🥜"]

    override func viewDidAppear(_ animated: Bool) {
        
        days = getDays()

        let titleLocalize = NSLocalizedString("Shop for", comment: "navigation title")
        let daysLocalize = NSLocalizedString("days", comment: "navigation title")
        navigationItem.title = "\(titleLocalize) \(Int(days)) \(daysLocalize)"
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "OtherItemCell", bundle: nil), forCellReuseIdentifier: K.otherItemCellID)
        

        loadItems(to: &itemArray)
        tableView.reloadData()
        if itemArray.count == 0 {
            let emptyItem = OtherItem(context: K.context)
            emptyItem.lastEdited = Date()
            itemArray.append(emptyItem)
        }
        
        //initialize serve sizes
        let appLanguage = Locale.preferredLanguages[0]
        if K.defaults.string(forKey: "Localization") != appLanguage {
            reloadServeSizes()
            K.defaults.set(appLanguage, forKey: "Localization")
        }
        
    }
    
    
    func setCellDoneState(_ checked: Bool, at indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! OtherItemCell
        cell.item?.done = checked
        cell.checkMark.image = checked ? K.checkedSymbol: K.uncheckedSymbol
//        itemArray[arrayIndex].done = checked
        saveContext()
    }
}

//MARK: - TableView Data Source

extension ShoppingListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return K.foodGroups.count + itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //food groups
        if indexPath.row < K.foodGroups.count {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: K.foodGroupCellID, for: indexPath)
            let group = K.foodGroups[indexPath.row]
            
            cell.textLabel?.text = "\(foodIcon[indexPath.row])  \(group)"
            
            if let serves = dailyTotalServes[group] {
                let total = serves * days
                var detail = "\(limitDigits(total)) \(K.servesString)"
                if group == K.foodGroups[5] {
                    let upToLocalize = NSLocalizedString("up to", comment: "oil serves")
                    detail = "\(upToLocalize) \(detail)"
                }
                cell.detailTextLabel?.text = detail
            }
            
            return cell
            
        //other items
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.otherItemCellID, for: indexPath) as! OtherItemCell
            let item = itemArray[indexPath.row - K.foodGroups.count]
            cell.item = item

            if item.title == nil {  //for adding new item
                cell.checkMark.isHidden = true
            } else if item.done {
                cell.checkMark.image = K.checkedSymbol
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            cell.titleTextField.text = item.title
            cell.titleTextField.tag = indexPath.row
            cell.titleTextField.delegate = self
            return cell
        }
    }
}

//MARK: - TableView Delegate Methods

extension ShoppingListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemIndex = indexPath.row - K.foodGroups.count
        
        //if food, go to servers calculator
        if itemIndex < 0 {
            performSegue(withIdentifier: "GoToServesCalculatorVC", sender: self)
            
        //if other items
        } else {
            setCellDoneState(true, at: indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let itemIndex = indexPath.row - K.foodGroups.count
        
        //if other items
        if itemIndex >= 0 {
            setCellDoneState(false, at: indexPath)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToServesCalculatorVC",
            let destinationVC = segue.destination as? ServesCalculatorViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            let group = K.foodGroups[indexPath.row]
            destinationVC.category = group
            destinationVC.targetServes = dailyTotalServes[group]! * days
        }
    }
}

//MARK: - Text Field Delegate Methods

extension ShoppingListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.endEditing(true)
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let itemIndex = textField.tag - K.foodGroups.count

        if textField.text == "", itemIndex > 0 {
            K.context.delete(itemArray[itemIndex])
            itemArray.remove(at: itemIndex)
            saveContext()
            tableView.reloadData()
        } else if textField.text != "" {
            itemArray[itemIndex].title = textField.text
            itemArray[itemIndex].lastEdited = Date()
            if itemIndex == 0 {
                //add new item
                itemArray.insert(OtherItem(context: K.context), at: 0)
            } else {
                //put edited item first
                itemArray.insert(itemArray[itemIndex], at: 1)
                itemArray.remove(at: itemIndex + 1)
            }
            itemArray[0].lastEdited = Date().advanced(by: 1)
            saveContext()
            tableView.reloadData()
        }
    }
    
    
}

