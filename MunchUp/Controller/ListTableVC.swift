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
    
    var expandSection: [Bool] = []
    var hideChecked = false
    var hiddenCell: [IndexPath: Bool] = [:]
    var currentServes: [String: Double] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setExpandState(true)
        
        for category in K.foodGroups {
            currentServes[category] = sumUpServes(category)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: K.notificationName, object: nil)
        
        tableView.register(UINib(nibName: K.foodCellID, bundle: nil), forCellReuseIdentifier: K.foodCellID)
        tableView.register(UINib(nibName: K.itemCellID, bundle: nil), forCellReuseIdentifier: K.itemCellID)
        tableView.register(ListSectionHeader.self, forHeaderFooterViewReuseIdentifier: K.foodHeaderID)

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


    func sumUpServes(_ category: String) -> Double {
        var total = 0.0
        if let array = Data.shared.foodDict[category] {
            for food in array {
                total += food.serves
            }
        }
        return total

    }
    
    
    func autoSet() {
        for (category, foodArray) in Data.shared.foodDict {
            if let dailyTarget = Data.shared.dailyTotal[category] {
                
                let targetServes = dailyTarget * Data.shared.days
                let servesPerItem = roundToHalf(targetServes/Double(foodArray.count))
                for food in foodArray {
                    food.serves = servesPerItem
                }
            }
            currentServes[category] = sumUpServes(category)
        }
        saveFood()
        tableView.reloadData()
    }
    
    
    func clearServes() {
        for (category, foodArray) in Data.shared.foodDict {
            for food in foodArray {
                food.serves = 0
            }
            currentServes[category] = 0
        }
        saveFood()
        tableView.reloadData()
    }
    
    
    func setFoodCellDoneState(_ checked: Bool, at indexPath: IndexPath) {
        
        let category = K.foodGroups[indexPath.section]
        Data.shared.foodDict[category]![indexPath.row].done = checked
        let cell = tableView.cellForRow(at: indexPath) as! FoodCell
        cell.updateCheckmark(checked)
        if hideChecked, checked {
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }
    
    
    func setItemCellDoneState(_ checked: Bool, at indexPath: IndexPath) {
        
        Data.shared.itemArray[indexPath.row].done = checked
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
                limitDigits( (Data.shared.dailyTotal[category] ?? 0.0) * Data.shared.days ),
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
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.foodHeaderID) as! ListSectionHeader
        
        headerView.delegate = self
        headerView.collapseButton.tag = section
        
        if section < K.foodGroups.count {
            let title = foodHeaderString(at: section)
            headerView.addButton.tag = section
            headerView.collapseButton.setTitle(title, for: .normal)
        } else {
            let title = String(format: "%@ (%d)",
                            NSLocalizedString("Other Items", comment: "section header"),
                            (Data.shared.itemArray.count - 1)
            )
            headerView.collapseButton.setTitle(title, for: .normal)
            headerView.addButton.isHidden = true
        }
        
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section < K.foodGroups.count {
            let category = K.foodGroups[section]
            return expandSection[section] ? (Data.shared.foodDict[category]?.count ?? 0): 0
        } else {
            return expandSection[section] ? Data.shared.itemArray.count: 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < K.foodGroups.count {
            let category = K.foodGroups[indexPath.section]
            let foodData = Data.shared.foodDict[category]![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: K.foodCellID, for: indexPath) as! FoodCell
            cell.delegate = self
            cell.index = indexPath.row
            cell.foodData = foodData
            cell.updateAll()
            initCheckedState(with: foodData.done, at: indexPath, cell: cell)
            return cell
            
        } else {
            let item = Data.shared.itemArray[indexPath.row]
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
        
        if indexPath.section < K.foodGroups.count {
            setFoodCellDoneState(true, at: indexPath)
        } else {
            setItemCellDoneState(true, at: indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if indexPath.section < K.foodGroups.count {
            setFoodCellDoneState(false, at: indexPath)
        } else {
            setItemCellDoneState(false, at: indexPath)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.section < K.foodGroups.count {
            
            let category = K.foodGroups[indexPath.section]
            let foodData = Data.shared.foodDict[category]![indexPath.row]
            
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
                Data.shared.foodDict[category]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .none)
                saveFood()
            }
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section < K.foodGroups.count {
            
            let category = K.foodGroups[indexPath.section]
            let foodData = Data.shared.foodDict[category]![indexPath.row]
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
        
        if let i = K.foodGroups.firstIndex(of: category),
            let hv = tableView.headerView(forSection: i) as? ListSectionHeader,
            let title = hv.collapseButton.currentTitle {
            
            let total = limitDigits(currentServes[category])
            let newTitle = title.replacingOccurrences(of: #"(\d|\.)+\)$"#, with: total + ")", options: .regularExpression, range: nil)
            hv.collapseButton.setTitle(newTitle, for: .normal)
        }
    }
    
    func saveFood(){
        saveContext()
    }
}

//MARK: - ItemCellDelegate

extension ListTableVC: ItemCellDelegate {
    
    func addItem(_ newTitle: String) {
        Data.shared.itemArray[0].title = newTitle
        Data.shared.itemArray[0].lastEdited = Date()
        Data.shared.itemArray.insert(Item(context: K.context), at: 0)
        Data.shared.itemArray[0].lastEdited = Date().advanced(by: 1)
    }
    
    
    func deleteItem(at index: Int) {
        K.context.delete(Data.shared.itemArray[index])
        Data.shared.itemArray.remove(at: index)
    }
    
    
    func saveItemAndReloadTable(){
        saveContext()
        tableView.reloadSections([K.foodGroups.count], with: .none)
    }
    
    
}

//MARK: - Notification center

extension ListTableVC {
    
    @objc func onNotification(notification: Notification) {
        
        var updateInterface = false
        
        if let userInfo = notification.userInfo as? [String: Any] {
            for (key, _) in userInfo {
                
                if key == "foodDict" {
                    for category in K.foodGroups {
                        currentServes[category] = sumUpServes(category)
                    }
                    updateInterface = true
                }
                
                if key == "dailyTotal" {
                    updateInterface = true
                }
                
                if key == "days" {
                    updateInterface = true
                }
            }
        }
        
        if updateInterface {
            tableView.reloadData()
        }
    }

}

//MARK: - ListSectionHeaderDelegate

extension ListTableVC: ListSectionHeaderDelegate {
    
    func onCollapseButtonPressed(sender: UIButton) {
        expandSection[sender.tag] = !expandSection[sender.tag]
        tableView.reloadSections([sender.tag], with: .none)
    }
    
    func onAddButtonPressed(sender: UIButton) {
        performSegue(withIdentifier: "GoToNewFoodTableVC", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToNewFoodTableVC",
            let vc = segue.destination as? NewFoodTableVC,
            let button = sender as? UIButton {
            
            vc.delegate = self
            vc.category = K.foodGroups[button.tag]
        }
    }
    
}

//MARK: - NewFoodTableVCDelegate

extension ListTableVC: NewFoodTableVCDelegate {
    
    func addNewFood(_ food: Food, category: String) {
        if Data.shared.foodDict[category] != nil,
            let i = K.foodGroups.firstIndex(of: category) {
            Data.shared.foodDict[category]!.append(food)
            saveFood()
            tableView.reloadSections([i], with: .none)
        }
    }
}
