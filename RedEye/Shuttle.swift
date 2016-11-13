//
//  Shuttle.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class Shuttle: NSObject {
    
    var numberOfSeatsAvailable: Int?
    var studentsToDrive: [Student] = []
    
    enum departureTime: String {
        
        case one = "7:00 PM"
        case two = "7:30 PM"
        case three = "8:00 PM"
        case four = "8:30 PM"
        case six = "9:00 PM"
        case seven = "9:30 PM"
        case eight = "10:00 PM"
        case nine = "10:30 PM"
        case ten = "11:00 PM"
        case eleven = "11:30 PM"
        case twelve = "12:00 AM"
        case thirteen = "12:30 AM"
        case fourteen = "1:00 AM"
        case fifteen = "1:30 AM"
        case sixteen = "2:00 AM"
        case seventeen = "2:30 AM"
        case eighteen = "3:00 AM"
        case nineteen = "3:30 AM"
        case twenty = "4:00 AM"
        case twentyOne = "4:30 AM"
        case twentyTwo = "5:00 AM"
        case twentyThree = "5:30 AM"
        case twentyFour = "6:00 AM"
    }
    
    

}
