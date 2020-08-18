//
//  ServesCalculatorViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/4.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class ServesCalculatorViewController: UIViewController {

    var category = ""
    var targetServes = 0.0
    var currentServes = 0.0
    var tableVC: ServesCalculatorTableViewController?
    
    @IBOutlet weak var targetServesLabel: UILabel!
    @IBOutlet weak var moreOrLessLabel: UILabel!
    @IBOutlet weak var totalServesLabel: UILabel!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setButton.layer.cornerRadius = 10
        clearButton.layer.cornerRadius = 10
        navigationItem.title = category
        targetServesLabel.text = limitDigits(targetServes)
        
                
    }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        tableVC?.setForUser()
    }
    
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        tableVC?.clearServes()
    }
    
    //MARK: - Functions
    
    func updateTotal(_ serves: Double) {
        currentServes = roundToHalf(serves)
        let delta = currentServes - targetServes
        totalServesLabel.text = (delta > 0) ? "+": ""
        if delta == 0 {
            moreOrLessLabel.text = NSLocalizedString("Just right", comment: "serves calculator")
        } else if delta > 0 {
            moreOrLessLabel.text = NSLocalizedString("Too much", comment: "serves calculator")
        } else if delta < 0 {
            moreOrLessLabel.text = NSLocalizedString("Too little", comment: "serves calculator")
        }
        totalServesLabel.text! += limitDigits(delta)
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "GoToServesCalculatorTableVC" {
            
            tableVC = segue.destination as? ServesCalculatorTableViewController

            tableVC?.category = category
            tableVC?.targetServes = targetServes
            tableVC?.containerVC = self

        } else if segue.identifier == "GoToNewFoodVC" {
            let destinationVC = segue.destination as? NewFoodTableViewController
            destinationVC?.category = category
            destinationVC?.containerVC = self
        }

    }
    
}
