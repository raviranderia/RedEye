//
//  StudentsListController.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/18/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase

class StudentsListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var studentTableView: UITableView!
    
    @IBAction func viewItineraryBtnPressed(_ sender: Any) {
        
    }
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var students = [Student]()
    
    var student = Student()
    
    var scheduleId: String = ""
    
    var reservationIds = [String]()
    
    var currentStudentFirstName: String = ""
    
    var currentStudentLastName:  String = ""
    var studentFirstName: String = ""
    var studentLastName:  String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        studentTableView.delegate = self
        studentTableView.dataSource = self

        self.title = "students"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
 
        activityIndicator.center = self.view.center
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        self.studentTableView.isHidden=true
          activityIndicator.startAnimating()

        
        fetchStudents()
        saveScheduleId()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //fetchCurrentlyLoggedInStudentName()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveScheduleId(){
        let defaults = UserDefaults.standard
        defaults.set(self.scheduleId, forKey: "studentScheduleId")
    }
    
    func getReservationIds(_ allReservationIds: [String]) -> [String]{
        reservationIds = allReservationIds;
        print("reservations IDS \(reservationIds)")
        return reservationIds;
    }
    
//    func fetchCurrentlyLoggedInStudentName() {
//        
//        
//        
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
//            return
//        }
//        
//        FIRDatabase.database().reference().child("Students").child(uid).observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
//        
//            let dictionary = snapshot.value as! [String:AnyObject]
//            
//            if let firstName = dictionary["firstName"] as? String {
//                self.currentStudentFirstName = firstName
//                print(self.currentStudentFirstName)
//            }
//            
//            if let lastName = dictionary["lastName"] as? String {
//                self.currentStudentLastName = lastName
//                print(self.currentStudentLastName)
//            }
//            
//        })
//    }
    
    func fetchStudents(){
        
       
        var studentMajor: String = ""
        var studentProfilePicture: String = ""
        
        let reservationReference = Constants.URL.ref.child("Schedule").child(self.scheduleId).child("Reservations")
        
        
        
        reservationReference.observe(.childAdded, with: { (snapshot) in
            
            //let reservation = snapshot.value as? [String : AnyObject]
            
            
            let studentReference = Constants.URL.ref.child("Students").child(snapshot.key)
            studentReference.observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    
                    
                    if let firstName = dictionary["firstName"] as? String {
                        self.studentFirstName = firstName
                    }
                    
                    if let lastName = dictionary["lastName"] as? String {
                        self.studentLastName = lastName
                    }
                    
                    if let major = dictionary["studentMajor"] as? String {
                        studentMajor = major
                        
                    }
                    
                    if let profilePictureUrl = dictionary["profilePictureUrl"] as? String{
                        print ("profile picture with no profile picture \(profilePictureUrl)")
                        studentProfilePicture = profilePictureUrl
                    }
                    
                    self.student = Student(studentFirstName: self.studentFirstName, studentLastName: self.studentLastName, studentProfilePicture: studentProfilePicture , studentMajor: studentMajor)
                    
                    //                student.studentFirstName = dictionary["firstName"] as? String
                    //                student.studentLastName = dictionary["lastName"]  as? String
                    //                student.studentMajor = dictionary["studentMajor"]  as? String
                    //                student.studentProfilePicture = dictionary["profilePictureUrl"] as? String
                    self.students.append(self.student)
                    
                    DispatchQueue.main.async{
                        
                        self.studentTableView.reloadData()
                    }
                    
                }
                
            })
            
            
            
         
        } , withCancel: nil)
        
        
    }

    // MARK: - Table view data source

   func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as? StudentCell

        if cell == nil {
            cell = StudentCell.init(style: .default, reuseIdentifier: "studentCell")
            
        }
        var student : Student!
        student = students[indexPath.row]
        print("student list \(student.studentProfilePicture)")
       
        cell?.updateStudentCell(student)
        self.activityIndicator.stopAnimating()
        self.studentTableView.isHidden=false
        
//        if currentStudentFirstName == cell?.studentFirstName.text && currentStudentLastName == cell?.studentLastName.text {
//            cell?.youLabel.isHidden = false
//        } else{
//            cell?.youLabel.isHidden = true
//        }
        
        return cell!
    }

}
