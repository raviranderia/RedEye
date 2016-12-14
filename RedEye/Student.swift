//
//  Student.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class Student: NSObject {
    
    //var studentId: Int?
    var studentFirstName: String?
    var studentLastName: String?
    var studentAddress: String?
    var studentHuskyEmailAddress: String?
    var studentProfilePicture: String?
    var studentMajor: String?
    
    var _studentFirstName: String{
        if studentFirstName == nil{
            studentFirstName = ""
        }
        return studentFirstName!
    }
    
    var _studentLastName: String{
        if studentLastName == nil{
            studentLastName = ""
        }
        return studentLastName!
    }
    
    var _studentHuskyEmailAddress: String{
        if studentHuskyEmailAddress == nil{
            studentHuskyEmailAddress = ""
        }
        return studentHuskyEmailAddress!
    }
    
    var _studentAddress: String{
        if studentAddress == nil{
            studentAddress = ""
        }
        return studentAddress!
    }
    
    var _studentProfilePicture: String{
        if studentProfilePicture == nil{
            studentProfilePicture = ""
        }
        return studentProfilePicture!
    }
    
    var _studentMajor: String{
        if studentMajor == nil{
            studentMajor = ""
        }
        return studentMajor!
    }
    
    override init(){
        
    }
    
    init(studentFirstName: String, studentLastName: String, studentProfilePicture: String , studentMajor: String) {
        self.studentFirstName = studentFirstName
        self.studentLastName = studentLastName
        self.studentMajor = studentMajor
        self.studentProfilePicture = studentProfilePicture
    }
    
    init(studentFirstName: String, studentLastName: String, studentAddress: String, studentHuskyEmailAddress: String, studentProfilePicture: String , studentMajor: String) {
        self.studentFirstName = studentFirstName
        self.studentLastName = studentLastName
        self.studentAddress = studentAddress
        self.studentHuskyEmailAddress = studentHuskyEmailAddress
        self.studentMajor = studentMajor
    }
    
 
    
    

}
