//
//  ServeCalculatorCell.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/2.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class FoodCell: UITableViewCell {
    
    var foodData: Food?
//    var tableVC: ListTableVC?
    
    let shared = UIViewController()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkMark: UIImageView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var servesStepper: UIStepper!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    

    /********************************
     Value update ways:
        1. loading from core data, if -1, set for user
        2. "set for me" button
        3. stepper
        4. text field
        5. user select cell (checkmark image)
     
     Serves value update dependencies (order):
        1. servefood.serves
        2. stepper
        3. segmented control
        4. text field
     
     Done value update order:
        1. servefood.done
        2. image
     *********************************/
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        numberTextField.delegate = self
        foodImage.layer.cornerRadius = 10
        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }
    
    
    @IBAction func servesStepperValueChanged(_ sender: UIStepper) {
        
        if let food = foodData {
            food.serves = sender.value
            shared.saveContext()
//            tableVC?.notifyChangeOfServes()
            updateServesStepper(food.serves)
            updateUnitSegmentedControl(food)
            updateNumberTextField()
        }
    }
    
    
    @IBAction func unitSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        updateNumberTextField()
        
    }
    
    
    func updateAll(){
        
        if let food = foodData {
            
            //detail label
            titleLabel.text = food.title
            
            //image
            updateCheckmark(food.done)
            updateFoodImage(food.image!, custom: food.custom)
            
            //stepper
            servesStepper.stepValue = 1
            servesStepper.minimumValue = 0
            updateServesStepper(food.serves)

            //segmented control
            updateUnitSegmentedControl(food)
            
            //text field
            updateNumberTextField()
            
        }
    }
    
    
    func updateServesStepper(_ serves: Double) {
        
        servesStepper.maximumValue = serves + servesStepper.stepValue
        servesStepper.value = serves
        
    }
    
    
    func updateUnitSegmentedControl(_ food: Food) {
                
        unitSegmentedControl.setTitle(
            "\(shared.limitDigits(food.serves)) \(K.servesString)",
            forSegmentAt: 0)
        
        let calculatedQ1 = food.quantity1 * food.serves
        
        unitSegmentedControl.setTitle(
            "\(shared.limitDigits(calculatedQ1)) \(food.unit1!)",
            forSegmentAt: 1)
        
        if food.unit2 == "" {
            
            unitSegmentedControl.setTitle("", forSegmentAt: 2)
            unitSegmentedControl.setEnabled(false, forSegmentAt: 2)
            
        } else {
            
            let calculatedQ2 = food.quantity2 * food.serves
            
            unitSegmentedControl.setTitle(
                "\(shared.limitDigits(calculatedQ2)) \(food.unit2!)",
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
        
        checkMark.image = done ? K.checkedSymbol: K.uncheckedSymbol
    }
    
    
    func updateFoodImage(_ name: String, custom: Bool = false){
        
        if custom,
            let imgUrl = shared.getFilePath(name) {
            
            foodImage.image = UIImage(contentsOfFile: imgUrl.path)
            
        } else if name != "",
            let image = UIImage(named: name) {
            
            foodImage.image = image
        }
    }
    
    
}

//MARK: - TextField Delegate Methods

extension FoodCell: UITextFieldDelegate {

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
        
        if let food = foodData,
            let double = Double(textField.text!) {
            
            switch unitSegmentedControl.selectedSegmentIndex {
            case 0:
                food.serves = shared.roundToHalf(double)
            case 1:
                food.serves = shared.roundToHalf(double/food.quantity1)
            case 2:
                food.serves = shared.roundToHalf(double/food.quantity2)
            default:
                return
            }
            
            shared.saveContext()
//            tableVC?.notifyChangeOfServes()
            updateServesStepper(food.serves)
            updateUnitSegmentedControl(food)
            updateNumberTextField()
            
        }
        
    }
    
    
}
