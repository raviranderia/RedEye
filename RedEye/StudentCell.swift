//
//  StudentCell.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    
    
    @IBOutlet weak var studentFirstName: UILabel!

    @IBOutlet weak var studentLastName: UILabel!
    
    @IBOutlet weak var studentMajor: UILabel!
    
    @IBOutlet weak var studentProfilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        studentProfilePicture.layer.cornerRadius = studentProfilePicture.frame.size.height/2
        studentProfilePicture.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
