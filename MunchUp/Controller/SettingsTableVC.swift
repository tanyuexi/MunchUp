//
//  SettingsTableViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/24.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableVC: UITableViewController {
    
    
    @IBOutlet weak var daysTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysTextField.text = "\(Int(getDays()))"
        
        daysTextField.delegate = self 
    
    }
    
    @IBAction func daysTextFieldEditingDidEnd(_ sender: UITextField) {
        
        if let days = Int(sender.text!) {
            if days < 1 {
                sender.text = "1"
            } else {
                sender.text = "\(days)"
            }
        } else {
            sender.text = "1"
        }
        
        updateDays(Int(sender.text!)!)
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
    
    
    func copyToClipboard(){
        let pasteboard = UIPasteboard.general
        
        var list = NSLocalizedString("Shopping List ", comment: "export")
        
        //number of people and days
        var memberArray: [People] = []
        loadPeople(to: &memberArray)
        let days = Int(getDays())
        list += "(\(memberArray.count) " + NSLocalizedString("people, ", comment: "export")
        list += "\(days) " + NSLocalizedString("days)", comment: "export") + "\n\n"
        memberArray = []
        
        //food
        var sizeArray: [Food] = []
        for group in K.foodGroups {
            list += "#############\n"
            list += "#  \(group)\n"
            list += "#############\n\n"
            loadFood(to: &sizeArray, category: group)
            for food in sizeArray {
                if food.serves == 0 {
                    continue
                }
                list += food.done ? "@ ": "- "
                list += "[ \(limitDigits(food.serves)) \(K.servesString)/ \(limitDigits(food.serves * food.quantity1)) \(food.unit1!)"
                list += (food.unit2 == "") ? "": "/ \(limitDigits(food.serves * food.quantity2)) \(food.unit2!)"
                list += " ] "
                list += "\(food.title!)\n\n"
            }
            sizeArray = []
        }
        
        //other items
        list += "#############\n"
        list += NSLocalizedString("#  Other items", comment: "export") + "\n"
        list += "#############\n\n"
        var itemArray: [Item] = []
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "lastEdited", ascending: false)
        request.sortDescriptors = [sortByDate]
        do{
            itemArray = try K.context.fetch(request)
            for i in itemArray {
                if let item = i.title {
                    list += i.done ? "@ ": "- "
                    list += "\(item)\n\n"
                }
            }
        } catch {
            print("Error loading Item \(error)")
        }
        
        pasteboard.string = list
    }
}

//MARK: - Table View Delegate Methods

extension SettingsTableVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case [0,1]:
            resetFoodDatabase()
            confirmMessage(NSLocalizedString("Food database reloaded", comment: "alert"))
            
        case [0,2]:
            copyToClipboard()
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
