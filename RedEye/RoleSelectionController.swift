//
//  RoleSelectionController.swift
//  RedEye
//
//  Created by Marie Fonkou on 12/12/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class RoleSelectionController: UIViewController {

    var roleValue: String!
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBAction func roleValueChanged(_ sender: UISegmentedControl) {
        roleValue = roleSegmentedControl.titleForSegment(at: sender.selectedSegmentIndex)
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if roleValue == "Driver"{
            self.performSegue(withIdentifier: "loginDriver", sender: sender)
        } else{
             self.performSegue(withIdentifier: "loginStudent", sender: sender)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let selectedSegmentIndex = roleSegmentedControl.selectedSegmentIndex
        
        roleValue = roleSegmentedControl.titleForSegment(at: selectedSegmentIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
