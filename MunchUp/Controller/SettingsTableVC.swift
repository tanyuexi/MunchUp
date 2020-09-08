//
//  SettingsTableVC.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/24.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableVC: UITableViewController {
    
    var days = 0.0

    @IBOutlet weak var daysTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: K.notificationName, object: nil)
//        
//        postNotification(["pass data to SettingsTableVC": true])

        days = getDays()
        daysTextField.text = String(Int(days))
        daysTextField.delegate = self
    
    }
    
    @IBAction func daysTextFieldEditingDidEnd(_ sender: UITextField) {

        if let d = Int(sender.text!) {
            if d < 1 {
                sender.text = "1"
            } else {
                sender.text = "\(d)"
            }
        } else {
            sender.text = "1"
        }
        
        days = Double(sender.text!)!
        updateDays(Int(days))
        postNotification([
            "days": days
        ])
    }



    func openUrl(_ string: String){
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }


    func confirmMessage(_ message: String){

        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "alert"), style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)

    }


//    func copyToClipboard(){
//        let pasteboard = UIPasteboard.general
//
//        var list = NSLocalizedString("Shopping List ", comment: "export")
//
//        if let tbvc = tabbarC {
//            //number of people and days
//            list += String(format: "(%d %@, %d %@)\n\n",
//                           tbvc.peopleArray.count,
//                           NSLocalizedString("people", comment: "export"),
//                           Int(tbvc.days),
//                           NSLocalizedString("days", comment: "export"))
//
//            //food
//            for group in K.foodGroups {
//                list += "#############\n"
//                list += "#  \(group)\n"
//                list += "#############\n\n"
//                if let foodArray = tbvc.foodDict[group] {
//                    for food in foodArray {
//                        if food.serves == 0 || food.done {
//                            continue
//                        }
//                        list += food.done ? "@ ": "- "
//                        list += "[ \(limitDigits(food.serves)) \(K.servesString)/ \(limitDigits(food.serves * food.quantity1)) \(food.unit1!)"
//                        list += (food.unit2 == "") ? "": "/ \(limitDigits(food.serves * food.quantity2)) \(food.unit2!)"
//                        list += " ] "
//                        list += "\(food.title!)\n\n"
//                    }
//                }
//            }
//
//            //other items
//            list += "#############\n"
//            list += NSLocalizedString("#  Other items", comment: "export") + "\n"
//            list += "#############\n\n"
//            for i in tbvc.itemArray {
//                if let item = i.title {
//                    list += i.done ? "@ ": "- "
//                    list += "\(item)\n\n"
//                }
//            }
//
//        }
//        pasteboard.string = list
//    }
}

//MARK: - Table View Delegate Methods

extension SettingsTableVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case [0,1]:
            postNotification(["resetFoodDatabase": true])
            confirmMessage(NSLocalizedString("Food database reloaded", comment: "alert"))
//            tabbarC?.updateFoodRelatedComponents()
            
        case [0,2]:
//            copyToClipboard()
            confirmMessage(NSLocalizedString("List copied", comment: "alert"))
            
        case [1,0]:
            openUrl(K.servesForChildrenLink)
            
        case [1,1]:
            openUrl(K.servesForAdultsLink)
            
        case [1,2]:
            openUrl(K.serveSizesLink)

        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Text Field Delegate Methods

extension SettingsTableVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
}

