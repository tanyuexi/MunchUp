//
//  NewFoodTableViewController.swift
//  MunchUp
//
//  Created by Yuexi Tan on 2020/8/18.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class NewFoodTableViewController: UITableViewController {

    var category = ""
    var containerVC: ServesCalculatorViewController?

    @IBOutlet weak var foodImageButton: UIButton!
    @IBOutlet weak var detailTextField: UITextField!
    @IBOutlet weak var servesTextField: UITextField!
    @IBOutlet weak var q1TextField: UITextField!
    @IBOutlet weak var u1TextField: UITextField!
    @IBOutlet weak var q2TextField: UITextField!
    @IBOutlet weak var u2TextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTextField.delegate = self
        servesTextField.delegate = self
        q1TextField.delegate = self
        u1TextField.delegate = self
        q2TextField.delegate = self
        u2TextField.delegate = self
        
        saveButton.layer.cornerRadius = 10
        cancelButton.layer.cornerRadius = 10
        
        enableSaveButton(saveButton, enable: false)

    }
    

    func checkIfReadyToSave(){
        
        if detailTextField.text != "",
            servesTextField.text != "",
            q1TextField.text != "",
            u1TextField.text != "" {
            
            enableSaveButton(saveButton)
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if let serves = Double(servesTextField.text!),
            let q1 = Double(q1TextField.text!) {
            
            let q1PerServe = q1/serves
            let newServeSizes = OneServe(context: K.context)
            newServeSizes.image = ""
            newServeSizes.category = category
            newServeSizes.custom = true
            newServeSizes.detail = detailTextField.text
            newServeSizes.serves = serves
            newServeSizes.quantity1 = q1PerServe
            newServeSizes.unit1 = u1TextField.text
            newServeSizes.done = false
            newServeSizes.order = Int16(100 + (containerVC?.tableVC?.serveSizes.count ?? 0))
            
            if let q2 = Double(q2TextField.text!) {
                let q2PerServe = q2/serves
                newServeSizes.quantity2 = q2PerServe
                newServeSizes.unit2 = u2TextField.text
            }
            
            containerVC?.tableVC?.serveSizes.append(newServeSizes)
            saveContext()
            containerVC?.tableVC?.tableView.reloadData()
        }
        
        navigationController?.popViewController(animated: true)

    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension NewFoodTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkIfReadyToSave()
    }
}
