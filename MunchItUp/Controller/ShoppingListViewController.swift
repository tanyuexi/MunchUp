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
    
    var memberArray : [FamilyMember] = []
    var ageThreshold: [Int: Date] = [:]
    var totalServes: [String: Double] = [:]
    var itemArray: [OtherItem] = []
    var serveSizes: [OneServe] = []
    let foodGroups = ["Vegetable", "Fruit", "Protein", "Grain", "Calcium", "Oil"]
    let foodIcon = ["🥬","🍎","🍗","🍞","🥛","🥜"]
    let checkedSymbol = UIImage(systemName: "checkmark.circle.fill")
    let uncheckedSymbol = UIImage(systemName: "circle")
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let myN = NumberFormatsTYX()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "OtherItemCell", bundle: nil), forCellReuseIdentifier: K.otherItemCellID)
        
        for i in [1, 2, 4, 9, 12, 14, 19, 51, 70] {
            ageThreshold[i] = yearsBeforeToday(i)
        }
        
        loadItems()
        if itemArray.count == 0 {
            let emptyItem = OtherItem(context: context)
            emptyItem.lastEdited = Date()
            itemArray.append(emptyItem)
        }
        
        //initialize serve sizes
        if !defaults.bool(forKey: "Serve sizes initialized") {
            storeServeSizes()
            defaults.set(true, forKey: "Serve sizes initialized")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        totalServes = [:]
        
        //calculate total serves
        let days = Double(defaults.integer(forKey: "Days"))
        navigationItem.title = "Shop for \(Int(days)) days"

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
            
            for group in foodGroups {
                if totalServes[group] == nil {
                    totalServes[group] = 0.0
                }
                totalServes[group]! += K.dailyServes[group]![key]! * days
                if (member.additional || olderRange), group != "Nut" {
                    totalServes[group]! += K.dailyServes["Additional"]![key]!/5 * days
                }
            }
        }
        
        tableView.reloadData()
    }
}

//MARK: - Functions

extension ShoppingListViewController {
    
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
    
    func formatWeight(_ grams: Double) -> String {
        if grams < 1000 {
            return myN.limitDigits(grams)
        } else {
            return myN.limitDigits(grams/1000)

        }
    }
    

}

//MARK: - TableView Data Source

extension ShoppingListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodGroups.count + itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //food groups
        if indexPath.row < foodGroups.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.foodGroupCellID, for: indexPath)
            let group = foodGroups[indexPath.row]
            cell.textLabel?.text = "\(foodIcon[indexPath.row])  \(group)"
            if let serves = totalServes[group] {
                if group == "Oil" {
                    cell.detailTextLabel?.text = "up to \(myN.limitDigits(serves)) serves"
                } else {
                    cell.detailTextLabel?.text = "\(myN.limitDigits(serves)) serves"
                }
            } else {
                cell.detailTextLabel?.text = ""
            }
            return cell
        //other items
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.otherItemCellID, for: indexPath) as! OtherItemCell
            let item = itemArray[indexPath.row - foodGroups.count]
            cell.done = item.done
            cell.checkMarkImage.image = item.done ? checkedSymbol: uncheckedSymbol
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
        
        let itemIndex = indexPath.row - foodGroups.count
        if itemIndex < 0 {
            performSegue(withIdentifier: "GoToServesCalculatorVC", sender: self)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! OtherItemCell
            cell.done = !cell.done
            cell.checkMarkImage.image = cell.done ? checkedSymbol: uncheckedSymbol
            itemArray[itemIndex].done = cell.done
            saveItems(false)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToServesCalculatorVC",
            let destinationVC = segue.destination as? ServesCalculatorViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            let group = foodGroups[indexPath.row]
            destinationVC.category = group
            destinationVC.targetServes = totalServes[group] ?? 0.0
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
        let itemIndex = textField.tag - foodGroups.count

        if textField.text == "", itemIndex > 0 {
            context.delete(itemArray[itemIndex])
            itemArray.remove(at: itemIndex)
            saveItems()
        }else if textField.text != "" {
            itemArray[itemIndex].title = textField.text
            itemArray[itemIndex].lastEdited = Date()
            if itemIndex == 0 {
                //add new item
                itemArray.insert(OtherItem(context:context), at: 0)
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
            itemArray = try context.fetch(request)
        } catch {
            print("Error loading OtherItem \(error)")
        }
        self.tableView.reloadData()
    }
    
    func saveItems(_ reload: Bool = true) {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        if reload {
            tableView.reloadData()
        }
    }
    
    func loadServeSizes() {
        let request : NSFetchRequest<OneServe> = OneServe.fetchRequest()

        do{
            serveSizes = try context.fetch(request)
        } catch {
            print("Error loading OneServe \(error)")
        }
    }
    
    func storeServeSizes(){
    
        let serveSizesPath = Bundle.main.path(forResource: "ServeSizes_Australia", ofType: "txt")
        
        if freopen(serveSizesPath, "r", stdin) == nil {
            perror(serveSizesPath)
        }
        
        //delete previous whatever serve sizes
        loadServeSizes()
        for i in serveSizes {
            context.delete(i)
        }
        
        serveSizes = []
        
        while let line = readLine() {
            let fields: [String] = line.components(separatedBy: "\t")
            let newServe = OneServe(context: context)
            newServe.category = fields[0]
            newServe.order = Int16(Int(fields[1]) ?? 0)
            newServe.quantity1 = Double(fields[2]) ?? 0.0
            newServe.unit1 = fields[3]
            newServe.quantity2 = Double(fields[4]) ?? 0.0
            newServe.unit2 = fields[5]
            newServe.detail = fields[6]
            newServe.custom = false
            newServe.serves = -1
            serveSizes.append(newServe)
        }
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        serveSizes = []
    }
}
