//
//  TabBarController.swift
//  MunchUp
//
//  Created by Yuexi Tan on 2020/8/28.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import UIKit
import CoreData

class TabBarController: UITabBarController {
    
    var peopleArray: [People] = []
    var foodDict: [String: [Food]] = [:]
    var itemArray: [Item] = []
    var dailyTotal: [String: Double] = [:]
    var days = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(getFilePath(directory: true)!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotification(notification:)), name: K.notificationName, object: nil)

        //if days not set, let days = 7
        days = getDays()
        if days == 0 {
            updateDays(7)
            days = 7.0
        }

        loadPeople(to: &peopleArray)
        calculateDailyTotalServes(from: peopleArray, to: &dailyTotal)
        loadItems(to: &itemArray)
        if itemArray.count == 0 {
            let emptyItem = Item(context: K.context)
            emptyItem.lastEdited = Date()
            itemArray.append(emptyItem)
        }
        
        //initialize food database
        let appLanguage = Locale.preferredLanguages[0]
        if K.defaults.string(forKey: "Localization") != appLanguage {
            resetFoodDatabase()
            K.defaults.set(appLanguage, forKey: "Localization")
        }
        loadFood(to: &foodDict)
        
        //show shopping list first
        selectedIndex = 1
    }
    
}

//MARK: - Notification center

extension TabBarController {

    @objc func onNotification(notification: Notification) {
        
        if let userInfo = notification.userInfo as? [String: Any] {
            for (key, data) in userInfo {
                if key == "pass data to ListContainerVC" {
                    postNotification([
                        "days": days,
                        "peopleCount": peopleArray.count
                    ])
                }
                
                if key == "pass data to ListTableVC" {
                    postNotification([
                        "days": days,
                        "foodDict": foodDict,
                        "itemArray": itemArray,
                        "dailyTotal": dailyTotal
                    ])
                }
                
                if key == "pass data to PeopleTableVC" {
                    postNotification([
                        "peopleArray": peopleArray
                    ])
                }
                
                if key == "peopleArray update" {
                    peopleArray = data as! [People]
                    calculateDailyTotalServes(from: peopleArray, to: &dailyTotal)
                    postNotification([
                        "peopleCount": peopleArray.count,
                        "dailyTotal": dailyTotal
                    ])
                }
                
                if key == "days" {
                    days = data as! Double
                }
                
                if key == "itemArray update" {
                    itemArray = data as! [Item]
                }
                
                if key == "resetFoodDatabase" {
                    resetFoodDatabase()
                    loadFood(to: &foodDict)
                    postNotification([
                        "foodDict": foodDict
                    ])
                    
                }
            }
        }
        

//        
//        if let data = notification.userInfo?["foodDict"] as? [String: [Food]] {
//            foodDict = data
//        }
//        

//        

        
        
        

    }
    
}
