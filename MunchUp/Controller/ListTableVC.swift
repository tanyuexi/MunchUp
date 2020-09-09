//
//  ServesCalculatorTableViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/2.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class ListTableVC: UITableViewController {
    
    var foodDict: [String: [Food]] = [:]
    var itemArray: [Item] = []
    var dailyTotal: [String: Double] = [:]
    var days = 0.0
    
    var expandSection: [Bool] = []
    var hideChecked = false
    var hiddenCell: [IndexPath: Bool] = [:]
    var currentServes: [String: Double] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setExpandState(true)

        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: K.notificationName, object: nil)
        
        postNotification(["pass data to ListTableVC": true])

        tableView.register(UINib(nibName: K.foodCellID, bundle: nil), forCellReuseIdentifier: K.foodCellID)
        tableView.register(UINib(nibName: K.itemCellID, bundle: nil), forCellReuseIdentifier: K.itemCellID)

//        for category in K.foodGroups {
//            currentServes[category] = sumUpServes(category)
//        }
    }
    
    
}

//MARK: - Functions

extension ListTableVC {
    
    func setExpandState(_ state: Bool){
        expandSection = []
        for _ in 1...(K.foodGroups.count + 1) {
            expandSection.append(state)
        }
    }
    
    
    
    //    func notifyChangeOfServes(_ category: String) {
    //
    ////        if let i = K.foodGroups.firstIndex(of: category),
    ////            let hv = tableView.headerView(forSection: i),
    ////            let button = hv.viewWithTag(i) as! UIButton?,
    ////            let title = button.currentTitle {
    ////
    ////            let total = limitDigits(sumUpServes(category))
    ////            let newTitle = title.replacingOccurrences(of: #"(\d|\.)+\)$"#, with: total + ")", options: .regularExpression, range: nil)
    ////            button.setTitle(newTitle, for: .normal)
    ////        }
    //        print("notifyChangeOfServes")
    //
    //    }

    func sumUpServes(_ category: String) -> Double {
        var total = 0.0
        if let array = foodDict[category] {
            for food in array {
                total += food.serves
            }
        }
        return total

    }
    
    
    func autoSet() {
        for (category, foodArray) in foodDict {
            if let dailyTarget = dailyTotal[category] {
                
                let targetServes = dailyTarget * days
                let servesPerItem = roundToHalf(targetServes/Double(foodArray.count))
                for food in foodArray {
                    food.serves = servesPerItem
                }
            }
        }
        saveFood()
        tableView.reloadData()
    }
    
    
    func clearServes() {
        for foodArray in foodDict.values {
            for food in foodArray {
                food.serves = 0
            }
        }
        saveFood()
        tableView.reloadData()
    }
    
    
    func setFoodCellDoneState(_ checked: Bool, at indexPath: IndexPath) {
        
        let category = K.foodGroups[indexPath.section]
        foodDict[category]![indexPath.row].done = checked
        let cell = tableView.cellForRow(at: indexPath) as! FoodCell
        cell.updateCheckmark(checked)
        if hideChecked, checked {
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }
    
    
    func setItemCellDoneState(_ checked: Bool, at indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = checked
        let cell = tableView.cellForRow(at: indexPath) as! ItemCell
        cell.updateCheckmark(checked)
        if hideChecked, checked {
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }
    
    
    func foodHeaderString(at section: Int) -> String{
        let category = K.foodGroups[section]
        let buttonTitle = String(
                format: "%@ %@ (%@: %@, %@: %@)",
                K.foodIcon[section],
                K.foodGroups[section],
                (section == 5 ?
                    NSLocalizedString("Up to", comment: "section header"):
                    NSLocalizedString("Target", comment: "section header")),
                limitDigits( (dailyTotal[category] ?? 0.0) * days ),
                K.nowString,
                limitDigits(currentServes[category] ?? 0.0)
        )
        return buttonTitle
    }
    
    
    func initCheckedState(with checked: Bool, at indexPath: IndexPath, cell: UITableViewCell) {
        if checked {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            if hideChecked {
                cell.isHidden = true
                hiddenCell[indexPath] = true
            } else {
                cell.isHidden = false
                hiddenCell[indexPath] = false
            }
        }
    }
    
}

//MARK: - TableView Data Source

extension ListTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return K.foodGroups.count + 1 //food, other items
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FoodSectionHeaderView.reuseIdentifier) as! FoodSectionHeaderView
        //
        //        headerView.button.setTitle(
        //            section < K.foodGroups.count ?
        //                foodHeaderString(at: section):
        //                NSLocalizedString("Other Items", comment: "section header"),
        //            for: .normal)
        //
        //        return headerView
        //
        let buttonTitle = section < K.foodGroups.count ?
            foodHeaderString(at: section):
            NSLocalizedString("Other Items", comment: "section header")
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
        viewHeader.backgroundColor = K.themeColor
        let button = UIButton(type: .custom)
        button.frame = viewHeader.bounds
        button.tag = section // Assign section tag to this button
        button.addTarget(self, action: #selector(tapSection(sender:)), for: .touchUpInside)
        button.setTitle(buttonTitle, for: .normal)
        viewHeader.addSubview(button)
        return viewHeader
    }
    
    @objc func tapSection(sender: UIButton) {
        expandSection[sender.tag] = !expandSection[sender.tag]
        tableView.reloadSections([sender.tag], with: .none)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if foodDict.count == 0 {
            return 0
        } else if section < K.foodGroups.count {
            let category = K.foodGroups[section]
            return expandSection[section] ? (foodDict[category]?.count ?? 0): 0
        } else {
            return expandSection[section] ? itemArray.count: 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if foodDict.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.emptyCellID, for: indexPath)
            return cell
            
        } else if indexPath.section < K.foodGroups.count {
            let category = K.foodGroups[indexPath.section]
            let foodData = foodDict[category]![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: K.foodCellID, for: indexPath) as! FoodCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.foodData = foodData
            cell.updateAll()
            initCheckedState(with: foodData.done, at: indexPath, cell: cell)
            return cell
            
        } else {
            let item = itemArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellID, for: indexPath) as! ItemCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.titleTextField.text = item.title
            initCheckedState(with: item.done, at: indexPath, cell: cell)
            
            return cell
        }
    }
    
}

//MARK: - TableView Delegate Methods

extension ListTableVC {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return getRowHeight(indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return getRowHeight(indexPath)
    }
    
    
    func getRowHeight(_ indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section < K.foodGroups.count,
            let isHidden = hiddenCell[indexPath],
            isHidden,
            hideChecked {
            
            return 0.0
        } else {
            return UITableView.automaticDimension
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if foodDict.count != 0, indexPath.section < K.foodGroups.count {
            
            setFoodCellDoneState(true, at: indexPath)
        }
        
        if indexPath.section == K.foodGroups.count {
            setItemCellDoneState(true, at: indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if foodDict.count != 0, indexPath.section < K.foodGroups.count {
            
            setFoodCellDoneState(false, at: indexPath)
        }
        
        if indexPath.section == K.foodGroups.count {
            setItemCellDoneState(false, at: indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if foodDict.count != 0, indexPath.section < K.foodGroups.count {
            
            let category = K.foodGroups[indexPath.section]
            let foodData = foodDict[category]![indexPath.row]
            
            if editingStyle == .delete {
                
                if foodData.custom,
                    let imgUrl = getFilePath(foodData.image),
                    FileManager.default.fileExists(atPath: imgUrl.path) {
                    
                    do {
                        try FileManager.default.removeItem(at: imgUrl)
                    } catch {
                        print(error)
                    }
                }
                
                K.context.delete(foodData)
                foodDict[category]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .none)
                saveFood()
            }
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if foodDict.count != 0, indexPath.section < K.foodGroups.count {
            
            let category = K.foodGroups[indexPath.section]
            let foodData = foodDict[category]![indexPath.row]
            if foodData.done {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
}

//MARK: - FoodCellDelegate

extension ListTableVC: FoodCellDelegate {
    
    func onServesChange(_ category: String){
        currentServes[category] = sumUpServes(category)
        saveFood()
    }
    
    func saveFood(){
        postNotification(["foodDict update": foodDict])
        saveContext()
    }
}

//MARK: - ItemCellDelegate

extension ListTableVC: ItemCellDelegate {
    
    func addItem(_ newTitle: String) {
        itemArray[0].title = newTitle
        itemArray[0].lastEdited = Date()
        itemArray.insert(Item(context: K.context), at: 0)
        itemArray[0].lastEdited = Date().advanced(by: 1)
    }
    
    
    func deleteItem(at index: Int) {
        K.context.delete(itemArray[index])
        itemArray.remove(at: index)
    }
    
    
    func saveItemAndReloadTable(){
        postNotification(["itemArray update": itemArray])
        saveContext()
        tableView.reloadSections([K.foodGroups.count], with: .none)
    }
    
    
}

//MARK: - Notification center

extension ListTableVC {
    
    @objc func onNotification(notification: Notification) {
        
        var updateInterface = false
        
        if let userInfo = notification.userInfo as? [String: Any] {
            for (key, data) in userInfo {
                
                if key == "foodDict" {
                    foodDict = data as! [String: [Food]]
                    updateInterface = true
                }
                
                if key == "itemArray" {
                    itemArray = data as! [Item]
                    updateInterface = true
                }
                
                if key == "dailyTotal" {
                    dailyTotal = data as! [String: Double]
                    updateInterface = true
                }
                
                if key == "days" {
                    days = data as! Double
                    updateInterface = true
                }
                
            }
        }
        
        if updateInterface {
            tableView.reloadData()
        }
    }

}
