//
//  ScheduleController.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/18/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Alamofire

// 1. List all shuttle departure time from 7 PM to 6 AM
// 2. The 7 PM shuttle disapears when the driver left 

// create a child under each schedule id - increment the number of seat reserved - call constructor for schedule to update cell

class ScheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleTableViewCellDelegate {

    var scheduleList = [Schedule]()
    var reservationList = [Dictionary<String,AnyObject>]()
    var scheduleCell = [ScheduleCell]()
    var driversList = [Dictionary<String,AnyObject>]()
    var shuttleList = [Dictionary<String,AnyObject>]()
    var scheduleIds = [String]()
    var reservationMade: Bool = false
    var numSeatReservation = 0
    var shuttleCapacityNum: String = ""
    var schedule = Schedule()
    var reservation = Reservation()
    var upcomingReservationMade: Bool = false
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "schedule"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]

        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        
        fetchDriversInformation()
        fetchShuttleInformation()
        fetchShuttleSchedule()
        
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return scheduleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as? ScheduleCell{
            var schedule : Schedule!
            schedule = scheduleList[indexPath.row]
            cell.delegate = self
            cell.updateScheduleCell(schedule)
          
        
        return cell
        }
        else{
            return UITableViewCell()
        }
    
    }
    
    
    func fetchDriversInformation(){
        
        var driverInformation = [String: String]()
        
          FIRDatabase.database().reference().child("Drivers").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let driverFirstName = dictionary["driverFirstName"] as? String
                let driverLastName = dictionary["driverLastName"] as? String
                let driverId = dictionary["driverID"] as? String
                let driverEmailAddress = dictionary["driverEmailAddress"] as? String
                
                driverInformation["driverFirstName"] = driverFirstName
                 driverInformation["driverLastName"] = driverLastName
                 driverInformation["driverId"] = driverId
                 driverInformation["driverEmailAddress"] = driverEmailAddress
                self.driversList.append(driverInformation as [String : AnyObject])
                
                print("GET DRIVER INFO \(self.driversList)")

                
            }
            
          } , withCancel: nil)
    }
    
    func fetchShuttleInformation(){
        
         var shuttleInformation = [String: String]()
        
        FIRDatabase.database().reference().child("Shuttles").observe(.childAdded, with: {(snapshot) in
        
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let licencePlate = dictionary["shuttleLicencePlate"] as? String
                let shuttleCapacity = dictionary["shuttleCapacity"] as? String
                
                shuttleInformation["shuttleLicencePlate"] = licencePlate
                shuttleInformation["shuttleCapacity"] = shuttleCapacity
                self.shuttleList.append(shuttleInformation as [String: AnyObject])
            }
        
        } , withCancel: nil)
        
    }
    
    func fetchShuttleSchedule(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        
        var driverID: String = ""
        var shuttleID:  String = ""
        var shuttleDepartureDate: String = ""
        var shuttleDepartureTime: String = ""
        var driverFirstName : String = ""
        var shuttleLicencePlateNum: String = ""
        var numSeatsLeft: String = ""
        
        FIRDatabase.database().reference().child("Schedule").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let key = snapshot.key
                self.scheduleIds.append(key)
                
                if snapshot.hasChild("Schedule/\(key)/Reservations/\(uid)") {
                    self.upcomingReservationMade == true
                    print("upcoming reservation made \(self.upcomingReservationMade)")
                }
                
                
                if let driverId = dictionary["driverID"] as? String{
                    driverID = driverId
                }
                if let departureDate = dictionary["date"] as? String {
                    shuttleDepartureDate = departureDate
                    
                }
                if let departureTime = dictionary["time"] as? String {
                    shuttleDepartureTime = departureTime
                }
                
                if let shuttleId = dictionary["shuttleID"] as? String {
                    shuttleID = shuttleId
                }
                
              
                
                let driver = self.driversList
                if let driverName = driver[Int(driverID)!-1]["driverFirstName"] as? String {
                    driverFirstName = driverName
                }
                
                let shuttle = self.shuttleList
                if let shuttleCapacity = shuttle[Int(shuttleID)!-1]["shuttleCapacity"] as? String {
                    self.shuttleCapacityNum = shuttleCapacity

                }
                if let shuttleLicencePlate = shuttle[Int(shuttleID)!-1]["shuttleLicencePlate"] as? String {
                    shuttleLicencePlateNum = shuttleLicencePlate
                }
                
                
                if let numSeatLeft = dictionary["numSeatsLeft"] as? String {
                    print("num seat left \(numSeatLeft)")
                    numSeatsLeft = "\(Int(numSeatLeft)! - self.numSeatReservation)"
                }
                
      
                self.schedule = Schedule(shuttleDepartureDate: shuttleDepartureDate, shuttleID:shuttleID, driverID: driverID, shuttleDepartureTime:shuttleDepartureTime, driverName : driverFirstName, shuttleCapacity: numSeatsLeft, shuttleLicencePlate: shuttleLicencePlateNum)
                
               
                self.scheduleList.append(self.schedule)
                
                DispatchQueue.main.async{
                    self.scheduleTableView.reloadData()
                }
                
            }
            print(snapshot)
            
        
        } , withCancel: nil)
      
        

        
    }
    
    func didTappedSwitch(cell: ScheduleCell) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let indexPath = self.scheduleTableView.indexPath(for: cell)
        let schedule = scheduleList[(indexPath?.row)!]

        if activeReservationExistsForStudentForSelectedSchedule(scheduleIndexPath: (indexPath?.row)!) == true {
            
            self.reservationAlreadyMadeForAnotherShuttle()
            
        } else {
        cell.reserveSwitch.isOn = true
        var reservationNumber = 0
        //var numSeatReservation = 0
            
        let ref = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
       
        print(self.scheduleIds[(indexPath?.row)!])
        
        // Get numSeatReservation when switch is on for a schedule cell
        FIRDatabase.database().reference().child("Schedule").child(scheduleIds[(indexPath?.row)!]).observe(.childAdded, with: { (snapshot) in

        if let dictionary = snapshot.value as? [String : AnyObject] {
                 if let numSeatReserved = dictionary["numSeatsReserved"] as? Int{
                    print("actual numSeatReserved \(numSeatReserved)")
                 self.numSeatReservation = numSeatReserved
    }
    }
        } , withCancel: nil)
    
            numSeatReservation += 1
    
            //scheduleList[(indexPath?.row)!].reserved  = cell.reserveSwitch.isOn
            if (cell.reserveSwitch.isOn){
               // scheduleList[(indexPath?.row)!].reserved = true
                
                var reservationInformation = [String: String]()
                
                let reservationReference = ref.child("Schedule").child(scheduleIds[(indexPath?.row)!]).child("Reservations").child("\(uid)")
                
                let timeStamp = self.getCurrentTimeStamp()
                let reserved = "Reserved"
                schedule.reserved = true
                
                let values = ["studentId": uid, "reservationTimeStamp": timeStamp , "reservationStatus":
                    reserved]
                reservationReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print ("Error saving reservation in database: \(error?.localizedDescription)")
                        return
                    } else{
                        print ("Successefully saved reservation \(values)")
                    }

                reservationInformation["studentId"] = uid
                reservationInformation["reservationTimeStamp"] = timeStamp
                reservationInformation["reservationStatus"] = reserved
                    
                self.reservationList.append(reservationInformation as [String : AnyObject])
                print("reservation List \(self.reservationList)")
                 //schedule.reservations[reservationNumber].reservationStatus = "Reserved"
                
                schedule.currentSeatAvalaible = "\(Int(self.scheduleList[(indexPath?.row)!].shuttleCapacity)! - self.numSeatReservation)"
                
                let reservationUpdate = ref.child("Schedule").child(self.scheduleIds[(indexPath?.row)!])
                    let valueSeat = ["numSeatsReserved": self.numSeatReservation, "numSeatsLeft": schedule.currentSeatAvalaible] as [String: Any]
                reservationUpdate.updateChildValues(valueSeat, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print ("Error saving schedule update in database: \(error?.localizedDescription)")
                        return
                    } else{
                        print ("Successefully updated schedule \(valueSeat)")
                    }
                })
                
                cell.updateReservationStatusCell(schedule)
                cell.updatedSchedule(schedule)
            
              self.activeReservationExistsForStudentForSelectedSchedule(scheduleIndexPath: (indexPath?.row)!) == true
              reservationNumber += 1

                })
        }
        }
    }
    
    
    func getCurrentTimeStamp() -> String {
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        formatter.string(from: currentDateTime)
        print("timestamp \(currentDateTime)")
        return "\(currentDateTime)"
    }
    
    func reservationAlreadyMadeForAnotherShuttle(){
        let alertController = UIAlertController(title: "Sorry, You can't do that", message: "You already made a reservation for another shuttle departure time", preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)

    }
    
    func activeReservationExistsForStudentForSelectedSchedule(scheduleIndexPath indexPath: Int) -> Bool {
        var reservationExists = false
        FIRDatabase.database().reference().child("Schedule").child(scheduleIds[indexPath]).child("Reservations").child("\(uid)").observe(.value, with: { (snapshot) in
            print(snapshot.value)
            if snapshot.exists() {
                print("Exists")
                reservationExists = true
            }
        }, withCancel: nil)
    

        return reservationExists
    }
    
//    func update(numResa : Int) -> Int{
//        return numResa += 1
//    }
//
//    func cancelReservation(scheduleIndexPath indexPath: Int){
//        //FIRDatabase.database().reference().child("Schedule").child(scheduleIds[(indexPath?.row)!])
//        //            print(snapshot.hasChild("Schedule/\(self.scheduleIds[(indexPath?.row)!])/Reservations/\(uid)"))
//            schedule.reserved == false
//            numSeatReservation -= 1
//            schedule.currentSeatAvalaible = "\(Int(scheduleList[(indexPath?.row)!].shuttleCapacity)! + numSeatReservation)"
//            scheduleList[(indexPath?.row)!].reserved = false
//            self.reservation.reservationStatus = "Cancelled"
//            cell.updateReservationStatusCell(schedule)
//            let reservationUpdate = ref.child("Schedule").child(scheduleIds[(indexPath?.row)!])
//            let valueSeat = ["numSeatsReserved": numSeatReservation, "numSeatsLeft": schedule.currentSeatAvalaible] as [String : Any]
//            reservationUpdate.updateChildValues(valueSeat, withCompletionBlock: { (error, ref) in
//                if error != nil {
//                    print ("Error saving number seats in database: \(error?.localizedDescription)")
//                    return
//                } else{
//                    print ("Successefully canceled reservation \(valueSeat)")
//                }
//            })
//            cell.updatedSchedule(schedule)
//            
//            
//        }
    }
    
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

