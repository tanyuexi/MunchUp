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
    
    //from listContrainerVC
    var foodDict: [String: [Food]] = [:]
    var itemArray: [Item] = []
    var dailyTotal: [String: Double] = [:]
    var days = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "FoodCell", bundle: nil), forCellReuseIdentifier: K.foodCellID)
        tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: K.itemCellID)
        
        setExpandState(true)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        days = getDays()
//        tableView.reloadData()
//    }
    
}

//MARK: - Functions

extension ListTableVC {
    
    func setExpandState(_ state: Bool){
        expandSection = []
        for _ in 1...(K.foodGroups.count + 1) {
            expandSection.append(state)
        }
    }

//    func notifyChangeOfServes() {
//
//        containerVC?.updateTotal(sumUpServes())
//
//    }

//    func sumUpServes() -> Double {
//
//        var total = 0.0
//        for serveSize in serveSizes {
//            total += serveSize.serves
//        }
//        return total
//
//    }
//
//
//    func setForUser() {
//
//        initServesAndDone(force: true)
//        tableView.reloadData()
//
//    }


//    func clearServes() {
//
//        for size in serveSizes {
//            size.serves = 0
//            size.done = false
//        }
//        saveContext()
//        notifyChangeOfServes()
//        tableView.reloadData()
//
//    }


//    func initServesAndDone(force: Bool = false){
//
//        let servesPerItem = roundToHalf(targetServes/Double(serveSizes.count))
//        for size in serveSizes {
//            if force || size.serves == -1 {
//                size.serves = servesPerItem
//                size.done = false
//                saveContext()
//                notifyChangeOfServes()
//            }
//        }
//
//    }


    func setFoodCellDoneState(_ checked: Bool, at indexPath: IndexPath) {

        let category = K.foodGroups[indexPath.section]
        foodDict[category]![indexPath.row].done = checked
        let cell = tableView.cellForRow(at: indexPath) as! FoodCell
        cell.updateCheckmark(checked)
        saveContext()
        if hideChecked, checked {
            tableView.reloadSections([indexPath.section], with: .fade)
        }
    }

}

//MARK: - TableView Data Source

extension ListTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {

        return K.foodGroups.count + 1 //food, other items
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        var buttonTitle = ""
        
        if section < K.foodGroups.count {
            let category = K.foodGroups[section]
            buttonTitle = String(format: "%@ %@ (%@: %@, %@: %@)",
                K.foodIcon[section],
                K.foodGroups[section],
                NSLocalizedString("Target", comment: "section header"),
                limitDigits( dailyTotal[category] ?? 0.0 * days ),
                NSLocalizedString("Now", comment: "section header"),
                "0"
            )
        } else {
            buttonTitle = NSLocalizedString("Other Items", comment: "section header")
        }
        
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
        tableView.reloadSections([sender.tag], with: .fade)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if foodDict.count == 0 {
            return 0
        } else if section < K.foodGroups.count {
            let category = K.foodGroups[section]
            return expandSection[section] ? foodDict[category]!.count: 0
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
            cell.foodData = foodData
            cell.updateAll()
            if foodData.done {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                if hideChecked {
                    cell.isHidden = true
                    hiddenCell[indexPath] = true
                } else {
                    cell.isHidden = false
                    hiddenCell[indexPath] = false
                }
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellID, for: indexPath) as! ItemCell
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
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if foodDict.count != 0, indexPath.section < K.foodGroups.count {
            
            setFoodCellDoneState(false, at: indexPath)
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
                foodDict[category]!.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                saveContext()
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


