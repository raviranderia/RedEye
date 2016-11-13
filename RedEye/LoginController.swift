//
//  ViewController.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper

// 1. If student chooses Log in, display view with email and password
// => Password must be at least 6 characters long and contains numbers and letters = > Alert if not
// => Check if email and password match the database
// 2. If student chooses Sign up, display view with first name, last Name, NEU ID, email and password
// => Email should be unique => Alert if email is already associated to another account
// 3. If logging in, next view is the shuttle schedule
// 4. If signiung up, next view is a pop up with a link to gmail that ask student to verify their email

class LoginController: UIViewController {


    
    @IBOutlet weak var redEyelabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var usernameField: UITextField!
    
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
        //            performSegue(withIdentifier: "goToSchedule", sender: nil)
        ////             performSegue(withIdentifier: "goToProfile", sender: nil)
        //        }
    }
    
    
//    @IBAction func loginBtnPressed(_ sender: AnyObject) {
//    
//        
//        if let username = usernameField.text, let password = passwordField.text {
//            
//            FIRAuth.auth()?.signIn(withEmail: username, password: password , completion: { (user, error) in
//                if error == nil {
//                    print ("SUCCESSFULLY LOGIN ALREADY EXISTING STUDENT")
//                    if let user = user{
//                        self.successfullyLogin(id: user.uid)
//                        // self.performSegue(withIdentifier: "goToSchedule", sender: nil)
//                        self.performSegue(withIdentifier: "goToProfile", sender: nil)
//                    }
//                    
//                } else{
//                    FIRAuth.auth()?.createUser(withEmail: username, password: password, completion: { (user, error) in
//                        if error != nil{
//                            // Alert
//                        } else{
//                            print ("SUCCESSFULLY LOGIN NEW STUDENT")
//                            if let user = user{
//                                self.successfullyLogin(id: user.uid)
//                                 self.performSegue(withIdentifier: "goToProfile", sender: nil)
//                                
//
//                            }
//                            
//                        }
//                    })
//                }
//            })
//        }
//        
//        
//    }
//    
//    func successfullyLogin(id: String){
//        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
//        print ("UID SAVED FOR USER \(keychainResult)")
//            
//    }
    

}

