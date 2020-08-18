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
    
    let myN = NumberFormatsTYX()
    let P = PublicData()
    
    var itemArray: [OtherItem] = []
    let foodIcon = ["🥬","🍎","🍗","🍞","🥛","🥜"]

    override func viewDidAppear(_ animated: Bool) {

        let titleLocalize = NSLocalizedString("Shop for", comment: "navigation title")
        let daysLocalize = NSLocalizedString("days", comment: "navigation title")
        navigationItem.title = "\(titleLocalize) \(Int(P.days)) \(daysLocalize)"
        print(P.days)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "OtherItemCell", bundle: nil), forCellReuseIdentifier: K.otherItemCellID)
        

        
        loadItems()
        if itemArray.count == 0 {
            let emptyItem = OtherItem(context: P.context)
            emptyItem.lastEdited = Date()
            itemArray.append(emptyItem)
        }
        
        //initialize serve sizes
        let appLanguage = Locale.preferredLanguages[0]
        if P.defaults.string(forKey: "Localization") != appLanguage {
            P.reloadServeSizes()
            P.defaults.set(appLanguage, forKey: "Localization")
        }
        
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
            
            if let serves = P.dailyTotalServes[group] {
                
                let total = serves * P.days
                let servesLocalize = NSLocalizedString("serves", comment: "a unit of food")
                
                if group == NSLocalizedString("Oil", comment: "food group") {
                    let upToLocalize = NSLocalizedString("up to", comment: "oil serves")
                    cell.detailTextLabel?.text = "\(upToLocalize) \(myN.limitDigits(total)) \(servesLocalize)"
                } else {
                    cell.detailTextLabel?.text = "\(myN.limitDigits(total)) \(servesLocalize)"
                }
                
            } else {
                
                cell.detailTextLabel?.text = ""
            }
            
            return cell
            
        //other items
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.otherItemCellID, for: indexPath) as! OtherItemCell
            let item = itemArray[indexPath.row - K.foodGroups.count]
            cell.done = item.done
            cell.checkMarkImage.image = item.done ? P.checkedSymbol: P.uncheckedSymbol
            if item.title == nil {
                cell.checkMarkImage.isHidden = true
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
        if itemIndex < 0 {
            performSegue(withIdentifier: "GoToServesCalculatorVC", sender: self)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! OtherItemCell
            cell.done = !cell.done
            cell.checkMarkImage.image = cell.done ? P.checkedSymbol: P.uncheckedSymbol
            itemArray[itemIndex].done = cell.done
            saveItems(false)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToServesCalculatorVC",
            let destinationVC = segue.destination as? ServesCalculatorViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            let group = K.foodGroups[indexPath.row]
            destinationVC.category = group
            destinationVC.targetServes = P.dailyTotalServes[group]! * P.days
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
            P.context.delete(itemArray[itemIndex])
            itemArray.remove(at: itemIndex)
            saveItems()
        }else if textField.text != "" {
            itemArray[itemIndex].title = textField.text
            itemArray[itemIndex].lastEdited = Date()
            if itemIndex == 0 {
                //add new item
                itemArray.insert(OtherItem(context: P.context), at: 0)
            } else {
                //put edited item first
                itemArray.insert(itemArray[itemIndex], at: 1)
                itemArray.remove(at: itemIndex + 1)
            }
            itemArray[0].lastEdited = Date().advanced(by: 1)
            saveItems()
        }
    }
    
    
}

//MARK: - Core Data Actions

extension ShoppingListViewController {
    
    func loadItems() {
        let request : NSFetchRequest<OtherItem> = OtherItem.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "lastEdited", ascending: false)
        request.sortDescriptors = [sortByDate]
        do{
            itemArray = try P.context.fetch(request)
        } catch {
            print("Error loading OtherItem \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    func saveItems(_ reload: Bool = true) {
        
        do {
          try P.context.save()
        } catch {
           print("Error saving P.context \(error)")
        }
        
        if reload {
            tableView.reloadData()
        }
    }
    
    
    
    
    
}
