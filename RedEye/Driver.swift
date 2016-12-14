//
//  Driver.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/24/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class Driver: NSObject {
    
    var driverFirstName: String?
    var driverLastName: String?
    var driverEmailAddress: String?
    var driverProfilePicture: String?
    
    var _driverFirstName: String{
        if driverFirstName == nil{
            driverFirstName = ""
        }
        return driverFirstName!
    }
    
    var _driverLastName: String{
        if driverLastName == nil{
            driverLastName = ""
        }
        return driverLastName!
    }
    
    var _driverEmailAddress: String{
        if driverEmailAddress == nil{
            driverEmailAddress = ""
        }
        return driverEmailAddress!
    }
    
    var _driverProfilePicture: String{
        if driverProfilePicture == nil{
            driverProfilePicture = ""
        }
        return driverProfilePicture!
    }
    
    override init(){
        
    }
    
    init(driverFirstName: String, driverLastName: String, driverProfilePicture: String , driverEmailAddress: String) {
        self.driverFirstName = driverFirstName
        self.driverLastName = driverLastName
        self.driverEmailAddress = driverEmailAddress
        self.driverProfilePicture = driverProfilePicture
    }


}
