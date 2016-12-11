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
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var students = [Student]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
               self.view.backgroundColor = UIColor.black
        studentTableView.delegate = self
        studentTableView.dataSource = self

        self.navigationController?.navigationBar.topItem?.title = "students"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
 
        activityIndicator.center = self.view.center
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        self.studentTableView.isHidden=true
          activityIndicator.startAnimating()
        

        
        fetchStudents()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchStudents(){
        FIRDatabase.database().reference().child("Students").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let student = Student()
                student.studentFirstName = dictionary["firstName"] as? String
                student.studentLastName = dictionary["lastName"]  as? String
                student.studentMajor = dictionary["studentMajor"]  as? String
                student.studentProfilePicture = dictionary["profilePictureUrl"] as? String
                self.students.append(student)
                
                DispatchQueue.main.async{
                
                    self.studentTableView.reloadData()
                }
                
            }
            print(snapshot)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath) as! StudentCell

        let student = students[indexPath.row]
        cell.studentFirstName?.text = student.studentFirstName
        cell.studentLastName?.text = student.studentLastName
        cell.studentMajor?.text = student.studentMajor
        
        if let profilePictureUrL = student.studentProfilePicture {
            
            cell.studentProfilePicture.loadImageWithCache(urlString: profilePictureUrL)
            self.activityIndicator.stopAnimating()
            self.studentTableView.isHidden=false
        }
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
