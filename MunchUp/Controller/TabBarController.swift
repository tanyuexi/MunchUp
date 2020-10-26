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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(getFilePath(directory: true)!)

        //if days not set, let days = 7
        Data.shared.days = getDays()
        if Data.shared.days == 0 {
            updateDays(7)
            Data.shared.days = 7.0
        }

        loadPeople(to: &Data.shared.peopleArray)
        calculateDailyTotalServes(from: Data.shared.peopleArray, to: &Data.shared.dailyTotal)
        loadItems(to: &Data.shared.itemArray)
        if Data.shared.itemArray.count == 0 {
            let emptyItem = Item(context: K.context)
            emptyItem.lastEdited = Date()
            Data.shared.itemArray.append(emptyItem)
        }
        
        //initialize food database
        let appLanguage = Locale.preferredLanguages[0]
        if K.defaults.string(forKey: "Localization") != appLanguage {
            resetFoodDatabase()
            K.defaults.set(appLanguage, forKey: "Localization")
        }
        loadFood(to: &Data.shared.foodDict)
        
        //show shopping list first
        selectedIndex = 1
        

    }
    

}

