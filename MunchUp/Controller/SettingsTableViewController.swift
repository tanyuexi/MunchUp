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

    @IBAction func servesForChildrenButtonPressed(_ sender: UIButton) {
        
        openUrl(K.servesForChildrenLink)
    }
    
    @IBAction func servesForAdultsButtonPressed(_ sender: UIButton) {
        
        openUrl(K.servesForAdultsLink)
    }
    
    @IBAction func serveSizesButtonPressed(_ sender: UIButton) {
        
        openUrl(K.serveSizesLink)
    }
    
    func loadSettings(){
        daysTextField.text = "\(defaults.integer(forKey: NSLocalizedString("Days", comment: "plist")))"
    }
    
    func openUrl(_ string: String){
        if let url = URL(string: string) {
            UIApplication.shared.open(url)
        }
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
