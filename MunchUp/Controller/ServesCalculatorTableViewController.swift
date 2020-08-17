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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let myN = NumberFormatsTYX()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadServeSizes(category)
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
        saveServeSizes()
        notifyChangeOfServes()
        tableView.reloadData()
        
    }
    
    
    func initServesAndDone(force: Bool = false){
        
        let servesPerItem = myN.roundToHalf(targetServes/Double(serveSizes.count))
        for size in serveSizes {
            if force || size.serves == -1 {
                size.serves = servesPerItem
                size.done = false
                saveServeSizes()
                notifyChangeOfServes()
            }
        }
        
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
        
        return cell
    }
    
}

//MARK: - TableView Delegate Methods

extension ServesCalculatorTableViewController {
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let i = indexPath.row
        
        if editingStyle == .delete {
            
            context.delete(serveSizes[i])
            serveSizes.remove(at: i)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveServeSizes()
        }
        
    }
    
}

//MARK: - Core Data

extension ServesCalculatorTableViewController {
    
    func loadServeSizes(_ category: String) {
        
        let request : NSFetchRequest<OneServe> = OneServe.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "category == %@", category)
        request.predicate = categoryPredicate
        
        let sortByOrder = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortByOrder]
        
        do{
            serveSizes = try context.fetch(request)
        } catch {
            print("Error loading OneServe \(error)")
        }
    }
    
    
    func saveServeSizes() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
    }
}
