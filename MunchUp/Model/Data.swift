//
//  Data.swift
//  MunchUp
//
//  Created by Yuexi Tan on 2020/9/13.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import Foundation
import CoreData

class Data {
    static let shared = Data()   //Singleton
    var peopleArray: [People] = []
    var foodDict: [String: [Food]] = [:]
    var itemArray: [Item] = []
    var dailyTotal: [String: Double] = [:]
    var days: Double = 0
    
}
