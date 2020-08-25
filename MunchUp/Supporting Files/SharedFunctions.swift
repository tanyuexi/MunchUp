//
//  SharedFunctions.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/3.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData
import func AVFoundation.AVMakeRect


extension UIViewController {
    
    //MARK: - plist
    func updateDays(_ int: Int){
        K.defaults.set(int, forKey: K.daysString)
    }
    
    
    func getDays() -> Double {
        let days = K.defaults.integer(forKey: K.daysString)
        return Double(days)
    }
    
    
    //MARK: - Core Data
    func reloadServeSizes(){
        
        //load old serve sizes
        var oldServeSizes: [OneServe] = []
        let request : NSFetchRequest<OneServe> = OneServe.fetchRequest()

        do{
            oldServeSizes = try K.context.fetch(request)
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
                K.context.delete(i)
            }
        }
        
        oldServeSizes = []
        
        //read in new serve sizes
        while let line = readLine() {
            let fields: [String] = line.components(separatedBy: "\t")
            let newServe = OneServe(context: K.context)
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
        
        saveContext()
        
    }
    
    
    func saveContext(){
        do {
            try K.context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    func loadFamilyMembers(to array: inout [FamilyMember]) {
        let request : NSFetchRequest<FamilyMember> = FamilyMember.fetchRequest()
        let sortByAge = NSSortDescriptor(key: "dateOfBirth", ascending: true)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortByAge, sortByName]
        do{
            array = try K.context.fetch(request)
        } catch {
            print("Error loading FamilyMembers \(error)")
        }
    }
    
    
    func loadItems(to array: inout [OtherItem]) {
        let request : NSFetchRequest<OtherItem> = OtherItem.fetchRequest()
        let sortByDate = NSSortDescriptor(key: "lastEdited", ascending: false)
        request.sortDescriptors = [sortByDate]
        do{
            array = try K.context.fetch(request)
        } catch {
            print("Error loading OtherItem \(error)")
        }
    }
    
    func loadServeSizes(to array: inout [OneServe], category: String) {
        
        let request : NSFetchRequest<OneServe> = OneServe.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "category == %@", category)
        request.predicate = categoryPredicate
        
        let sortByOrder = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortByOrder]
        
        do{
            array = try K.context.fetch(request)
        } catch {
            print("Error loading OneServe \(error)")
        }
    }


    
    //MARK: - Number formatting
    func limitDigits(_ double: Double, max: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max
        return formatter.string(from: NSNumber(value: double))!
    }
    
    
    func roundToHalf(_ double: Double) -> Double {
        return round(double*2)/2
    }
    
    
//    func formatWeight(_ grams: Double) -> String {
//        if grams < 1000 {
//            return limitDigits(grams)
//        } else {
//            return limitDigits(grams/1000)
//
//        }
//    }
    
    
    //MARK: - UI handling
    func enableSaveButton(_ button: UIButton, enable: Bool = true){
        if enable {
            button.isEnabled = true
            button.backgroundColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        } else {
            button.isEnabled = false
            button.backgroundColor = .systemGray
        }
    }
    
    //MARK: - Image
    func scaleImage(_ image: UIImage, within rect: CGRect) -> UIImage? {
        
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: rect)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: rect.size))
        }
    }
    
}
