//
//  SignUpController.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/12/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase

extension UIVisualEffectView {
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self.contentView ? nil : view
    }
}

class SignUpController: UIViewController {
    
    @IBOutlet weak var lastNameField: TextField!

    @IBOutlet weak var huskyEmailField: TextField!
    
    @IBOutlet weak var passwordField: TextField!
    
    
    @IBOutlet weak var firstNameField: TextField!
    
    @IBOutlet var checkEmailView: UIView!
 
    @IBOutlet weak var visualEffectEmail: UIVisualEffectView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        effect = visualEffectEmail.effect
        visualEffectEmail.effect = nil
        checkEmailView.layer.cornerRadius = 10
        hideKeyboardWhenTappedView()
        
           }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        let firstName = self.firstNameField.text
        let lastName = self.lastNameField.text
        let email = self.huskyEmailField.text
        
        if self.lastNameField.text == "" || self.huskyEmailField.text == "" || self.passwordField.text == "" || self.firstNameField.text == "" {
            
            let alertControllerSignUp = UIAlertController (title : "Oops, you were too fast", message: "Please make sure to fill in every field.", preferredStyle: .alert)
            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
            alertControllerSignUp.addAction(actionSignUp)
            self.present(alertControllerSignUp, animated: true, completion: nil)
            
        } else{
            
            FIRAuth.auth()?.createUser (withEmail: self.huskyEmailField.text!, password : self.passwordField.text!, completion: {(user, error) in
                if error == nil{
                    user?.sendEmailVerification() { error in
                     
                        if error == nil {
                            print ("Verification email sent to \(self.huskyEmailField.text)")
                            guard let uid = user?.uid else{
                                return
                            }
                            let ref = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
                            let studentReference = ref.child("Students").child(uid)
                            
                            let values = ["firstName": firstName, "lastName": lastName, "email": email, "hasReservation":"NO"]
                            studentReference.updateChildValues(values, withCompletionBlock: { (errorDatabase, ref) in
                                if errorDatabase != nil {
                                    print ("Error saving data in database: \(errorDatabase?.localizedDescription)")
                                    return
                                } else{
                                    print ("Successefully saved user \(email)")
                                }
                            })

                            self.animateIn()
                        } else {
                            print ("Error sending email verification \(error?.localizedDescription)")
                        }
                        
                                                       
                    }
                    } else if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                        switch errCode {
                        case .errorCodeEmailAlreadyInUse:
                            let alertControllerSignUp = UIAlertController (title : "We can't find you", message: "The email you provided has already been used. You should be able to directly log in." , preferredStyle: .alert)
                            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                            alertControllerSignUp.addAction(actionSignUp)
                            self.present(alertControllerSignUp, animated: true, completion: nil)
                            break
                        default:
                            let alertControllerSignUp = UIAlertController (title : "Oops", message: error?.localizedDescription, preferredStyle: .alert)
                            let actionSignUp = UIAlertAction (title: "OK", style: . cancel, handler : nil)
                            alertControllerSignUp.addAction(actionSignUp)
                            self.present(alertControllerSignUp, animated: true, completion: nil)

                            break
                        }
                
                    
                }})
          
        }
        
       
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
         animateOut()
    }
    
    
    @IBAction func checkEmailBtnPressed(sender: AnyObject) {

        let url  = NSURL(string: Constants.URL.gmailURL);
        if UIApplication.shared.canOpenURL(url! as URL) == true
        {
            UIApplication.shared.openURL(url! as URL)
        } else{
            UIApplication.shared.open(NSURL(string:"https://mail.google.com") as! URL, options: [:], completionHandler: nil)
        }
    }
   
    var effect: UIVisualEffect!
    
  
    
    
    func animateIn(){
        self.view.addSubview(checkEmailView)
        checkEmailView.center = self.view.center
        checkEmailView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        checkEmailView.alpha = 0
        
        UIView.animate(withDuration: 0.4){
            self.visualEffectEmail.effect = self.effect
            self.checkEmailView.alpha = 1
            self.checkEmailView.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut(){
        UIView.animate(withDuration: 0.3 , animations: {
            self.checkEmailView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.checkEmailView.alpha = 0
            
            self.visualEffectEmail.effect = nil
        }) {(success: Bool) in self.checkEmailView.removeFromSuperview()
        }
    }
    
    func hideKeyboardWhenTappedView (){
        let tap = UITapGestureRecognizer(target: self, action:#selector(SignUpController.hideKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func hideKeyBoard(){
        self.view.endEditing(true)
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
