//
//  SettingsTableViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/24.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    let shopListVC = ShoppingListViewController()
    
    @IBOutlet weak var daysTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        
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
        defaults.set(Int(sender.text!), forKey: NSLocalizedString("Days", comment: "plist"))
    }
    
    
    func loadSettings(){
        daysTextField.text = "\(defaults.integer(forKey: NSLocalizedString("Days", comment: "plist")))"
    }
    
    
    func openUrl(_ string: String){
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
    }
    
    
    func alertPopUp(_ message: String){
        
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Got it", comment: "alert"), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)

    }
}

//MARK: - Table View Delegate Methods

extension SettingsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath {
        case [0,1]:
            shopListVC.reloadServeSizes()
            alertPopUp(NSLocalizedString("Food database reloaded", comment: "alert"))
            break
            
        case [1,0]:
            openUrl(K.servesForChildrenLink)
            break
            
        case [1,1]:
            openUrl(K.servesForAdultsLink)
            break
            
        case [1,2]:
            openUrl(K.serveSizesLink)
            break

        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - Text Field Delegate Methods

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
}
