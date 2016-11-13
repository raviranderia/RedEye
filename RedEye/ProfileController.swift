//
//  ProfileController.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper


// 1. Pick profile picture from Camera library. Profile picture is uploaded in the circle frame and as a blurry background image
// 2. Select major using the picker view. 
// => the selected major is the one that will be save in the database : No save button
// 3. Enter address with Address autocompletion 
// => the selected address is the one that will be save in the database: No save button



class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var nuidField: UITextField!
    
    
    @IBOutlet weak var firstnameField: UITextField!

    @IBOutlet weak var lastnameField: UITextField!
    
    
    @IBOutlet weak var adressField: UITextField!
    
    
    @IBOutlet weak var cityField: UITextField!
    
    
    @IBOutlet weak var zipcodeField: UITextField!
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func addProfilePictureBtnPressed(_ sender: UIButton) {
        
        let profilePicturePicker = UIImagePickerController()
        profilePicturePicker.delegate = self
        profilePicturePicker.sourceType = .photoLibrary
        
        self.present(profilePicturePicker, animated: true, completion: nil)
        
        
    }
    
    @IBOutlet weak var profilePictureView: UIImageView!
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePictureView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //self.dismiss(animated: false, completion: nil)
    }
    
//    @IBAction func logoutBtnPressed(_ sender: UIButton) {
//        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
//        try!FIRAuth.auth()?.signOut()
//        performSegue(withIdentifier: "goBackToSignInPage", sender: nil)
//    }
//    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
