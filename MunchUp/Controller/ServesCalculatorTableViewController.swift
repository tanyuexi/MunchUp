//
//  ServesCalculatorTableViewController.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/2.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class ServesCalculatorTableViewController: UITableViewController {
    
    var category = ""
    var targetServes = 0.0
    var containerVC: ServesCalculatorViewController?
    
    var serveSizes: [OneServe] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadServeSizes(to: &serveSizes, category: category)
        initServesAndDone()
        notifyChangeOfServes()
        
        tableView.register(UINib(nibName: "ServesCalculatorCell", bundle: nil), forCellReuseIdentifier: K.servesCalculatorCellID)

    }
    
}

//MARK: - Functions

extension ServesCalculatorTableViewController {
    
    func notifyChangeOfServes() {
        
        containerVC?.updateTotal(sumUpServes())
        
    }
    
    func sumUpServes() -> Double {
        
        var total = 0.0
        for serveSize in serveSizes {
            total += serveSize.serves
        }
        return total
        
    }
    
    
    func setForUser() {
        
        initServesAndDone(force: true)
        tableView.reloadData()
        
    }
    
    
    func clearServes() {
        
        for size in serveSizes {
            size.serves = 0
            size.done = false
        }
        saveContext()
        notifyChangeOfServes()
        tableView.reloadData()
        
    }
    
    
    func initServesAndDone(force: Bool = false){
        
        let servesPerItem = roundToHalf(targetServes/Double(serveSizes.count))
        for size in serveSizes {
            if force || size.serves == -1 {
                size.serves = servesPerItem
                size.done = false
                saveContext()
                notifyChangeOfServes()
            }
        }
        
    }
    
    
    func setCellDoneState(_ checked: Bool, at indexPath: IndexPath) {
        
        serveSizes[indexPath.row].done = checked
        let cell = tableView.cellForRow(at: indexPath) as! ServesCalculatorCell
        cell.updateCheckmark(checked)
        saveContext()
    }
    
}

//MARK: - TableView Data Source

extension ServesCalculatorTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serveSizes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.servesCalculatorCellID, for: indexPath) as! ServesCalculatorCell
        
        cell.serveSizes = serveSizes[indexPath.row]
        cell.tableVC = self
        
        cell.updateAll()
        if serveSizes[indexPath.row].done {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell

    }
    
}

//MARK: - TableView Delegate Methods

extension ServesCalculatorTableViewController {
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        setCellDoneState(true, at: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        setCellDoneState(false, at: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let i = indexPath.row
        
        if editingStyle == .delete {
            
            if serveSizes[i].custom,
                let imgUrl = getFilePath(serveSizes[i].image),
                FileManager.default.fileExists(atPath: imgUrl.path) {
                                
                do {
                    try FileManager.default.removeItem(at: imgUrl)
                } catch {
                    print(error)
                }
            }
            
            K.context.delete(serveSizes[i])
            serveSizes.remove(at: i)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if serveSizes[indexPath.row].done {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}


