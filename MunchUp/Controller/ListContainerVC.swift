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
    var expandAll = true
    
    //from tab bar controller
    var foodDict: [String: [Food]] = [:]
    var itemArray: [Item] = []
    var dailyTotal: [String: Double] = [:]


    @IBOutlet weak var hideCheckedButton: UIButton!
    @IBOutlet weak var collapseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    

    func reloadListTable(){
        listTableVC?.foodDict = foodDict
        listTableVC?.itemArray = itemArray
        listTableVC?.dailyTotal = dailyTotal
        listTableVC?.tableView.reloadData()
    }
    
    //MARK: - Actions
    
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
