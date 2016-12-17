//
//  ScheduleController.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/18/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import Alamofire

// 1. List all shuttle departure time from 7 PM to 6 AM
// 2. The 7 PM shuttle disapears when the driver left 

// create a child under each schedule id - increment the number of seat reserved - call constructor for schedule to update cell

class ScheduleController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleTableViewCellDelegate, GMSAutocompleteViewControllerDelegate {

    var scheduleList = [Schedule]()
    var allReservations = [Reservation]()
    var allReservationsId = [String]()
   
    var scheduleCell = [ScheduleCell]()
    var driversList = [Dictionary<String,AnyObject>]()
    var shuttleList = [Dictionary<String,AnyObject>]()
    var scheduleIds = [String]()
    var numSeatReservation = 0
    var shuttleCapacityNum: String = ""
    var studentAddress : String!
    var schedule = Schedule()
    var reservation = Reservation()
    let uid = FIRAuth.auth()?.currentUser?.uid
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var studentAddressLongAndLat = StudentAddress()
    
    var reservations: NSDictionary = [:]
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var scheduleTableView: UITableView!
    
    func updateTableView(){
        
         self.scheduleList.removeAll()
        fetchDriversInformation()
        fetchShuttleInformation()
        fetchShuttleSchedule()
        
        self.refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.refreshControl.addTarget(self, action: #selector(ScheduleController.updateTableView), for: .valueChanged)
        
        
        if #available(iOS 10.0, *) {
            
            self.scheduleTableView.refreshControl = refreshControl
            self.scheduleTableView.layoutIfNeeded()
            
        } else {
            self.scheduleTableView.addSubview(refreshControl)
        }
        
        
        self.title = "schedule"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        
        activityIndicator.center = self.view.center
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        self.scheduleTableView.isHidden=true
        activityIndicator.startAnimating()
        
        fetchDriversInformation()
        fetchShuttleInformation()
        fetchShuttleSchedule()
        
        
        self.getCurrentUserLoggedAddress { (userAddress) in
            
            self.studentAddress = userAddress
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        //cell?.addressLabel.text = getCurrentlyLoggedInStudentAddress(){(studentAddress)}
        self.activityIndicator.stopAnimating()
        self.scheduleTableView.isHidden=false
        

        
        cell?.shuttleCapacity.text = schedule.currentSeatAvalaible
        cell?.reserveSwitch.isOn = schedule.reserved
        cell?.viewStudentsBtn.isHidden = !schedule.reserved
        cell?.yourDestinationLabel.isHidden = !schedule.reserved
        cell?.addressLabel.isHidden = !schedule.reserved
        cell?.modifyAddressLabel.isHidden = !schedule.reserved
        if schedule.reserved == true {
             cell?.reservationStatus.text = "Reserved"
            cell?.addressLabel.text = self.studentAddress
            
        } else{
            cell?.reservationStatus.text = ""
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
                let driverProfilePicture = dictionary["profilePictureUrl"] as? String
                
                driverInformation["driverFirstName"] = driverFirstName
                 driverInformation["driverLastName"] = driverLastName
                 driverInformation["driverId"] = driverId
                 driverInformation["driverEmailAddress"] = driverEmailAddress
                driverInformation["profilePictureUrl"] = driverProfilePicture
                self.driversList.append(driverInformation as [String : AnyObject])
                
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
        var driverLast : String = ""
        var driverProfilePicture : String = ""
        var shuttleLicencePlateNum: String = ""
        var numSeatsLeft: String = ""
        var scheduleActive: String = ""
        
        FIRDatabase.database().reference().child("Schedule").observe(.childAdded, with: { (snapshot) in
            let dictionary = snapshot.value as! [String : AnyObject]
            let key = snapshot.key
          
            
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
            
            if let scheduleStatus = dictionary["scheduleActive"] as? String {
                scheduleActive = scheduleStatus
            }
            
            
            
            let driver = self.driversList
            if let driverName = driver[Int(driverID)!-1]["driverFirstName"] as? String {
                driverFirstName = driverName
            }
            if let driverLastName = driver[Int(driverID)!-1]["driverLastName"] as? String {
                driverLast = driverLastName
            }
            if let driverPicture = driver[Int(driverID)!-1]["profilePictureUrl"] as? String {
                driverProfilePicture = driverPicture
            }
            
            let shuttle = self.shuttleList
            if let shuttleCapacity = shuttle[Int(shuttleID)!-1]["shuttleCapacity"] as? String {
                self.shuttleCapacityNum = shuttleCapacity
                
            }
            if let shuttleLicencePlate = shuttle[Int(shuttleID)!-1]["shuttleLicencePlate"] as? String {
                shuttleLicencePlateNum = shuttleLicencePlate
            }
            
            
            if let numSeatLeft = dictionary["numSeatsLeft"] as? String {
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
                    
                     self.allReservationsId.append(studentId)
                    
                    let reserv = Reservation(scheduleId: scheduleId, reservationTimeStamp: reservationsTimeStamp, reservationStatus: reservationsStatus, studentUniqueId: studentId)
                    
                    self.allReservations.append(reserv)
                   
                }
            }
     
            self.schedule = Schedule(id: key, shuttleDepartureDate: shuttleDepartureDate, shuttleID:shuttleID, driverID: driverID, shuttleDepartureTime:shuttleDepartureTime, driverName : driverFirstName, driverLastName: driverLast, driverProfilePicture: driverProfilePicture , shuttleCapacity: numSeatsLeft, shuttleLicencePlate: shuttleLicencePlateNum, scheduleActive: scheduleActive)
            
            self.schedule.currentSeatAvalaible = numSeatsLeft
            self.schedule.reservations = self.allReservations
            self.schedule.reservationID = self.allReservationsId
            
            for reserv in self.allReservations {
                
                if (reserv.studentUniqueId == uid) {
                    if (reserv.scheduleId == self.schedule.id) {
                        
                        self.schedule.reserved = true
                        break
                    }
                }
            }
            
            if scheduleActive == "YES" {
                self.schedule.scheduleActive = "YES"
                self.scheduleList.append(self.schedule)
                self.scheduleIds.append(key)
                DispatchQueue.main.async{
                    self.scheduleTableView.reloadData()
                }
            }
            
            
            

            //print(snapshot)
            
        
        } , withCancel: nil)
      
        

        
    }
    
    func getCurrentUserLoggedAddress(completionHandler: @escaping (_ studentAddress: String) -> () ) {
        
        FIRDatabase.database().reference().child("Address").child(uid!).observe(.value, with: {  (snapshot) in
            
            if let studentAddressInfo = snapshot.value as? [String : AnyObject] {
                self.studentAddress = studentAddressInfo["studentAddress"] as? String
                completionHandler(self.studentAddress)
                
            }
            
        }, withCancel: nil)
    }

    
    func didTappedModifyAddress(cell: ScheduleCell) {
        let autoComplete = GMSAutocompleteViewController()
        autoComplete.delegate = self
        
        autoComplete.searchDisplayController?.searchBar.setSerchTextcolor(color: UIColor.red)
        
        
        self.present(autoComplete, animated: true, completion: nil)
    }
    
    func didTappedViewStudentButton(cell: ScheduleCell) {
        
        let indexPath = self.scheduleTableView.indexPath(for: cell)
        let schedule = scheduleList[(indexPath?.row)!]
        print("schedule tapped view students \(schedule.id)")
        
        
        let studentsVC: StudentsListController = self.storyboard?.instantiateViewController(withIdentifier: "studentsVC") as! StudentsListController
        
        studentsVC.scheduleId = schedule.id
        
        self.navigationController?.pushViewController(studentsVC, animated: true)
    }
    
    
    
    
    func didTappedSwitch(cell: ScheduleCell) {
        
        //DispatchQueue.global(qos: .default).async {
          // self.updateTableView()
            
           // DispatchQueue.main.async {
        
        
        if cell.reserveSwitch.isOn {
            
            self.confirmYourAddress(scheduleCell: cell)
            
        } else {
            self.updateScheduleInfo(cell: cell)
        }
        
        
    }
        
    //}
    
    
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
    
    func shuttleIsFull(){
        let alertController = UIAlertController(title: "You came too late", message: "This shuttle seems to be full.", preferredStyle: UIAlertControllerStyle.alert)
        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func addressNotAvailable(){
        let controller = UIAlertController(title: "Where are you going?", message: "We need you to enter your destination", preferredStyle: .alert)
        
        
        let changeAddress = UIAlertAction(title: "Set address", style: .default) { (action) in
            let autoComplete = GMSAutocompleteViewController()
            autoComplete.delegate = self
            
            autoComplete.searchDisplayController?.searchBar.setSerchTextcolor(color: UIColor.red)
            
            
            self.present(autoComplete, animated: true, completion: nil)
            
        }
        
        controller.addAction(changeAddress)
        
        present(controller, animated: true, completion: nil)

    }
    
    
    func confirmYourAddress(scheduleCell: ScheduleCell){
        
        let controller = UIAlertController(title: "Confirm your destination", message: "Are you going to \(self.studentAddress!) ?", preferredStyle: .alert)
        
        let confirmAddress = UIAlertAction(title: "Yes", style: .cancel) { (action) in
            
            self.updateScheduleInfo(cell: scheduleCell)
            return
        }
        
        controller.addAction(confirmAddress)
        
        
        let changeAddress = UIAlertAction(title: "No, modify address", style: .default) { (action) in
            let autoComplete = GMSAutocompleteViewController()
            autoComplete.delegate = self
            
            autoComplete.searchDisplayController?.searchBar.setSerchTextcolor(color: UIColor.red)
            
            
            self.present(autoComplete, animated: true, completion: nil)
            self.updateScheduleInfo(cell: scheduleCell)
            return

        }
        
        controller.addAction(changeAddress)
        
        present(controller, animated: true, completion: nil)
        
        
    }
    
    func updateScheduleInfo(cell: ScheduleCell) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let indexPath = self.scheduleTableView.indexPath(for: cell)
        let schedule = self.scheduleList[(indexPath?.row)!]
        print(schedule.id)
        
        var snapshotValues = [String]()
        
        FIRDatabase.database().reference().child("Address").observe(.childAdded, with: { (snapshot) in
            snapshotValues.append(snapshot.key)
        }, withCancel: nil)
        
        
        FIRDatabase.database().reference().child("Address").child(uid).observe(.value, with: { (snapshot) in
            
            if let studentAddressInfo = snapshot.value as? [String : AnyObject] {
                self.studentAddress = studentAddressInfo["studentAddress"] as? String
            }
            
        }, withCancel: nil)
        
        
        if schedule.scheduleActive != "YES" {
            
            cell.reserveSwitch.isOn = false
            return;
            
        }
        
        let reservationReference = Constants.URL.ref.child("Schedule").child(self.scheduleIds[(indexPath?.row)!]).child("Reservations").child("\(uid)")
        
        let studentReference = Constants.URL.ref.child("Students").child(uid)
        
        if cell.reserveSwitch.isOn {
            
            
            studentReference.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                
                
                let userInfo = snapshot.value as? [String:AnyObject]
                let hasReservation = userInfo?["hasReservation"] as? String
                var numberSeatLeft : String = ""
                //let firstQueue = DispatchQueue(label: "firstQueue", qos: DispatchQoS.userInitiated)
                // firstQueue.async {
                let scheduleReference = Constants.URL.ref.child("Schedule").child(self.scheduleIds[(indexPath?.row)!])
                
                scheduleReference.observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
                    
                    let scheduleInfo = snapshot.value as? [String: AnyObject]
                    numberSeatLeft = (scheduleInfo?["numSeatsLeft"] as? String)!
                    print("number seat \(numberSeatLeft) ")
                    if numberSeatLeft == "0" && hasReservation == "NO" {
                        self.shuttleIsFull()
                        DispatchQueue.main.async {
                            cell.reserveSwitch.isOn = false
                            return
                        }
                    } else {
                        if hasReservation == "YES" {
                            
                            self.reservationAlreadyMadeForAnotherShuttle()
                            DispatchQueue.main.async {
                                cell.reserveSwitch.isOn = false
                                return
                            }
                            
                        } else {
                            //var snapshotValues = [String]()
                            
                            //FIRDatabase.database().reference().child("Address").observe(.childAdded, with: { (snapshot) in
                            //    snapshotValues.append(snapshot.key)
                            //     print("snapshot address \(snapshotValues)")
                            // }, withCancel: nil)
                            
                            if snapshotValues.contains(uid) == false{
                                self.addressNotAvailable()
                                DispatchQueue.main.async {
                                    cell.reserveSwitch.isOn = false
                                    return
                                }
                                
                            } else{
                                
                                
                                DispatchQueue.main.async {
                                    cell.reserveSwitch.isOn = false
                                    return
                                }
                                
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
                                                Constants.URL.ref.child("Schedule").child(self.scheduleIds[(indexPath?.row)!]).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                                                    
                                                    if let scheduleInfo = snapshot.value as? [String : AnyObject] {
                                                        
                                                        let numSeatLeft = scheduleInfo["numSeatsLeft"] as! String
                                                        let numSeatsReserved = scheduleInfo["numSeatsReserved"] as! String
                                                        
                                                        var numSeatLeftINT: Int = Int(numSeatLeft)!
                                                        var numSeatsReservedINT: Int = Int(numSeatsReserved)!
                                                        
                                                        numSeatLeftINT = numSeatLeftINT - 1
                                                        numSeatsReservedINT = numSeatsReservedINT + 1
                                                        
                                                        schedule.currentSeatAvalaible = "\(numSeatLeftINT)"
                                                        schedule.reserved = true
                                                        
                                                        let reservationUpdate = Constants.URL.ref.child("Schedule").child(self.scheduleIds[(indexPath?.row)!])
                                                        
                                                        let seatValues = ["numSeatsReserved": "\(numSeatsReservedINT)", "numSeatsLeft" : "\(numSeatLeftINT)"] as [String : Any]
                                                        
                                                        reservationUpdate.updateChildValues(seatValues, withCompletionBlock: { (error, ref) in
                                                            
                                                            if error != nil {
                                                                print("ERROR: \(error?.localizedDescription)")
                                                            } else {
                                                                
                                                                DispatchQueue.main.async {
                                                                    cell.viewStudentsBtn.isHidden = false
                                                                    cell.yourDestinationLabel.isHidden = false
                                                                    cell.addressLabel.isHidden = false
                                                                    cell.modifyAddressLabel.isHidden=false
                                                                    cell.reserveSwitch.isOn = true
                                                                    cell.updateReservationStatusCell(schedule)
                                                                     cell.addressLabel.text = self.studentAddress
                                                                    
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
                        }}
                    
                } , withCancel: nil)
                
            })
            
            
            
        } else {
            //let timeStamp = self.getCurrentTimeStamp()
            //let reservationDictionary = ["studentId":uid, "reservationTimeStamp": timeStamp, "reservationStatus":"Cancelled", "scheduleID":schedule.id]
            
            //reservationReference.updateChildValues(reservationDictionary, withCompletionBlock: { (error, ref) in
            reservationReference.removeValue(completionBlock: { (error, ref) in
                
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
                            Constants.URL.ref.child("Schedule").child(self.scheduleIds[(indexPath?.row)!]).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                                
                                if let scheduleInfo = snapshot.value as? [String : AnyObject] {
                                    
                                    let numSeatLeft = scheduleInfo["numSeatsLeft"] as! String
                                    let numSeatsReserved = scheduleInfo["numSeatsReserved"] as! String
                                    
                                    var numSeatLeftINT: Int = Int(numSeatLeft)!
                                    var numSeatsReservedINT: Int = Int(numSeatsReserved)!
                                    
                                    numSeatLeftINT = numSeatLeftINT + 1
                                    numSeatsReservedINT = numSeatsReservedINT - 1
                                    
                                    schedule.currentSeatAvalaible = "\(numSeatLeftINT)"
                                    schedule.reserved = false
                                    
                                    let reservationUpdate = Constants.URL.ref.child("Schedule").child(self.scheduleIds[(indexPath?.row)!])
                                    
                                    let seatValues = ["numSeatsReserved": "\(numSeatsReservedINT)", "numSeatsLeft" : "\(numSeatLeftINT)"] as [String : Any]
                                    
                                    reservationUpdate.updateChildValues(seatValues, withCompletionBlock: { (error, ref) in
                                        
                                        if error != nil {
                                            print("ERROR: \(error?.localizedDescription)")
                                        } else {
                                            
                                            DispatchQueue.main.async {
                                                cell.viewStudentsBtn.isHidden = true
                                                cell.yourDestinationLabel.isHidden = true
                                                cell.addressLabel.isHidden = true
                                                cell.modifyAddressLabel.isHidden = true
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
        //}
    }
    func confirmYourAddressCancelled(){
        
        let controller = UIAlertController(title: "Confirm your destination", message: "We could not save your new address. Are you still going to \(self.studentAddress!) ?", preferredStyle: .alert)
        
        let confirmAddress = UIAlertAction(title: "Yes", style: .cancel) { (action) in
            return
        }
        
        controller.addAction(confirmAddress)
        
        
        let changeAddress = UIAlertAction(title: "No, modify address", style: .default) { (action) in
            let autoComplete = GMSAutocompleteViewController()
            autoComplete.delegate = self
            
            autoComplete.searchDisplayController?.searchBar.setSerchTextcolor(color: UIColor.red)
            
            
            self.present(autoComplete, animated: true, completion: nil)
            
        }
        
        controller.addAction(changeAddress)
        
        present(controller, animated: true, completion: nil)
        
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print ("Fail to get auto complete address \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: {
        
            self.confirmYourAddressCancelled()
        })
    }
    
  
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        

        
            guard let uid = FIRAuth.auth()?.currentUser?.uid else{
                return
            }
            let studentReference = Constants.URL.ref.child("Address").child(uid)
            let values = ["studentAddress": place.formattedAddress!, "studentPlaceID": place.placeID, "studentID": uid]
            studentReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print ("Error saving address in database: \(error?.localizedDescription)")
                    return
                } else{
                    print ("Successefully saved address \(place.formattedAddress!)")
                }
            })
        
        getAddressCordinates{}
        //saveLatAndLong()
        
        
     
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func confirmAutoCompleteAddress(){
        let controller = UIAlertController(title: "Just to make sure", message: "Are you going to\(self.studentAddress!) ?", preferredStyle: .alert)
        
        let confirmAddress = UIAlertAction(title: "Yes", style: .cancel) { (action) in
            return
        }
        
        controller.addAction(confirmAddress)
        
        
        let changeAddress = UIAlertAction(title: "No, modify address", style: .default) { (action) in
            
            let autoComplete = GMSAutocompleteViewController()
            autoComplete.delegate = self
            
            autoComplete.searchDisplayController?.searchBar.setSerchTextcolor(color: UIColor.red)
            
            
            autoComplete.present(autoComplete, animated: true, completion: nil)

        
    }
        
        controller.addAction(changeAddress)
        
        present(controller, animated: true, completion: nil)
 

}
    
    
    func getAddressCordinates(completed: @escaping DownloadComplete){
        Alamofire.request("\(Constants.URL.googleGeocodingAPI)\(self.studentAddress.replacingOccurrences(of: " ", with: ""))\(Constants.Google.GEOLOCATION_API_KEY )").responseJSON {
            response in
            let result = response.result
            if let dictionary = result.value as? Dictionary <String, AnyObject>{
                if let results = dictionary["results"] as? [Dictionary <String, AnyObject>]{
                    var latitudeRequest: Double = 0.0
                    var longitudeRequest: Double = 0.0
                    if let geometry = results[0]["geometry"] as?  Dictionary<String, AnyObject>{
                        if let location = geometry["location"] as? Dictionary<String, AnyObject> {
                            if let latitude = location["lat"] as? Double {
                                latitudeRequest = latitude
                                
                            }
                            if let longitude = location["lng"] as? Double{
                                longitudeRequest = longitude
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.studentAddressLongAndLat = StudentAddress(latitude:latitudeRequest, longitude:longitudeRequest)
                        print("ADDRESS CONSTRUCTOR \(self.studentAddressLongAndLat._latitude) \(self.studentAddressLongAndLat._longitude)")
                        self.saveLatAndLong()
                    })
                    
                    
                }
                
            }
            
            
        }
        completed()
        
        
    }
    
    func saveLatAndLong(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let ref = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
        let studentReference = ref.child("Address").child(uid)
        let values = ["studentAddressLatitude" : self.studentAddressLongAndLat._latitude , "studentAddressLongitude" : self.studentAddressLongAndLat._longitude]
        print("save latitude \(self.studentAddressLongAndLat._latitude) and save longitude \(self.studentAddressLongAndLat._longitude)")
        studentReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print ("Error saving lat and long in database: \(error?.localizedDescription)")
                return
            } else{
                print ("Successefully saved lat and long \(self.studentAddressLongAndLat._latitude) \(self.studentAddressLongAndLat._longitude)")
            }
        })
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

