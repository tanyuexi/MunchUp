//
//  CommonOneServe.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/1.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import Foundation

struct CommonOneServe {
    let detail: String?
    let unit1: String?
    let quantityOfUnit1: Double?
    let unit2: String?
    let quantityOfUnit2: Double?
    
    init(d: String, u1: String, q1: Double, u2: String, q2: Double){
        detail = d
        unit1 = u1
        quantityOfUnit1 = q1
        unit2 = u2
        quantityOfUnit2 = q2
    }
}
