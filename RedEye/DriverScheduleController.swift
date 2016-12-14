//
//  DriverScheduleController.swift
//  RedEye
//
//  Created by Marie Fonkou on 12/13/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase

class DriverScheduleController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var driverScheduleTableView: UITableView!
    
    var driverSchedule = [Schedule]()
    var schedule = Schedule()
    var driverUid: String!
    var driverEmployementId: String!
    
    var alertController: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertController = UIAlertController(title: "Taking off", message:"Confirm you're about to depart", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        driverScheduleTableView.delegate = self
        driverScheduleTableView.dataSource = self
        
        self.navigationController?.navigationBar.topItem?.title = "schedule"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
        getDriverEmployementId()
        fetchDriverSchedule()
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "driverScheduleCell", for: indexPath) as? DriverScheduleCell
        
        if cell == nil {
            cell = DriverScheduleCell.init(style: .default, reuseIdentifier: "driverScheduleCell")
            
        }
        
        let schedule = driverSchedule[indexPath.row]

        cell?.updateDriverSchedule(schedule)
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
                }
            }
            
        } , withCancel: nil)
    }
    
    func fetchDriverSchedule(){
       
        var driverId = ""
        var shuttleDepartureDate = ""
        var shuttleDepartureTime = ""
        var numSeatAvailable = ""
        
        
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

                if let driverID = dictionary["driverID"] as? String{
                   driverId = driverID
                    print("driver id \(driverId)")
                }
                
                self.schedule = Schedule(id: key, shuttleDepartureDate: shuttleDepartureDate, shuttleDepartureTime:shuttleDepartureTime, numSeatLeft: numSeatAvailable)
                
                if driverId == self.driverEmployementId {
                    self.driverSchedule.append(self.schedule)
                    print("driver schedule \(self.driverSchedule)")
                    
                }
                
                DispatchQueue.main.async{
                    self.driverScheduleTableView.reloadData()
                }
                
            }
            
        }, withCancel: nil )
        
        
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
