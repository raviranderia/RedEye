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


    @IBOutlet var loginViewEffect: UIVisualEffectView!
    
    
    @IBOutlet weak var redEyelabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var emailField: UITextField!
      
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedView()
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "goToProfile", sender: nil)

            } else {
                
            }
        }
        
//        if (FIRAuth.auth()?.currentUser?.uid) != nil{
////            let profileController = ProfileController()
////            present(profileController, animated:true, completion:nil)
//            performSegue(withIdentifier: "goToProfile", sender: nil)
//            
//        }
//        
        
    }
    
    @IBAction func loginBtnPressed(sender: AnyObject) {
        
        if self.emailField.text == "" || self.passwordField.text == "" {
            
            let alertControllerLogin = UIAlertController (title : "Oops, you were too fast", message: "Please make sure to fill in every field.", preferredStyle: .alert)
            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
            alertControllerLogin.addAction(actionSignUp)
            self.present(alertControllerLogin, animated: true, completion: nil)
        }else{
            FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: {(user, error) in
                if error == nil{
                    if (user?.isEmailVerified)! {
                        print("Email verified")
                      self.performSegue(withIdentifier: "goToProfile", sender: nil)
                        print ("Succefully logged in \(self.emailField.text)")
                    }else{
                        print("Email not verified")
                        let alertControllerVerificationEmail = UIAlertController (title : "Verification required", message: "You need to verify your husky email address before logging in" , preferredStyle: .alert)
                        let actionVerification = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                        alertControllerVerificationEmail.addAction(actionVerification)
                        self.present(alertControllerVerificationEmail, animated: true, completion: nil)
                    }
                
                } else if (error != nil){
                    if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            let alertControllerSignUp = UIAlertController (title : "Oops", message: "The email address you provided is invalid." , preferredStyle: .alert)
                            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                            alertControllerSignUp.addAction(actionSignUp)
                            self.present(alertControllerSignUp, animated: true, completion: nil)
                            break
                        case .errorCodeWrongPassword:
                            let alertControllerSignUp = UIAlertController (title : "Come on, you know this!", message: "The password you entered doesn't match the one we have in record." , preferredStyle: .alert)
                            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                            alertControllerSignUp.addAction(actionSignUp)
                            self.present(alertControllerSignUp, animated: true, completion: nil)
                            break
                        default:
                            let alertControllerSignUp = UIAlertController (title : "Oops", message: "There's no record for \(self.emailField.text!) in our database. You might want to sign up first." , preferredStyle: .alert)
                            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                            alertControllerSignUp.addAction(actionSignUp)
                            self.present(alertControllerSignUp, animated: true, completion: nil)
                        }
                    }
                    
                }
            })
        }

    }
    
    
 
    
    func hideKeyboardWhenTappedView (){
        let tap = UITapGestureRecognizer(target: self, action:#selector(LoginController.hideKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func hideKeyBoard(){
        self.view.endEditing(true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
        //            performSegue(withIdentifier: "goToSchedule", sender: nil)
        ////             performSegue(withIdentifier: "goToProfile", sender: nil)
        //        }
    }
    

//    
//    func successfullyLogin(id: String){
//        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
//        print ("UID SAVED FOR USER \(keychainResult)")
//            
//    }
    

}

