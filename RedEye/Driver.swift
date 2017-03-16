//
//  Driver.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/24/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

// Would try to make this a struct...since struct is a data type and that makes swift processing easier. Also you probably dont have to write init function as a struct will automatically do that for you.
class Driver: NSObject {
    
    private let driverFirstName: String?
    private let driverLastName: String?
    private let driverEmailAddress: String?
    private let driverProfilePicture: String?
    
    init(driverFirstName: String, driverLastName: String, driverProfilePicture: String , driverEmailAddress: String) {
        self.driverFirstName = driverFirstName
        self.driverLastName = driverLastName
        self.driverEmailAddress = driverEmailAddress
        self.driverProfilePicture = driverProfilePicture
    }
    
    var _driverFirstName: String{
        guard let driverFirstName = driverFirstName else { return "" }
        return driverFirstName
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
    



}
