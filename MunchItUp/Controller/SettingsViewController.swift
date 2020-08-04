//
//  SettingsViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/24.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
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
        defaults.set(Int(sender.text!), forKey: "Days")
    }
    
    func loadSettings(){
        daysTextField.text = "\(defaults.integer(forKey: "Days"))"
    }
}

//MARK: - Text Field Delegate Methods

extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
}
