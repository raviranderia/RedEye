//
//  StudentCell.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    
    var student = Student()
    
    @IBOutlet weak var studentFirstName: UILabel!

    @IBOutlet weak var studentLastName: UILabel!
    
    @IBOutlet weak var studentMajor: UILabel!
    
    @IBOutlet weak var studentProfilePicture: UIImageView!
    
    var profilePictureUrl : String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        studentProfilePicture.layer.cornerRadius = studentProfilePicture.frame.size.height/2
        studentProfilePicture.layer.masksToBounds = true
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateStudentCell(_ student: Student){
        self.student = student
       
        
        studentFirstName.text = self.student.studentFirstName
        print("studentFirstName.text \(studentFirstName.text)")
        studentLastName.text = self.student.studentLastName
        print("studentLastName.text \(studentLastName.text)")
        studentMajor.text = self.student.studentMajor
        print("studentMajor.text  \(studentMajor.text )")
        profilePictureUrl = self.student.studentProfilePicture
        print("profilePictureUrl \(profilePictureUrl)")
        
        if profilePictureUrl.contains("Profile Picture") {
            studentProfilePicture.image = UIImage(named:"Profile Picture Icon-2")
        } else {
            let imageUrl = NSURL(string: profilePictureUrl)
            if imageUrl == nil {
                studentProfilePicture.image = UIImage(named:"Profile Picture Icon-2")
            } else {
                let placeHolderOmage = UIImage.init(named: "Profile Picture Icon-2")
                studentProfilePicture.sd_setImage(with: imageUrl as! URL, placeholderImage: placeHolderOmage)
            }
            
        }
        
        
        
        
        //studentProfilePicture.sd_setImage(NSURL(string: profilePictureUrl), placeholderImage:UIImage(named: "Profile Picture Icon-2"))
        
//
//            if profilePictureUrl == "No profile picture"{
//                studentProfilePicture.image = UIImage(named:"Profile Picture Icon-2")
//            } else{
//                studentProfilePicture.loadImageWithCache(urlString: profilePictureUrl)
//            }
        
        
        
    }

}
