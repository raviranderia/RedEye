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
}

class ScheduleCell: UITableViewCell {
    
    var schedule : Schedule!
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    @IBOutlet weak var driverProfilePicture: UIImageView!
    
    @IBOutlet weak var driverName: UILabel!
    
    @IBOutlet weak var shuttleDepartureDate: UILabel!
    
    
    @IBOutlet weak var shuttleDepartureTime: UILabel!
    
    @IBOutlet weak var shuttleCapacity: UILabel!
    

    @IBOutlet weak var shuttleLicencePlate: UILabel!
    
    @IBOutlet weak var reserveSwitch: reserveSwitch!
    
    var delegate : ScheduleTableViewCellDelegate!
    
    @IBOutlet weak var reservationStatus: UILabel!
    
    var isReserved = false
    
    @IBAction func reserveSwitchValueChanged(_ sender: Any) {
        delegate.didTappedSwitch(cell: self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
            self.reserveSwitch.isOn = false
        
        self.reservationStatus.text = "Switch button to reserve"
        
        
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
    
    func updateScheduleCell(_ schedule: Schedule){
        self.schedule = schedule
        isReserved = false
        shuttleDepartureDate.text = self.schedule.shuttleDepartureDate
        shuttleDepartureTime.text = self.schedule.shuttleDepartureTime
        driverName.text = self.schedule.driverName
        shuttleCapacity.text = self.schedule.shuttleCapacity
        shuttleLicencePlate.text = self.schedule.shuttleLicencePlate
      
    
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
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
