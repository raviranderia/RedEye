//
//  StudentAddress.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/12/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class StudentAddress: NSObject {
    
    var _address: String?
    var _placeID: String?
    var _latitude: Double?
    var _longitude: Double?
    
    
    var address: String{
        if _address == nil{
            _address = ""
        }
        return _address!
    }

    var placeID: String{
        if _placeID == nil{
            _placeID = ""
        }
        return _placeID!
    }
    
    var latitude: Double {
        if _latitude == nil {
            _latitude = 0.0
        }
        return _latitude!
    }
    
    var longitude: Double {
        if _longitude == nil {
            _longitude = 0.0
        }
        return _longitude!
    }
    
    override init(){
        
    }
    
    init(latitude: Double, longitude: Double) {
        self._latitude = latitude
        self._longitude = longitude
    }

}
