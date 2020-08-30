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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(getFilePath(directory: true)!)
        
        selectedIndex = 1  //shopping list appears first

        //if days not set, let days = 7
        if getDays() == 0 {
            updateDays(7)
        }
        
        loadPeople(to: &peopleArray)
        loadItems(to: &itemArray)
        calculateDailyTotalServes(from: &peopleArray, to: &dailyTotal)

        
        //initialize food database
//        let appLanguage = Locale.preferredLanguages[0]
//        if K.defaults.string(forKey: "Localization") != appLanguage {
            resetFoodDatabase()
//            K.defaults.set(appLanguage, forKey: "Localization")
//        }
        
        for category in K.foodGroups {
            var foodByCategory: [Food] = []
            loadFood(to: &foodByCategory, category: category)
            foodDict[category] = foodByCategory
        }

        
        let peopleVC = viewControllers![0] as! PeopleTableVC
        let listContainerVC = viewControllers![1] as! ListContainerVC
//        let settingsVC = viewControllers![2] as! SettingsTableVC
        peopleVC.peopleArray = peopleArray
        listContainerVC.foodDict = foodDict
        listContainerVC.itemArray = itemArray
        listContainerVC.dailyTotal = dailyTotal
        listContainerVC.reloadListTable()


    }

}
