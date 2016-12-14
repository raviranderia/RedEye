//
//  ScheduleCell.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

protocol ScheduleTableViewCellDelegate {
    func didTappedSwitch(cell: ScheduleCell)
    func didTappedViewStudentButton(cell: ScheduleCell)
}

class ScheduleCell: UITableViewCell {
    
    var schedule : Schedule!
    
    var reservationList = [String]()
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    @IBOutlet weak var driverProfilePicture: UIImageView!
    
    var driverProfilePictureUrl : String!

    @IBOutlet weak var driverFirstName: UILabel!
    
    @IBOutlet weak var driverLastName: UILabel!
    
    @IBOutlet weak var shuttleDepartureDate: UILabel!
    
    
    @IBOutlet weak var shuttleDepartureTime: UILabel!
    
    @IBOutlet weak var shuttleCapacity: UILabel!
    

    @IBOutlet weak var shuttleLicencePlate: UILabel!
    
    @IBOutlet weak var reserveSwitch: reserveSwitch!
    
    var delegate : ScheduleTableViewCellDelegate!
    
    @IBOutlet weak var reservationStatus: UILabel!
    
    var isReserved = false
    
    
    @IBOutlet weak var viewStudentsBtn: UIButton!
    
    @IBAction func viewStudents(_ sender: Schedule) {
        
        delegate.didTappedViewStudentButton(cell: self)
//        self.schedule = sender
//        reservationList = schedule.reservationID
//        print ("reservationList \(reservationList)")

    }
    
    
    @IBAction func reserveSwitchValueChanged(_ sender: Any) {
        delegate.didTappedSwitch(cell: self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        driverProfilePicture.layer.cornerRadius = driverProfilePicture.frame.size.height/2
        driverProfilePicture.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
            self.reserveSwitch.isOn = false
        
        self.reservationStatus.text = ""
        
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateScheduleCell(_ schedule: Schedule){
        self.schedule = schedule
        isReserved = false
        shuttleDepartureDate.text = self.reformatDate(self.schedule.shuttleDepartureDate!)
        shuttleDepartureTime.text = self.schedule.shuttleDepartureTime
        driverFirstName.text = self.schedule.driverName
        driverLastName.text = self.schedule.driverLastName
        shuttleCapacity.text = self.schedule.shuttleCapacity
        shuttleLicencePlate.text = self.schedule.shuttleLicencePlate
        driverProfilePictureUrl = self.schedule.driverProfilePicture
        if driverProfilePictureUrl == "No profile picture" {
            driverProfilePicture.image = UIImage(named:"Profile Picture Icon-2")
        } else{
            driverProfilePicture.loadImageWithCache(urlString: driverProfilePictureUrl)
            
        }
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

    func updateReservationStatusCell(_ schedule: Schedule){
        self.schedule = schedule
        
        if (self.schedule.reserved == true){
            reservationStatus.text = "Reserved"
        } else{
           reservationStatus.text = "Reservation Cancelled"
        }
        
    }
    
    func updatedSchedule(_ schedule: Schedule){
         self.schedule = schedule
        print(schedule.currentSeatAvalaible)
        self.shuttleCapacity.text = schedule.currentSeatAvalaible
    }


}

extension String {
    
}
