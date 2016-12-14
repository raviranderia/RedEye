//
//  DriverScheduleCell.swift
//  RedEye
//
//  Created by Marie Fonkou on 12/13/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase

class DriverScheduleCell: UITableViewCell {
    
    
    @IBOutlet weak var departureDate: UILabel!
   
    @IBOutlet weak var departureTime: UILabel!
    
    @IBOutlet weak var numSeatsLeft: UILabel!
    
    @IBOutlet weak var aboutToLeaveBtn: LoginButton!
    var schedule : Schedule!
    
    
    @IBAction func aboutToLeaveBtnPressed(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        let scheduleId = defaults.string(forKey: "\(sender.tag)")
        print("schedule id \(scheduleId)")
        
        let scheduleReference = Constants.URL.ref.child("Schedule").child(scheduleId!)
        let updateScheduleValues = ["scheduleActive": "NO"]
        scheduleReference.updateChildValues(updateScheduleValues, withCompletionBlock: { (error, ref) in
            if error != nil {
                print ("Error saving major in database: \(error?.localizedDescription)")
                return
            } else{
                
            }
        })
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func updateDriverSchedule(_ schedule: Schedule){
         self.schedule = schedule
        departureDate.text = reformatDate(self.schedule.shuttleDepartureDate!)
        departureTime.text = self.schedule.shuttleDepartureTime
        numSeatsLeft.text = self.schedule.shuttleCapacity
        
    }
    
    
    func reformatDate(_ shuttleDepartureDate : String) -> String{
        let dateFormatter = DateFormatter()
        let date = shuttleDepartureDate
        
        dateFormatter.dateFormat = "MM, dd, yyyy"
        let stringDate = dateFormatter.date(from: date)
        
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        let formattedDate = dateFormatter.string(from: stringDate!)
        
        return formattedDate
    }
    
//    func getScheduleIdForSelectedCell(_ schedule : Schedule){
//        self.schedule = schedule
//        print("schedule id \(schedule.id)")
//        let defaults = UserDefaults.standard
//        defaults.set(schedule.id, forKey: "idSelectedSchedule")
//        aboutToLeaveBtn.addTarget(self, action: #selector(DriverScheduleCell.aboutToLeaveBtnPressed(_:)), for: UIControlEvents.touchUpInside)
//        
//        
//    }

}
