//
//  DriverScheduleController.swift
//  RedEye
//
//  Created by Marie Fonkou on 12/13/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase

class DriverScheduleController: UIViewController , UITableViewDelegate, UITableViewDataSource, DriverScheduleTableViewCellDelegate{

    @IBOutlet weak var driverScheduleTableView: UITableView!
    
    var driverSchedule = [Schedule]()
    var schedule = Schedule()
    var driverUid: String!
    var scheduleIds = [String]()
    var driverEmployementId: String!
     var refreshControl = UIRefreshControl()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        

        self.title = "schedule"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
        
        getDriverEmployementId()
        
        self.refreshControl.addTarget(self, action: #selector(ScheduleController.updateTableView), for: .valueChanged)
        
        
        if #available(iOS 10.0, *) {
            
            self.driverScheduleTableView.refreshControl = refreshControl
            self.driverScheduleTableView.layoutIfNeeded()
            
        } else {
            self.driverScheduleTableView.addSubview(refreshControl)
        }

   
        
        
    }
    
    func updateTableView() -> Void {
        
        self.driverSchedule.removeAll()
        
         self.fetchDriverSchedule();
         self.refreshControl.endRefreshing()
 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return driverSchedule.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "driverScheduleCell") as? DriverScheduleCell
        
        if cell == nil {
            cell = DriverScheduleCell.init(style: .default, reuseIdentifier: "driverScheduleCell")
            
        }
        
        var schedule : Schedule!
        schedule = driverSchedule[indexPath.row]
        
        
        
        cell?.delegate = self

       cell?.updateDriverSchedule(schedule)
        

    
        cell?.aboutToLeaveBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        if (schedule.scheduleActive == "YES") {
            cell?.aboutToLeaveBtn.titleLabel?.text = "About to leave"
        } else{
            cell?.aboutToLeaveBtn.titleLabel?.text = "Cancel departure"
        }
        //cell?.aboutToLeaveBtn.titleLabel?.text =  (schedule.scheduleActive! == "YES") ? "About to leave" : "Cancel departure"
        print("\(cell?.aboutToLeaveBtn.titleLabel?.text)")

        cell?.viewStudentsBtn.isHidden = !(Int(schedule.numSeatReserved)!>0)
        cell?.aboutToLeaveBtn.tag = indexPath.row
        let idSelectedSchedule = cell?.aboutToLeaveBtn.tag
        
        let defaults = UserDefaults.standard
        defaults.set(schedule.id, forKey: "\(idSelectedSchedule!)")
        
      return cell!
    }
    
    

    func getDriverEmployementId(){
        
        let defaults = UserDefaults.standard
        let driverUid = defaults.string(forKey: "driverEmailAddress")
        print("driveruid \(driverUid)")
        
        FIRDatabase.database().reference().child("Drivers").child(driverUid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                if let driverId = dictionary["driverID"] as? String {
                    self.driverEmployementId = driverId
                    print("driver emplyement id \(self.driverEmployementId)")
                    self.fetchDriverSchedule();
                }
            }
            
        } , withCancel: nil)
    }
    
    func fetchDriverSchedule(){
       
        var driverId = ""
        var shuttleDepartureDate = ""
        var shuttleDepartureTime = ""
        var numSeatAvailable = ""
        var numberSeatReserved = ""
        var scheduleIsActive = ""
        
        FIRDatabase.database().reference().child("Schedule").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let key = snapshot.key
                
                if let departureDate = dictionary["date"] as? String {
                    shuttleDepartureDate = departureDate
                    
                }
                if let departureTime = dictionary["time"] as? String {
                    shuttleDepartureTime = departureTime
                }
                
                if let numSeatLeft = dictionary["numSeatsLeft"] as? String {
                    numSeatAvailable = numSeatLeft
                    
                }

                
                if let numSeatReserved = dictionary["numSeatsReserved"] as? String {
                    numberSeatReserved = numSeatReserved
                    
                }
                
                if let scheduleActive = dictionary["scheduleActive"] as? String {
                    scheduleIsActive = scheduleActive
                    print(scheduleIsActive)
                    
                }
                
                if let driverID = dictionary["driverID"] as? String{
                   driverId = driverID
                }
                
                self.schedule = Schedule(id: key, shuttleDepartureDate: shuttleDepartureDate, shuttleDepartureTime:shuttleDepartureTime, numSeatLeft: numSeatAvailable, numSeatReserved: numberSeatReserved, scheduleActive: scheduleIsActive)
                
                if driverId == self.driverEmployementId {
                    
                    if !self.scheduleIds.contains(key) {
                        self.scheduleIds.append(key)
                        self.driverSchedule.append(self.schedule)
                        DispatchQueue.main.async{
                            self.driverScheduleTableView.reloadData()
                        }
                    }
                   
                    
                }
                
                
                
                
            }
            
        }, withCancel: nil )
        
        
    }
    
    func didTappedViewStudentButton(cell: DriverScheduleCell) {
        
        let indexPath = self.driverScheduleTableView.indexPath(for: cell)
        let schedule = driverSchedule[(indexPath?.row)!]
        print("schedule tapped \(schedule.id)")
        
        
        let studentsVC: StudentsListController = self.storyboard?.instantiateViewController(withIdentifier: "studentsVC") as! StudentsListController
        
        studentsVC.scheduleId = schedule.id
        
        self.navigationController?.pushViewController(studentsVC, animated: true)
    }
    
    func didTappedAboutToLeaveButton(cell: DriverScheduleCell) {
        
        var alertController: UIAlertController!
        
        let indexPath = self.driverScheduleTableView.indexPath(for: cell)
        let schedule = driverSchedule[(indexPath?.row)!]
        
        if(cell.aboutToLeaveBtn.titleLabel?.text == "Cancel departure"){
            
            alertController = UIAlertController(title: "Not ready to leave", message:"If you confirm that you're not about to depart anymore, students will be able to reserve a seat.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let cancelDeparture = UIAlertAction(title: "Cancel departure", style: UIAlertActionStyle.default) { (action) in
                
                let scheduleReference = Constants.URL.ref.child("Schedule").child(schedule.id)
                let updateScheduleValues = ["scheduleActive": "YES"]
                scheduleReference.updateChildValues(updateScheduleValues, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print ("Error setting schedule as unactive in the database: \(error?.localizedDescription)")
                        return
                    } else{
                        let controller = UIAlertController(title: "Departure cancelled", message: " Students can now reserve for the shuttle leaving on \(schedule.shuttleDepartureDate!) at \(schedule.shuttleDepartureTime!).", preferredStyle: .alert)
                        let scheduleDeleted = UIAlertAction(title: "Okay", style: .default)
                        controller.addAction(scheduleDeleted)
                        self.present(controller, animated: true, completion: nil)
//                        DispatchQueue.main.async {
//                            self.updateTableView()
//                        }
                        
                    }
                })
                
                let reservationReference = Constants.URL.ref.child("Schedule").child(schedule.id).child("Reservations")
                reservationReference.observe(.childAdded, with: { (snapshot) in
                    
                    
                    let studentReference = Constants.URL.ref.child("Students").child(snapshot.key)
                    print(snapshot.key)
                    let updateReservationValuesForStudents = ["hasReservation": "YES"]
                    studentReference.updateChildValues(updateReservationValuesForStudents, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("Error occured while trying to update values for hasReservation for students")
                        } else{
                            print("Successfully updated values for hasReservation for students")
                        }
                    })
                    
                })
            }
            let confirmDeparture = UIAlertAction(title: "Confirm departure", style: UIAlertActionStyle.default) { (action) in
            return
            }
            
                
                alertController.addAction(cancelDeparture)
                alertController.addAction(confirmDeparture)
                
                self.present(alertController, animated: true, completion: nil)
            
        } else{
            alertController = UIAlertController(title: "Taking off", message:"If you confirm that you're about to depart, students won't be able to reserve a seat anymore.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let removeSchedule = UIAlertAction(title: "Yes, confirm departure", style: UIAlertActionStyle.default) { (action) in
                
                let scheduleReference = Constants.URL.ref.child("Schedule").child(schedule.id)
                let updateScheduleValues = ["scheduleActive": "NO"]
                scheduleReference.updateChildValues(updateScheduleValues, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print ("Error setting schedule as unactive in the database: \(error?.localizedDescription)")
                        return
                    } else{
                        let controller = UIAlertController(title: "Departure saved", message: " Shuttle for departure on \(schedule.shuttleDepartureDate!) at \(schedule.shuttleDepartureTime!) cannot be reserved by students anymore.", preferredStyle: .alert)
                        let scheduleDeleted = UIAlertAction(title: "Okay", style: .default)
                        controller.addAction(scheduleDeleted)
                        self.present(controller, animated: true, completion: nil)
//                         DispatchQueue.main.async {
//                   cell.aboutToLeaveBtn.titleLabel?.text = "Cancel departure"
////                        //self.updateTableView()
//                        }
                    }
                })
//                                DispatchQueue.main.async {
//                                    cell.aboutToLeaveBtn.titleLabel?.text = "Cancel departure"
//                                    //self.updateTableView()
//                                }
                
                let reservationReference = Constants.URL.ref.child("Schedule").child(schedule.id).child("Reservations")
                reservationReference.observe(.childAdded, with: { (snapshot) in
                    
                    
                    let studentReference = Constants.URL.ref.child("Students").child(snapshot.key)
                    print(snapshot.key)
                    let updateReservationValuesForStudents = ["hasReservation": "NO"]
                    studentReference.updateChildValues(updateReservationValuesForStudents, withCompletionBlock: { (error, ref) in
                        if error != nil {
                            print("Error occured while trying to update values for hasReservation for students")
                        } else{
                            print("Successfully updated values for hasReservation for students")
                        }
                    })
                    
                })
                
                DispatchQueue.main.async {
                    cell.aboutToLeaveBtn.titleLabel?.text = "Cancel departure"
                    //self.updateTableView()
                    return
                }
            }
            
            let cancelRemoveSchedule = UIAlertAction(title: "No, I'm not ready yet", style: UIAlertActionStyle.default) { (action) in
                return
            }
            
            alertController.addAction(removeSchedule)
            alertController.addAction(cancelRemoveSchedule)
            
            
            
            self.present(alertController, animated: true, completion: nil)
        }
    
      
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 147
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
