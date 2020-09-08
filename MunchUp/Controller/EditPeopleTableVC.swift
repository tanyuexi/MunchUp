//
//  EditPeopleTableVC.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/20.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

protocol EditPeopleTableVCDelegate: class {
    func addPerson(_ newData: People)
    func deletePerson(at index: Int)
    func saveDataAndReloadTable()
}

class EditPeopleTableVC: UITableViewController {
    
    var delegate: EditPeopleTableVCDelegate?
    var selectedPerson: [People] = []
    var index = -1
    
    var validDOB = false
    let dateFormatter = DateFormatter()
    let confirmFormatter = DateFormatter()
    
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
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = NSLocalizedString("dd/MM/yyyy", comment: "DOB text field data format")
        confirmFormatter.dateFormat = NSLocalizedString("(d MMM, yyyy)", comment: "DOB confirm label data format")
        
        if selectedPerson.count == 0 {
            deleteButton.isHidden = true
        } else {
            deleteButton.isHidden = false
            dataToForm(from: selectedPerson[0])
        }
        
        nameTextField.delegate = self
        DOBTextField.delegate = self
        
        checkIfReadyToSave()
    }
    
    func dataToForm(from data: People){
        nameTextField.text = data.name
        DOBTextField.text = dateFormatter.string(from: data.dateOfBirth!)
        DOBConfirmLabel.text = confirmFormatter.string(from: data.dateOfBirth!)
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
            if let oldDate = dateFormatter.date(from: DOBTextField.text!),
                dateFormatter.date(from: DOBTextField.text!)! <= Date() {
                DOBConfirmLabel.text = confirmFormatter.string(from: oldDate)
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
        let newPerson = People(context: K.context)
        formToData(to: newPerson)
        if selectedPerson.count == 1 {   //edit existing person
            delegate?.deletePerson(at: index)
        }
        //add new person
        delegate?.addPerson(newPerson)
        delegate?.saveDataAndReloadTable()
        dismiss(animated: true, completion: nil)
    }
    
    func formToData(to data: People){
        data.name = nameTextField.text!
        data.dateOfBirth = dateFormatter.date(from: DOBTextField.text!)
        data.additional = additionalSwitch.isOn
        data.female = (genderSegmentedControl.selectedSegmentIndex == 0)
        data.pregnant = pregnantSwitch.isOn
        data.breastfeeding = breastfeedingSwitch.isOn
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.deletePerson(at: index)
        delegate?.saveDataAndReloadTable()
        dismiss(animated: true, completion: nil)
    }
    
    
    func checkIfReadyToSave() {
        enableSaveButton(saveButton, enable: (nameTextField.text != "" &&
        validDOB))
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - UITextFieldDelegate

extension EditPeopleTableVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    //DOBTextField auto format to "XX/XX/XXXX"
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField != DOBTextField || string == "" {
            return true
        }
        
        let currentText = textField.text! as NSString
        var updatedText = currentText.replacingCharacters(in: range, with: string)
        
        switch updatedText.count {
        case Int(NSLocalizedString("2", comment: "auto format date")):
            updatedText.append("/")
        case Int(NSLocalizedString("5", comment: "auto format date")):
            updatedText.append("/")
        case 11:
            return false
        default:
            return true
        }
        
        textField.text = updatedText
        return false
    }
    
}



