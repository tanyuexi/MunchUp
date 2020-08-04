//
//  NumberFormats.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/8/3.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import Foundation

class NumberFormatsTYX {
    
    func limitDigits(_ double: Double, max: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = max
        return formatter.string(from: NSNumber(value: double))!
    }
    
    func roundToHalf(_ double: Double) -> Double {
        return round(double*2)/2
    }
}
