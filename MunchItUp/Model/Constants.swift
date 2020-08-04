//
//  Constants.swift
//  MunchItUp
//
//  Created by Yuexi Tan on 2020/7/17.
//  Copyright © 2020 Yuexi Tan. All rights reserved.
//

import Foundation

struct K {
    static let memberCellID = "MemberReusableCell"
    static let addingMemberCellID = "AddingMemberReusableCell"
    static let foodGroupCellID = "FoodGroupReusableCell"
    static let otherItemCellID = "OtherItemReusableCell"
    static let servesCalculatorCellID = "ServesCalculatorReusableCell"
    
    //Daily Five Group Serves Table
    //source: https://www.eatforhealth.gov.au/food-essentials/how-much-do-we-need-each-day/recommended-number-serves-children-adolescents-and
    //for Toddler(1-2yrs), mid value serves is used in stead of range
    //for addition, mid value is used in stead of range
    //if pregnant & breastfeeding, max value is used
    //keys: M=Male, F=Female, P=Pregnant, B=Breastfeeding
    //dailyServes = ["food": ["age gender&condition": serves]]
    static let dailyServes = [
        "Vegetable": [
            //Boys
            "1 M": 2.5,
            "2 M": 2.5,
            "4 M": 4.5,
            "9 M": 5,
            "12 M": 5.5,
            "14 M": 5.5,
            //Girls
            "1 F": 2.5,
            "2 F": 2.5,
            "4 F": 4.5,
            "9 F": 5,
            "12 F": 5,
            "14 F": 5,
            //Children pregnant/breastfeeding
            "1 FP": 5,
            "1 FB": 5.5,
            "1 FPB": 5.5,
            //Male
            "19 M": 6,
            "51 M": 5.5,
            "70 M": 5,
            //Female
            "19 F": 5,
            "51 F": 5,
            "70 F": 5,
            //Adult pregnant/breastfeeding
            "19 FP": 5,
            "19 FB": 7.5,
            "19 FPB": 7.5
        ],
        
        "Fruit": [
            //Boys
            "1 M": 0.5,
            "2 M": 1,
            "4 M": 1.5,
            "9 M": 2,
            "12 M": 2,
            "14 M": 2,
            //Girls
            "1 F": 0.5,
            "2 F": 1,
            "4 F": 1.5,
            "9 F": 2,
            "12 F": 2,
            "14 F": 2,
            //Children pregnant/breastfeeding
            "1 FP": 2,
            "1 FB": 2,
            "1 FPB": 2,
            //Male
            "19 M": 2,
            "51 M": 2,
            "70 M": 2,
            //Female
            "19 F": 2,
            "51 F": 2,
            "70 F": 2,
            //Adult pregnant/breastfeeding
            "19 FP": 2,
            "19 FB": 2,
            "19 FPB": 2
        ],
        
        "Grain": [
            //Boys
            "1 M": 4,
            "2 M": 4,
            "4 M": 4,
            "9 M": 5,
            "12 M": 6,
            "14 M": 7,
            //Girls
            "1 F": 4,
            "2 F": 4,
            "4 F": 4,
            "9 F": 4,
            "12 F": 5,
            "14 F": 7,
            //Children pregnant/breastfeeding
            "1 FP": 8,
            "1 FB": 9,
            "1 FPB": 9,
            //Male
            "19 M": 6,
            "51 M": 6,
            "70 M": 4.5,
            //Female
            "19 F": 6,
            "51 F": 4,
            "70 F": 3,
            //Adult pregnant/breastfeeding
            "19 FP": 8.5,
            "19 FB": 9,
            "19 FPB": 9
        ],
        
        "Protein": [
            //Boys
            "1 M": 1,
            "2 M": 1,
            "4 M": 1.5,
            "9 M": 2.5,
            "12 M": 2.5,
            "14 M": 2.5,
            //Girls
            "1 F": 1,
            "2 F": 1,
            "4 F": 1.5,
            "9 F": 2.5,
            "12 F": 2.5,
            "14 F": 2.5,
            //Children pregnant/breastfeeding
            "1 FP": 3.5,
            "1 FB": 2.5,
            "1 FPB": 3.5,
            //Male
            "19 M": 3,
            "51 M": 2.5,
            "70 M": 2.5,
            //Female
            "19 F": 2.5,
            "51 F": 2,
            "70 F": 2,
            //Adult pregnant/breastfeeding
            "19 FP": 3.5,
            "19 FB": 2.5,
            "19 FPB": 3.5
        ],
        
        "Calcium": [
            //Boys
            "1 M": 1.25,
            "2 M": 1.5,
            "4 M": 2,
            "9 M": 2.5,
            "12 M": 3.5,
            "14 M": 3.5,
            //Girls
            "1 F": 1.25,
            "2 F": 1.5,
            "4 F": 1.5,
            "9 F": 3,
            "12 F": 3.5,
            "14 F": 3.5,
            //Children pregnant/breastfeeding
            "1 FP": 3.5,
            "1 FB": 4,
            "1 FPB": 4,
            //Male
            "19 M": 2.5,
            "51 M": 2.5,
            "70 M": 3.5,
            //Female
            "19 F": 2.5,
            "51 F": 4,
            "70 F": 4,
            //Adult pregnant/breastfeeding
            "19 FP": 2.5,
            "19 FB": 2.5,
            "19 FPB": 2.5
        ],
        
        "Additional": [
            //Boys
            "1 M": 0,
            "2 M": 1,
            "4 M": 2.5,
            "9 M": 3,
            "12 M": 3,
            "14 M": 5,
            //Girls
            "1 F": 0,
            "2 F": 1,
            "4 F": 1,
            "9 F": 3,
            "12 F": 2,
            "14 F": 2,
            //Children pregnant/breastfeeding
            "1 FP": 3,
            "1 FB": 3,
            "1 FPB": 3,
            //Male
            "19 M": 3,
            "51 M": 2.5,
            "70 M": 2.5,
            //Female
            "19 F": 2.5,
            "51 F": 2.5,
            "70 F": 2,
            //Adult pregnant/breastfeeding
            "19 FP": 2.5,
            "19 FB": 2.5,
            "19 FPB": 2.5
        ],
        
        "Oil": [
            //Boys
            "1 M": 0,
            "2 M": 0.5,
            "4 M": 1,
            "9 M": 1,
            "12 M": 1.5,
            "14 M": 2,
            //Girls
            "1 F": 0,
            "2 F": 0.5,
            "4 F": 1,
            "9 F": 1,
            "12 F": 1.5,
            "14 F": 2,
            //Children pregnant/breastfeeding
            "1 FP": 2,
            "1 FB": 2,
            "1 FPB": 2,
            //Male
            "19 M": 4,
            "51 M": 4,
            "70 M": 2,
            //Female
            "19 F": 2,
            "51 F": 2,
            "70 F": 2,
            //Adult pregnant/breastfeeding
            "19 FP": 2,
            "19 FB": 2,
            "19 FPB": 2
        ]
    ]
    
    //Serve Sizes
    //source: https://www.eatforhealth.gov.au/food-essentials/how-much-do-we-need-each-day/serve-sizes
    //serveSizes = ["food": [OneServe]]
//    static let serveSizes = [
//        "Vegetable": [
//            CommonOneServe(d:"cooked green or orange vegetables (for example, broccoli, spinach, carrots or pumpkin)", u1:"cup", q1:0.5, u2:"g", q2:75),
//            CommonOneServe(d:"cooked dried or canned beans, peas or lentils (preferably with no added salt)", u1:"cup", q1:0.5, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:)
//        ],
//        
//        "Fruit": [
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:)
//        ],
//        
//        "Grain": [
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:)
//        ],
//        
//        "Protein": [
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:)
//        ],
//        
//        "Calcium": [
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:)
//        ],
//        
//        "Nut": [
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:),
//            CommonOneServe(d:"", u1:"", q1:, u2:"", q2:)
//        ],
//    ]
}
