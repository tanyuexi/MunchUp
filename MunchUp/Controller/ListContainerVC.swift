//
//  ListContainerVC.swift
//  MunchUp
//
//  Created by Yuexi Tan on 2020/8/29.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit

class ListContainerVC: UIViewController {
    
    var listTableVC: ListTableVC?
    
    var days = 0.0
    var peopleCount = 0
    
    var expandAll = true


    @IBOutlet weak var hideCheckedButton: UIButton!
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: K.notificationName, object: nil)
        
        postNotification(["pass data to ListContainerVC": true])
    }
    
    
    func updateInfoLabel(){
        infoLabel.text = String(format: "%@ %d %@, %d %@",
            NSLocalizedString("Number of serves for", comment: "info"),
            peopleCount,
            NSLocalizedString("people", comment: "info"),
            Int(days),
            NSLocalizedString("days", comment: "info"))
    }



    //MARK: - Actions
    @IBAction func autoSetButtonPressed(_ sender: UIButton) {
        listTableVC?.autoSet()
    }


    @IBAction func clearButtonPressed(_ sender: UIButton) {
        listTableVC?.clearServes()
    }


    @IBAction func hideCheckedButtonPressed(_ sender: UIButton) {

        if let vc = listTableVC {
            vc.hideChecked = !vc.hideChecked
            vc.tableView.reloadData()
            sender.setTitle(vc.hideChecked ?
                NSLocalizedString("Show Checked", comment: "button"):
                NSLocalizedString("Hide Checked", comment: "button"),
                for: .normal)
        }
    }


    @IBAction func collapseButtonPressed(_ sender: UIButton) {

        if let vc = listTableVC {
            expandAll = !expandAll
            vc.setExpandState(expandAll)
            vc.tableView.reloadData()
            sender.setTitle(expandAll ?
                NSLocalizedString("Collapse All", comment: "button"):
                NSLocalizedString("Expand All", comment: "button"),
                for: .normal)
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "GoToListTableVC" {
            listTableVC = segue.destination as? ListTableVC
        }
    }


}

//MARK: - Notification center

extension ListContainerVC {
    
    @objc func onNotification(notification: Notification) {
        
        var updateInterface = false
        
        if let userInfo = notification.userInfo as? [String: Any] {
            for (key, data) in userInfo {
                
                if key == "days" {
                    days = data as! Double
                    updateInterface = true
                }
                
                if key == "peopleCount" {
                    peopleCount = data as! Int
                    updateInterface = true
                }
                
            }
        }
        
        if updateInterface {
            updateInfoLabel()
        }

    }
    
    
}
