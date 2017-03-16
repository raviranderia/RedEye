//
//  DriverLoginController.swift
//  RedEye
//
//  Created by Marie Fonkou on 12/13/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase

class DriverLoginController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var driverEmailAddressField: TextField!
    @IBOutlet weak var driverPasswordField: TextField!
    @IBOutlet weak var loginBtnPressed: LoginButton!
    
    // MARK: Variables
    var driverEmailAddressList = [String]()
    var driverEmailAddressAndUniqueId = [String : String]()
    var driverIds = [String]()
    var driverUid: String!
    var emailAddress: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getAllDriversEmailAddresses()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
         saveDriverUid()
    }
    
    // get rid of this function if not using it
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // What does this function do?
    func getAllDriversEmailAddresses(){
        
        
        
    
    }
    
    // remove extra lines
    // if you want to follow MVVM architecture...your network calls are made from the view model...create a seperate file called DriverLoginViewModel and create a driverLoginViewModel variable in this controller and make it perform network requests
    // driverEmailAddressList should be a variable in the viewModel
    // basically the view controller should only contain code to display things to UI..no logic or processing happens in the view controller..everything is handled by the viewModel
    
    func checkDriverByEmail(driverEmail: String) {
        FIRDatabase.database().reference().child("Drivers").observe(.childAdded, with: { (snapshot) in
            
            print("snapshot \(snapshot)")
            if let dictionary = snapshot.value as? [String : AnyObject] {
                
                let key = snapshot.key
                self.driverIds.append(key)
                // this is a magic value...create a variable for this in viewModel called driverEmailAddresKey
                if let driverEmailAddress = dictionary["driverEmailAddress"] as? String {
                    self.emailAddress = driverEmailAddress
                }
                self.driverEmailAddressList.append(self.emailAddress)
                self.driverEmailAddressAndUniqueId.updateValue(key, forKey: "\(self.emailAddress)")
                print("dictionary \(self.driverEmailAddressAndUniqueId)")
                
            }
            
            if self.driverEmailAddressList.contains(driverEmail) {
                
                self.driverUid = self.driverEmailAddressAndUniqueId["\(driverEmail)"]
                // magic value..store segue identifer as variable in view model
                self.performSegue(withIdentifier: "goToDriverProfile", sender: nil)
                
            } else {
                // create a common function to display alert controller and simply pass title and message string to it...which also should be defined as variables in viewModel
                let alertControllerVerificationEmail = UIAlertController (title : "Email address unknown", message: "You need to enter your driver information" , preferredStyle: .alert)
                let actionVerification = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                alertControllerVerificationEmail.addAction(actionVerification)
                self.present(alertControllerVerificationEmail, animated: true, completion: nil)
                
                try? FIRAuth.auth()?.signOut()
            }
            
        } , withCancel: nil)
        
        
    }
    
    @IBAction func driverLoginBtnPressed(_ sender: Any) {
        if self.driverEmailAddressField.text == "" || self.driverPasswordField.text == "" {
            // common function to avoid repeating code
            let alertControllerLogin = UIAlertController (title : "Oops, you were too fast", message: "Please make sure to fill in every field.", preferredStyle: .alert)
            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
            alertControllerLogin.addAction(actionSignUp)
            self.present(alertControllerLogin, animated: true, completion: nil)
            
        } else{
            // network logic goes in viewModel
            FIRAuth.auth()?.signIn(withEmail: driverEmailAddressField.text!, password: driverPasswordField.text!, completion: { (user, error) in
                
                if error != nil {
                     // common function to avoid repeating code
                    let alertControllerSignUp = UIAlertController (title : "Come on, you know this!", message: "The password you entered doesn't match the one we have in record." , preferredStyle: .alert)
                    let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                    alertControllerSignUp.addAction(actionSignUp)
                    self.present(alertControllerSignUp, animated: true, completion: nil)
                    if (error?.localizedDescription.contains("invalid"))! {
                        FIRAuth.auth()?.createUser(withEmail: self.driverEmailAddressField.text!, password: self.driverPasswordField.text!, completion: {(user, error) in
                            if error == nil{
                                
                                self.performSegue(withIdentifier: "goToDriverProfile", sender: nil)
                            } else {
                                // error
                            }
                        })
                    } else {
                                    // common function to avoid repeating code

                        let alertControllerVerificationEmail = UIAlertController (title : "Email address unknown", message: "You need to enter your driver information" , preferredStyle: .alert)
                        let actionVerification = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                        alertControllerVerificationEmail.addAction(actionVerification)
                        self.present(alertControllerVerificationEmail, animated: true, completion: nil)
                    }
                    
                } else {
                    
                    // logged in
                    
                    let currentDriver = FIRAuth.auth()?.currentUser
                    self.checkDriverByEmail(driverEmail: (currentDriver?.email)!)

                }
            })
            
        }

    }
    
    
    func login(){
        if self.driverEmailAddressField.text == "" || self.driverPasswordField.text == "" {
                        // common function to avoid repeating code
            let alertControllerLogin = UIAlertController (title : "Oops, you were too fast", message: "Please make sure to fill in every field.", preferredStyle: .alert)
            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
            alertControllerLogin.addAction(actionSignUp)
            self.present(alertControllerLogin, animated: true, completion: nil)
        }else{
        
            self.driverUid = self.driverEmailAddressAndUniqueId["\(self.driverEmailAddressField.text!)"]
            
        FIRAuth.auth()?.signIn(withEmail: driverEmailAddressField.text!, password: driverPasswordField.text!, completion: { (user, error) in
            
            if error != nil{
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
                    default: break
//                        let alertControllerSignUp = UIAlertController (title : "Oops", message: "There's no record for \(self.driverPasswordField.text!) in our database. You might want to sign up first." , preferredStyle: .alert)
//                        let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
//                        alertControllerSignUp.addAction(actionSignUp)
//                        self.present(alertControllerSignUp, animated: true, completion: nil)
                    }
                }
                
            } else {
                self.performSegue(withIdentifier: "goToDriverProfile", sender: nil)
                print ("Succefully logged in \(self.driverEmailAddressField.text)")
                
            }
        })
    }    
}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToDriverProfile") {
            let tabBarController = segue.destination as! UITabBarController
            let navController = tabBarController.viewControllers![0] as! UINavigationController
            let destinationVC = navController.topViewController as! DriverProfileController
            destinationVC.driverUid = self.driverUid!
        }
    }
    
    func saveDriverUid(){
        let defaults = UserDefaults.standard
        defaults.set(driverUid, forKey: "driverEmailAddress")
    }    
    
    func hideKeyboardWhenTappedView (){
        let tap = UITapGestureRecognizer(target: self, action:#selector(LoginController.hideKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func hideKeyBoard(){
        self.view.endEditing(true)
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


