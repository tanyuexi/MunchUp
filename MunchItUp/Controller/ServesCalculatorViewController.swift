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
    var totalServes = 0.0
    var tableVC: ServesCalculatorTableViewController?
    
    @IBOutlet weak var targetServesLabel: UILabel!
    @IBOutlet weak var totalServesLabel: UILabel!
    @IBOutlet weak var setButton: UIButton!
    
    let myN = NumberFormatsTYX()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setButton.layer.cornerRadius = 10
        navigationItem.title = category
        targetServesLabel.text = myN.limitDigits(targetServes)
                
    }
    
    @IBAction func setButtonPressed(_ sender: UIButton) {
        tableVC?.setForUser()
    }
    
    //MARK: - Functions
    
    func updateTotal(_ serves: Double) {
        totalServes = myN.roundToHalf(serves)
        let delta = totalServes - targetServes
        totalServesLabel.text = (delta >= 0) ? "+": ""
        totalServesLabel.text! += myN.limitDigits(delta)
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "GoToServesCalculatorTableVC" {
            tableVC = segue.destination as? ServesCalculatorTableViewController
            
            tableVC?.category = category
            tableVC?.targetServes = targetServes
            tableVC?.containerVC = self
            
        }
        
    }
    
}
