//
//  ScheduleCell.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Alamofire

protocol ScheduleTableViewCellDelegate {
    func didTappedSwitch(cell: ScheduleCell)
}

class ScheduleCell: UITableViewCell {
    
    var schedule : Schedule!
    
    @IBOutlet weak var driverProfilePicture: UIImageView!
    
    @IBOutlet weak var driverName: UILabel!
    
    @IBOutlet weak var shuttleDepartureDate: UILabel!
    
    
    @IBOutlet weak var shuttleDepartureTime: UILabel!
    
    @IBOutlet weak var shuttleCapacity: UILabel!
    

    @IBOutlet weak var shuttleLicencePlate: UILabel!
    
    @IBOutlet weak var reserveSwitch: reserveSwitch!
    
    var delegate : ScheduleTableViewCellDelegate!
    
    @IBOutlet weak var reservationStatus: UILabel!
    
    
    @IBAction func reserveSwitchValueChanged(_ sender: Any) {
        delegate.didTappedSwitch(cell: self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateScheduleCell(_ schedule: Schedule){
        self.schedule = schedule
        
        shuttleDepartureDate.text = self.schedule.shuttleDepartureDate
        shuttleDepartureTime.text = self.schedule.shuttleDepartureTime
        driverName.text = self.schedule.driverName
        shuttleCapacity.text = self.schedule.shuttleCapacity
        shuttleLicencePlate.text = self.schedule.shuttleLicencePlate
      
        
        
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
