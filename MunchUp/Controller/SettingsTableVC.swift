//
//  SettingsTableVC.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/24.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import GoogleMobileAds
import UIKit
import CoreData

class SettingsTableVC: UITableViewController, GADBannerViewDelegate {
    
    // Google AdMob
    var bannerView: GADBannerView!

    @IBOutlet weak var daysTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        daysTextField.text = String(Int(Data.shared.days))
        daysTextField.delegate = self
        
        // Google AdMob
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.adUnitID = K.adUnitIDSettings  //change this after test before publish
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        tableView.tableHeaderView?.frame = bannerView.frame
        tableView.tableHeaderView = bannerView
    
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
        
        Data.shared.days = Double(sender.text!)!
        updateDays(Int(Data.shared.days))
        postNotification([
            "days": Data.shared.days
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


    func copyToClipboard(){
//        postNotification(["copy list": true])
        let pasteboard = UIPasteboard.general
        
        var list = String(format: "%@ (%d %@, %d %@)\n\n",
            NSLocalizedString("Shopping List", comment: "export"),
            Data.shared.peopleArray.count,
            NSLocalizedString("people", comment: "export"),
            Int(Data.shared.days),
            NSLocalizedString("days", comment: "export")
        )
        
        //food
        for group in K.foodGroups {
            list += "#############\n"
            list += "#  \(group)\n"
            list += "#############\n\n"
            if let foodArray = Data.shared.foodDict[group] {
                for food in foodArray {
                    if food.serves == 0 || food.done {
                        continue
                    }
                    list += String(format: "- [ %@ %@/ %@/ %@ ] %@\n\n",
                        limitDigits(food.serves),
                        K.servesString,
                        formatQuantity((food.serves * food.quantity1), unit: food.unit1!),
                        (food.unit2 == "") ?
                            "":
                            formatQuantity((food.serves * food.quantity2), unit: food.unit2!),
                        food.title!
                    )
                }
            }
        }
            
        
        //other items
        list += "#############\n"
        list += "#  " + NSLocalizedString("Other items", comment: "export") + "\n"
        list += "#############\n\n"
        for i in Data.shared.itemArray {
            if let title = i.title,
                i.done == false {
                
                list += "- \(title)\n\n"
            }
        }
        
        pasteboard.string = list
    }
    
    func readInAbout() -> String {
        
        var contents = ""
        
        if let filePath = Bundle.main.path(forResource: "About", ofType: "txt") {
            
            do {
                try contents = String(contentsOfFile: filePath)
            } catch {
                print("Error reading file: \(error)")
            }
        }
        
        return contents
    }
}

//MARK: - Table View Delegate Methods

extension SettingsTableVC {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case [0,1]:
            resetFoodDatabase()
            loadFood(to: &Data.shared.foodDict)
            postNotification([
                "foodDict": Data.shared.foodDict
            ])
            confirmMessage(NSLocalizedString("Food database reloaded", comment: "alert"))
            
        case [0,2]:
            copyToClipboard()
            confirmMessage(NSLocalizedString("List copied", comment: "alert"))
            
        case [0,3]:
            confirmMessage(readInAbout())
            
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

