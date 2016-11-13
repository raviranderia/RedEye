//
//  SwitchLoginViewController.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/12/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit

class SwitchLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBOutlet weak var LoginView: UIView!
    
    @IBOutlet weak var SignUpView: UIView!
    
    
    @IBAction func switchViewSegment(_ sender: SegmentedControl) {
        print ("value segment \(sender.getSelectedSegment())")
        if sender.getSelectedSegment() == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.LoginView.alpha = 1
                self.SignUpView.alpha = 0
            })
        } else {
             UIView.animate(withDuration: 0.5, animations: {
            self.LoginView.alpha = 0
            self.SignUpView.alpha = 1
            })
        }
    }
    
//    @IBAction func switchViews(_ sender: UISegmentedControl) {
//
//        if sender.selectedSegmentIndex == 0 {
//            UIView.animate(withDuration: 0.5, animations: {
//                self.LoginView.alpha = 1
//                self.SignUpView.alpha = 0
//            })
//        } else {
//            UIView.animate(withDuration: 0.5, animations: {
//                self.LoginView.alpha = 0
//                self.SignUpView.alpha = 1
//            })
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
