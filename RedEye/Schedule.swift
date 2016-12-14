//
//  Schedule.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/24/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class Schedule: NSObject {
    
    var id: String!
    
    var shuttleDepartureDate: String!
    
    var shuttleID: String!
    
    var driverID: String!
    
    var shuttleDepartureTime: String!
    
    var driverName: String!
    
    var driverLastName: String!
    
    var driverProfilePicture: String!
    
    var shuttleLicencePlate: String!
    
    var shuttleCapacity: String!
    
    var reserved: Bool = false
    
    var currentSeatAvalaible: String!
    
    var studentWhoReserved = [Student]()
    
    var currentReservations = Array<Any>()
    
    var reservations = [Reservation]()
    
    var reservationID = [String]()
    
    var scheduleActive: String!
    
    
    
    var _shuttleDepartureDate: String{
        if shuttleDepartureDate == nil{
            shuttleDepartureDate = ""
        }
        return shuttleDepartureDate
    }
    
    var _shuttleID: String{
        if shuttleID == nil{
            shuttleID = ""
        }
        return shuttleID
    }

    var _driverID: String{
        if driverID == nil{
            driverID = ""
        }
        return driverID
    }
    
    var _shuttleDepartureTime: String{
        if shuttleDepartureTime == nil{
            shuttleDepartureTime = ""
        }
        return shuttleDepartureTime
    }
    
    
    var _driverName: String{
        if driverName == nil{
            driverName = ""
        }
        return driverName
    }
    
    
    var _driverLastName: String{
        if driverLastName == nil{
            driverLastName = ""
        }
        return driverLastName
    }
    
    var _driverProfilePicture: String{
        if driverProfilePicture == nil{
            driverProfilePicture = ""
        }
        return driverProfilePicture
    }
    
    var _shuttleCapacity: String{
        if shuttleCapacity == nil{
            shuttleCapacity = ""
        }
        return shuttleCapacity
    }
    
    var _currentSeatAvalaible: String{
        if currentSeatAvalaible == nil{
            currentSeatAvalaible = ""
        }
        return currentSeatAvalaible
    }

    
    override init(){
        
    }
    
    init(id: String, shuttleDepartureDate: String, shuttleDepartureTime:String, numSeatLeft: String){
        self.id = id
        self.shuttleDepartureDate = shuttleDepartureDate
        self.shuttleDepartureTime = shuttleDepartureTime
        self.shuttleCapacity = numSeatLeft
    }
    
    init (id: String, shuttleDepartureDate: String, shuttleID:String, driverID: String, shuttleDepartureTime:String, driverName: String, driverLastName : String , driverProfilePicture : String , shuttleCapacity: String,
          shuttleLicencePlate: String){
        
        self.id = id
        self.shuttleDepartureDate = shuttleDepartureDate
        self.shuttleID = shuttleID
        self.driverID = driverID
        self.shuttleDepartureTime = shuttleDepartureTime
        self.driverName = driverName
        self.driverLastName = driverLastName
        self.driverProfilePicture = driverProfilePicture
        self.shuttleCapacity = shuttleCapacity
        self.shuttleLicencePlate = shuttleLicencePlate
    }

}
