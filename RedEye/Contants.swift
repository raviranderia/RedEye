//
//  Contants.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import Foundation
import UIKit
import Firebase

  typealias DownloadComplete = () -> ()

struct Constants{
    
    
    struct Google{
        static let LIBRARY_PLACE_ID = "place_id:ChIJ4VzPmRl644kRw5bUbgV-4UY"
        static let API_KEY = "&key=AIzaSyCpz9dknKXt58wCNXYqYFNsrsIOH5vH6Rs"
        static let GEOLOCATION_API_KEY = "&key=AIzaSyDu4yQJitQkunAeQx_q_WXpaTXzM6buWdU"
        static let DESTINATION = "&destination=place_id:"
        static let WAYPOINTS = "&waypoints=place_id:"
    }
    
    struct Firebase{
        let KEY_UID = "uid"
        
    }
    
    struct Colors {
        static let redColor = UIColor(red: 208/255, green: 2/255, blue: 27/255, alpha: 100)
        static let grayColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 100)
        static let lightGrayColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 100)
    }
    
    struct URL {
        static let gmailURL = "googlegmail://"
        static let firebaseDatabase = "https://nuredeye-84bef.firebaseio.com/"
        static let googleMapDirectionAPI = "https://maps.googleapis.com/maps/api/directions/json?origin=\(Constants.Google.LIBRARY_PLACE_ID)"
        static let googleGeocodingAPI = "https://maps.googleapis.com/maps/api/geocode/json?address="
        static let ref = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
    }
    
}


