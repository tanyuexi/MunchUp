//
//  PublicData.swift
//  MunchUp
//
//  Created by Yuexi Tan on 2020/8/17.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class PublicData {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let defaults = UserDefaults.standard
    
    var days = 0.0
    var dailyTotalServes: [String: Double] = [:]
    
    let checkedSymbol = UIImage(systemName: "checkmark.circle.fill")
    let uncheckedSymbol = UIImage(systemName: "circle")
 
    //plist days
    func updateDays(_ int: Int){
        defaults.set(int, forKey: NSLocalizedString("Days", comment: "plist"))
        days = Double(int)
        print(days)
    }
    
    func reloadServeSizes(){
        
        //load old serve sizes
        var oldServeSizes: [OneServe] = []
        let request : NSFetchRequest<OneServe> = OneServe.fetchRequest()

        do{
            oldServeSizes = try context.fetch(request)
        } catch {
            print("Error loading OneServe \(error)")
        }
    
        let serveSizesPath = Bundle.main.path(forResource: "ServeSizes_Australia", ofType: "txt")
        
        if freopen(serveSizesPath, "r", stdin) == nil {
            perror(serveSizesPath)
        }
        
        //delete previous serve sizes in database
        var newServeSizes: [OneServe] = []
        
        for i in oldServeSizes {
            if i.custom {
                newServeSizes.append(i)
            } else {
                context.delete(i)
            }
        }
        
        oldServeSizes = []
        
        //read in new serve sizes
        while let line = readLine() {
            let fields: [String] = line.components(separatedBy: "\t")
            let newServe = OneServe(context: context)
            newServe.category = fields[0]
            newServe.order = Int16(Int(fields[1]) ?? 0)
            newServe.quantity1 = Double(fields[2]) ?? 0.0
            newServe.unit1 = fields[3]
            newServe.quantity2 = Double(fields[4]) ?? 0.0
            newServe.unit2 = fields[5]
            newServe.image = fields[6]
            newServe.detail = fields[7]
            newServe.custom = false
            newServe.serves = -1
            newServeSizes.append(newServe)
        }
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
    }
}
