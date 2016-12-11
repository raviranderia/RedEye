//
//  Reservation.swift
//  RedEye
//
//  Created by Marie Fonkou on 12/4/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class Reservation: NSObject {
    
    var reservationTimeStamp: String!
    var reservationStatus: String!
    var studentUniqueId: String!
    
    var _reservationTimeStamp: String{
        if reservationTimeStamp == nil{
            reservationTimeStamp = ""
        }
        return reservationTimeStamp!
    }
    
    var _reservationStatus: String{
        if reservationStatus == nil{
            reservationStatus = ""
        }
        return reservationStatus!
    }

    
    var _studentUniqueId: String{
        if studentUniqueId == nil{
            studentUniqueId = ""
        }
        return studentUniqueId!
    }
    
    override init(){
        
    }
    
    init(reservationTimeStamp: String, reservationStatus: String, studentUniqueId: String) {
        self.reservationTimeStamp = reservationTimeStamp
        self.reservationStatus = reservationStatus
        self.studentUniqueId = studentUniqueId
    }


}
