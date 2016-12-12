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
    var allReservations = [Reservation]()
    
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
    
    var reservations: NSDictionary = [:]
    
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
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell") as? ScheduleCell
        if cell == nil {
            cell = ScheduleCell.init(style: .default, reuseIdentifier: "scheduleCell")
            
           
            
        }
        var schedule : Schedule!
        schedule = scheduleList[indexPath.row]
        
        cell?.delegate = self
        cell?.updateScheduleCell(schedule)
        
        cell?.shuttleCapacity.text = schedule.currentSeatAvalaible
        cell?.reserveSwitch.isOn = schedule.reserved
        if schedule.reserved == true {
             cell?.reservationStatus.text = "Reserved"
        }
        
        return cell!
    
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
                
               // print("GET DRIVER INFO \(self.driversList)")

                
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
            let dictionary = snapshot.value as! [String : AnyObject]
            let key = snapshot.key
            self.scheduleIds.append(key)
            
            if snapshot.hasChild("Schedule/\(key)/Reservations/\(uid)") {
                
                self.upcomingReservationMade == true
                // print("upcoming reservation made \(self.upcomingReservationMade)")
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
                // print("num seat left \(numSeatLeft)")
                numSeatsLeft = "\(Int(numSeatLeft)! - self.numSeatReservation)"
                
                
            }
            
            
            if dictionary["Reservations"] != nil {
                
                self.reservations = dictionary["Reservations"]! as! NSDictionary
                
                for (key, _) in self.reservations {
                    
                    let reservation:NSObject = self.reservations[key] as! NSObject
                    
                    let reservationsTimeStamp:String! = reservation.value(forKey: "reservationTimeStamp") as? String
                    let reservationsStatus:String! = reservation.value(forKey: "reservationStatus") as? String
                    let studentId:String! = reservation.value(forKey: "studentId") as? String
                    let scheduleId:String! = reservation.value(forKey: "scheduleID") as? String
                    
                    let reserv = Reservation(scheduleId: scheduleId, reservationTimeStamp: reservationsTimeStamp, reservationStatus: reservationsStatus, studentUniqueId: studentId)
                    
                    self.allReservations.append(reserv)
                    
                }
            }
            
            
            
            
            self.schedule = Schedule(id: key, shuttleDepartureDate: shuttleDepartureDate, shuttleID:shuttleID, driverID: driverID, shuttleDepartureTime:shuttleDepartureTime, driverName : driverFirstName, shuttleCapacity: numSeatsLeft, shuttleLicencePlate: shuttleLicencePlateNum)
            
            self.schedule.currentSeatAvalaible = numSeatsLeft
            self.schedule.reservations = self.allReservations
            for reserv in self.allReservations {
                
                if (reserv.studentUniqueId == uid) {
                    if (reserv.scheduleId == self.schedule.id) {
                        
                        self.schedule.reserved = true
                        break
                    }
                }
            }
            
            
            
            self.scheduleList.append(self.schedule)
            
            
            
            DispatchQueue.main.async{
                self.scheduleTableView.reloadData()
            }
            //print(snapshot)
            
        
        } , withCancel: nil)
      
        

        
    }
    
    func didTappedSwitch(cell: ScheduleCell) {
        
        let mainRef = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let indexPath = self.scheduleTableView.indexPath(for: cell)
        let schedule = scheduleList[(indexPath?.row)!]
        
        let reservationReference = mainRef.child("Schedule").child(scheduleIds[(indexPath?.row)!]).child("Reservations").child("\(uid)")
        
        let studentReference = mainRef.child("Students").child(uid)
        
        if cell.reserveSwitch.isOn {
            
            studentReference.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                
                let userInfo = snapshot.value as? [String:AnyObject]
                let hasReservation = userInfo?["hasReservation"] as? String
                if hasReservation == "YES" {
                    
                    self.reservationAlreadyMadeForAnotherShuttle()
                    DispatchQueue.main.async {
                        cell.reserveSwitch.isOn = false
                        
                    }
                    return
                } else {
                    let timeStamp = self.getCurrentTimeStamp()
                    let reservationDictionary = ["studentId":uid, "reservationTimeStamp": timeStamp, "reservationStatus":"Reserved", "scheduleID":schedule.id]
                    
                    reservationReference.updateChildValues(reservationDictionary, withCompletionBlock: { (error, ref) in
                        
                        if error != nil {
                            print("ERROR: \(error?.localizedDescription)")
                            return
                        } else {
                            
                            let hasReservation = ["hasReservation":"YES"]
                            
                            studentReference.updateChildValues(hasReservation, withCompletionBlock: { (error, ref) in
                                if error != nil {
                                    print("ERROR: \(error?.localizedDescription)")
                                    return
                                } else {
                                    mainRef.child("Schedule").child(self.scheduleIds[(indexPath?.row)!]).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                                        
                                        if let scheduleInfo = snapshot.value as? [String : AnyObject] {
                                            
                                            let numSeatLeft = scheduleInfo["numSeatsLeft"] as! String
                                            let numSeatsReserved = scheduleInfo["numSeatsReserved"] as! String
                                            
                                            var numSeatLeftINT: Int = Int(numSeatLeft)!
                                            var numSeatsReservedINT: Int = Int(numSeatsReserved)!
                                            
                                            numSeatLeftINT = numSeatLeftINT - 1
                                            numSeatsReservedINT = numSeatsReservedINT + 1
                                            
                                            if numSeatsReservedINT < 0 || numSeatLeftINT < 0 {
                                                return
                                            }
                                            
                                            schedule.currentSeatAvalaible = "\(numSeatLeftINT)"
                                            schedule.reserved = true
                                            
                                            let reservationUpdate = mainRef.child("Schedule").child(self.scheduleIds[(indexPath?.row)!])
                                            
                                            let seatValues = ["numSeatsReserved": "\(numSeatsReservedINT)", "numSeatsLeft" : "\(numSeatLeftINT)"] as [String : Any]
                                            
                                            reservationUpdate.updateChildValues(seatValues, withCompletionBlock: { (error, ref) in
                                                
                                                if error != nil {
                                                    print("ERROR: \(error?.localizedDescription)")
                                                } else {
                                                    
                                                    DispatchQueue.main.async {
                                                        cell.reserveSwitch.isOn = true
                                                        cell.updateReservationStatusCell(schedule)
                                                        cell.updatedSchedule(schedule)
                                                        
                                                    }
                                                    
                                                    
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
            })
            
            
            
        } else {
            let timeStamp = self.getCurrentTimeStamp()
            let reservationDictionary = ["studentId":uid, "reservationTimeStamp": timeStamp, "reservationStatus":"Cancelled", "scheduleID":schedule.id]
            
             reservationReference.updateChildValues(reservationDictionary, withCompletionBlock: { (error, ref) in
            //reservationReference.removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("ERROR: \(error?.localizedDescription)")
                    return
                } else {
                    
                    let hasReservation = ["hasReservation":"NO"]
                    
                    studentReference.updateChildValues(hasReservation, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("ERROR: \(error?.localizedDescription)")
                            return
                        } else {
                            mainRef.child("Schedule").child(self.scheduleIds[(indexPath?.row)!]).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                                
                                if let scheduleInfo = snapshot.value as? [String : AnyObject] {
                                    
                                    let numSeatLeft = scheduleInfo["numSeatsLeft"] as! String
                                    let numSeatsReserved = scheduleInfo["numSeatsReserved"] as! String
                                    
                                    var numSeatLeftINT: Int = Int(numSeatLeft)!
                                    var numSeatsReservedINT: Int = Int(numSeatsReserved)!
                                    
                                    numSeatLeftINT = numSeatLeftINT + 1
                                    numSeatsReservedINT = numSeatsReservedINT - 1
                                    
                                    if numSeatsReservedINT < 0 || numSeatLeftINT < 0 {
                                        return
                                    }
                                    
                                    schedule.currentSeatAvalaible = "\(numSeatLeftINT)"
                                    schedule.reserved = false
                                    
                                    let reservationUpdate = mainRef.child("Schedule").child(self.scheduleIds[(indexPath?.row)!])
                                    
                                    let seatValues = ["numSeatsReserved": "\(numSeatsReservedINT)", "numSeatsLeft" : "\(numSeatLeftINT)"] as [String : Any]
                                    
                                    reservationUpdate.updateChildValues(seatValues, withCompletionBlock: { (error, ref) in
                                        
                                        if error != nil {
                                            print("ERROR: \(error?.localizedDescription)")
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                cell.reserveSwitch.isOn = false
                                                cell.updateReservationStatusCell(schedule)
                                                cell.updatedSchedule(schedule)
                                            }
                                            
                                            
                                        }
                                    })
                                }
                            })
                        }
                        
                    })
                    
                }
            })
        }

    }
    
    
    func getCurrentTimeStamp() -> String {
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        formatter.string(from: currentDateTime)
        //print("timestamp \(currentDateTime)")
        return "\(currentDateTime)"
    }
    
    func reservationAlreadyMadeForAnotherShuttle(){
        let alertController = UIAlertController(title: "Sorry, You can't do that", message: "You already made a reservation for another shuttle departure time", preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)

    }

    }
    
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

