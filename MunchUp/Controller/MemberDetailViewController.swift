//
//  MemberDetailViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/20.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class MemberDetailViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var DOBTextField: UITextField!
    @IBOutlet weak var DOBConfirmLabel: UILabel!
    @IBOutlet weak var additionalSwitch: UISwitch!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pregnantStackView: UIStackView!
    @IBOutlet weak var pregnantSwitch: UISwitch!
    @IBOutlet weak var breastfeedingStackView: UIStackView!
    @IBOutlet weak var breastfeedingSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var selectedMember: [FamilyMember] = []
    var validDOB = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 10
        deleteButton.layer.cornerRadius = 10
                
        if selectedMember.count == 0 {
            navigationItem.title = NSLocalizedString("New Member", comment: "navigation title")
            deleteButton.isHidden = true
        } else {
            let editLocalize = NSLocalizedString("Edit", comment: "navigation title")
            navigationItem.title = "\(editLocalize) \(selectedMember[0].name!)"
            dataToForm(from: selectedMember[0])
        }
        
        nameTextField.delegate = self
        DOBTextField.delegate = self
    
        checkIfReadyToSave()
    }
    
    func dataToForm(from data: FamilyMember){
        nameTextField.text = data.name
        DOBTextField.text = data.dateOfBirthString
        validDOB = true
        additionalSwitch.isOn = data.additional
        pregnantSwitch.isOn = data.pregnant
        breastfeedingSwitch.isOn = data.breastfeeding
        enableFemaleOptions(data.female)
    }

    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        checkIfReadyToSave()
    }
    
    @IBAction func DOBTextFieldEditingChanged(_ sender: UITextField) {
        if DOBTextField.text == "" {
            DOBConfirmLabel.text = NSLocalizedString("(DD/MM/YYYY)", comment: "DOB confirm label")
            DOBConfirmLabel.textColor = .none
            validDOB = false
        } else {
            let oldFormatter = DateFormatter()
            oldFormatter.dateFormat = "dd/MM/yyyy"
            let newFormatter = DateFormatter()
            newFormatter.dateFormat = "(d MMM, yyyy)"
            if let oldDate = oldFormatter.date(from: DOBTextField.text!),
                oldFormatter.date(from: DOBTextField.text!)! <= Date() {
                DOBConfirmLabel.text = newFormatter.string(from: oldDate)
                DOBConfirmLabel.textColor = .none
                DOBTextField.clearsOnBeginEditing = false
                validDOB = true
            } else {
                DOBConfirmLabel.text = NSLocalizedString("(Invalid date)", comment: "DOB confirm label")
                DOBConfirmLabel.textColor = .red
                DOBTextField.clearsOnBeginEditing = true
                validDOB = false
            }
        }
        checkIfReadyToSave()
    }
    
    @IBAction func genderSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        enableFemaleOptions(sender.selectedSegmentIndex == 0)
    }
    
    func enableFemaleOptions(_ enable: Bool){
        if enable {
            genderSegmentedControl.selectedSegmentIndex = 0
            pregnantStackView.isHidden = false
            breastfeedingStackView.isHidden = false
        } else {
            genderSegmentedControl.selectedSegmentIndex = 1
            pregnantStackView.isHidden = true
            breastfeedingStackView.isHidden = true
            pregnantSwitch.isOn = false
            breastfeedingSwitch.isOn = false
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if selectedMember.count == 0 {   //adding new member
            selectedMember.append(FamilyMember(context: context))
        }
        formToData(to: selectedMember[0])
        saveMemberDetail()
        navigationController?.popViewController(animated: true)
    }
    
    func formToData(to data: FamilyMember){
        data.name = nameTextField.text!
        data.dateOfBirthString = DOBTextField.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        data.dateOfBirth = dateFormatter.date(from: data.dateOfBirthString!)
        data.additional = additionalSwitch.isOn
        data.female = (genderSegmentedControl.selectedSegmentIndex == 0)
        data.pregnant = pregnantSwitch.isOn
        data.breastfeeding = breastfeedingSwitch.isOn
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        context.delete(selectedMember[0])
        saveMemberDetail()
        navigationController?.popViewController(animated: true)
    }
    
    
    func checkIfReadyToSave() {
        if nameTextField.text != "",
            validDOB {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .systemGreen
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .systemGray
        }
    }
}

//MARK: - UITextFieldDelegate

extension MemberDetailViewController: UITextFieldDelegate {
    
    //DOBTextField auto format to "XX/XX/XXXX"
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField != DOBTextField || string == "" {
            return true
        }

        let currentText = textField.text! as NSString
        var updatedText = currentText.replacingCharacters(in: range, with: string)

        switch updatedText.count {
        case 2:
            updatedText.append("/")
        case 5:
            updatedText.append("/")
        case 11:
            return false
        default:
            return true
        }

        textField.text = updatedText
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
}

//MARK: - Model Manupulation Methods

extension MemberDetailViewController {
    func saveMemberDetail() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
}



