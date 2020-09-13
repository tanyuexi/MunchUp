//
//  NewFoodTableVC.swift
//  MunchUp
//
//  Created by Yuexi Tan on 2020/8/18.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

protocol NewFoodTableVCDelegate {
    func addNewFood(_ food: Food, category: String)
}

class NewFoodTableVC: UITableViewController {

    var category = ""
    var delegate: NewFoodTableVCDelegate?
    
    var imagePicker = UIImagePickerController()
    var imageFileName = ""


    @IBOutlet weak var categoryLabel: UILabel!
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
        
        categoryLabel.text = category
        
        detailTextField.delegate = self
        servesTextField.delegate = self
        q1TextField.delegate = self
        u1TextField.delegate = self
        q2TextField.delegate = self
        u2TextField.delegate = self
        
        imagePicker.delegate = self

        foodImageButton.imageView?.layer.cornerRadius = 10
        
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


    func choosePhoto(_ type: UIImagePickerController.SourceType){

        if UIImagePickerController.isSourceTypeAvailable(type){

            imagePicker.sourceType = type
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }


    @IBAction func foodImageButtonPressed(_ sender: UIButton) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Take a photo", comment: "image picker"), style: .default, handler: {action in self.choosePhoto(.camera)}))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Choose from Library", comment: "image picker"), style: .default, handler: {action in self.choosePhoto(.photoLibrary)}))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "image picker"), style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)


    }


    @IBAction func saveButtonPressed(_ sender: UIButton) {

        if let serves = Double(servesTextField.text!),
            let q1 = Double(q1TextField.text!) {

            let q1PerServe = q1/serves
            let newFood = Food(context: K.context)
            newFood.image = ""
            newFood.category = category
            newFood.custom = true
            newFood.title = detailTextField.text
            newFood.serves = serves
            newFood.quantity1 = q1PerServe
            newFood.unit1 = u1TextField.text
            newFood.done = false
            newFood.date = Date()

            if let q2 = Double(q2TextField.text!) {
                let q2PerServe = q2/serves
                newFood.quantity2 = q2PerServe
                newFood.unit2 = u2TextField.text
            }

            if let imgUrl = getFilePath(imageFileName),
                let data = foodImageButton.currentImage?.pngData() {

                do {
                    try data.write(to: imgUrl)
                } catch {
                    print("Error saving image \(error)")
                }
                newFood.image = imageFileName
            }

            delegate?.addNewFood(newFood, category: category)
        }

        dismiss(animated: true)

    }


    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension NewFoodTableVC: UITextFieldDelegate {

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

//MARK: - image picker
extension NewFoodTableVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {

            imageFileName = "img\(Date().timeIntervalSince1970).png"
            let smallImage = scaleImage(pickedImage, within: foodImageButton.imageView!.bounds)
            foodImageButton.setImage(smallImage, for: .normal)
        }

        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}
