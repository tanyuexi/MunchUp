//
//  ServeCalculatorCell.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/2.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class ServesCalculatorCell: UITableViewCell {
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var servesStepper: UIStepper!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    
    var serveSizes: OneServe?
    var tableVC: ServesCalculatorTableViewController?
    
    let myN = NumberFormatsTYX()
    let checkedSymbol = UIImage(systemName: "checkmark.circle.fill")
    let uncheckedSymbol = UIImage(systemName: "circle")
    
    /********************************
     Value update ways:
        1. loading from core data, if -1, set for user
        2. "set for me" button
        3. stepper
        4. text field
        5. user select cell (checkmark image)
     
     Serves value update dependencies (order):
        1. serveSizes.serves
        2. stepper
        3. segmented control
        4. text field
     
     Done value update order:
        1. serveSizes.done
        2. image
     *********************************/
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        numberTextField.delegate = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        if let sizes = serveSizes, selected {
            sizes.done = !sizes.done
            updateCheckmark(sizes.done)
            tableVC?.saveServeSizes()
        }
        
    }

    
    @IBAction func servesStepperValueChanged(_ sender: UIStepper) {
        
        if let sizes = serveSizes {
            sizes.serves = sender.value
            tableVC?.saveServeSizes()
            tableVC?.notifyChangeOfServes()
            updateServesStepper(sizes.serves)
            updateUnitSegmentedControl(sizes)
            updateNumberTextField()
        }
    }
    
    
    @IBAction func unitSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        updateNumberTextField()
        
    }
    
    
    func updateAll(){
        
        if let sizes = serveSizes {
            
            //detail label
            detailLabel.text = sizes.detail
            
            //image
            updateCheckmark(sizes.done)
            
            //stepper
            servesStepper.stepValue = 1
            servesStepper.minimumValue = 0
            updateServesStepper(sizes.serves)

            //segmented control
            updateUnitSegmentedControl(sizes)
            
            //text field
            updateNumberTextField()
            
        }
    }
    
    
    func updateServesStepper(_ serves: Double) {
        
        servesStepper.value = serves
        servesStepper.maximumValue = servesStepper.value + servesStepper.stepValue
        
    }
    
    
    func updateUnitSegmentedControl(_ sizes: OneServe) {
        
        unitSegmentedControl.setTitle(
            "\(myN.limitDigits(sizes.serves)) serves",
            forSegmentAt: 0)
        
        let calculatedQ1 = sizes.quantity1 * sizes.serves
        
        unitSegmentedControl.setTitle(
            "\(myN.limitDigits(calculatedQ1)) \(sizes.unit1!)",
            forSegmentAt: 1)
        
        if sizes.unit2 == "" {
            
            unitSegmentedControl.setTitle("", forSegmentAt: 2)
            unitSegmentedControl.setEnabled(false, forSegmentAt: 2)
            
        } else {
            
            let calculatedQ2 = sizes.quantity2 * sizes.serves
            
            unitSegmentedControl.setTitle(
                "\(myN.limitDigits(calculatedQ2)) \(sizes.unit2!)",
                forSegmentAt: 2)
            
            unitSegmentedControl.setEnabled(true, forSegmentAt: 2)
            
        }
        
    }
    
    
    func updateNumberTextField() {
        
        let i = unitSegmentedControl.selectedSegmentIndex
        let number = unitSegmentedControl.titleForSegment(at: i)?.components(separatedBy: " ")[0]
        numberTextField.text = number
        
    }
    
    
    func updateCheckmark(_ done: Bool) {
        
        foodImage.image = done ? checkedSymbol: uncheckedSymbol
        
    }
    
    
}

//MARK: - TextField Delegate Methods

extension ServesCalculatorCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.selectAll(nil)
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        return true
        
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if Double(textField.text!) == nil{
            textField.text = "0"
        }
        return true
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let sizes = serveSizes,
            let double = Double(textField.text!) {
            
            switch unitSegmentedControl.selectedSegmentIndex {
            case 0:
                sizes.serves = myN.roundToHalf(double)
            case 1:
                sizes.serves = myN.roundToHalf(double/sizes.quantity1)
            case 2:
                sizes.serves = myN.roundToHalf(double/sizes.quantity2)
            default:
                return
            }
            
            tableVC?.saveServeSizes()
            tableVC?.notifyChangeOfServes()
            updateServesStepper(sizes.serves)
            updateUnitSegmentedControl(sizes)
            updateNumberTextField()
            
        }
        
    }
    
    
}

