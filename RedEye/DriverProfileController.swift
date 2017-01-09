//
//  DriverProfileController.swift
//  RedEye
//
//  Created by Marie Fonkou on 12/13/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase

class DriverProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var backgroundProfilePicture: UIImageView!
    
    
    @IBOutlet weak var driverFirstName: UILabel!
    
    
    @IBOutlet weak var driverLastName: UILabel!
    
    
    @IBOutlet weak var driverProfilePicture: UIImageView!
    
    var driverUid: String!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        
        self.navigationController?.navigationBar.topItem?.title = "profile"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
    
        self.driverProfilePicture.layer.cornerRadius = driverProfilePicture.frame.size.height / 2
        self.driverProfilePicture.layer.masksToBounds = true
        self.driverProfilePicture.layer.borderWidth = 5
        self.driverProfilePicture.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        self.driverProfilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addProfilePicture)))
        self.driverProfilePicture.isUserInteractionEnabled = true
        
        
        
        activityIndicator.center = self.view.center
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        
        self.driverFirstName.isHidden = true
        self.driverLastName.isHidden = true
        self.driverProfilePicture.isHidden = true
        activityIndicator.startAnimating()
        
        
        self.fetchDriverInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        if (FIRAuth.auth()?.currentUser?.uid) != nil{
            
            try? FIRAuth.auth()?.signOut()
            var appDelegate: AppDelegate
            appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController
                = self.storyboard?.instantiateViewController(withIdentifier: "driverOrStudentVC")
            
        }
    }
    
    func fetchDriverInformation(){
        
        var driverFirstName: String = ""
        var driverLastName:  String = ""
        var driverProfilePicture: String = ""
        
        
        FIRDatabase.database().reference().child("Drivers").child(driverUid).observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject]{
                
                if let firstName = dictionary["driverFirstName"] as? String {
                    driverFirstName = firstName
                    print("first name \(driverFirstName)")
                }
                
                if let lastName = dictionary["driverLastName"] as? String {
                    driverLastName = lastName
                    print("last name \(driverLastName)")
                }
                
                
                if let profilePictureUrl = dictionary["profilePictureUrl"] as? String{
                    
                    driverProfilePicture = profilePictureUrl
                    print("driver profile picture \(driverProfilePicture)")
                }
                
                if driverProfilePicture == "No profile picture"{
                    DispatchQueue.main.async{
                        self.activityIndicator.stopAnimating()
                        self.driverFirstName.isHidden = false
                        self.driverLastName.isHidden = false
                        self.driverProfilePicture.isHidden = false
                        self.driverFirstName.text = driverFirstName
                        self.driverLastName.text = driverLastName
                        self.driverProfilePicture.image = UIImage(named:"Profile Picture Icon-2")
                        self.backgroundProfilePicture.image = UIImage(named:"Profile Picture Icon-2")
                    }
                } else{
                    
                    let url = driverProfilePicture
                    
                    print("Succefully loaded profile picture")
                    self.activityIndicator.stopAnimating()
                    self.driverFirstName.isHidden = false
                    self.driverLastName.isHidden = false
                    self.driverProfilePicture.isHidden = false
                    self.driverFirstName.text = driverFirstName
                    self.driverLastName.text = driverLastName
//                    self.driverProfilePicture.loadImageWithCache(urlString: url)
//                    self.backgroundProfilePicture.loadImageWithCache(urlString: url)
                    let imageUrl = NSURL(string: url)
                    let placeHolderImage = UIImage.init(named: "Profile Picture Icon-2")
                    self.driverProfilePicture.sd_setImage(with: imageUrl as! URL, placeholderImage: placeHolderImage)
                    self.backgroundProfilePicture.sd_setImage(with: imageUrl as! URL, placeholderImage: placeHolderImage)
                    
                }

            }
            
        } ,withCancel : nil)
        
    }
    
    func addProfilePicture() {
        
        let profilePicturePicker = UIImagePickerController()
        profilePicturePicker.delegate = self
        profilePicturePicker.allowsEditing = true
        profilePicturePicker.sourceType = .photoLibrary
        
        self.present(profilePicturePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        driverProfilePicture.image = image
        backgroundProfilePicture.image = image
        
//        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
//            return
//        }
        let ref = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
        
        let pictureName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("drivers_profile_pictures").child("\(pictureName).png")
        if let uploadProfilePicture = UIImagePNGRepresentation(self.driverProfilePicture.image!){
            storageRef.put(uploadProfilePicture, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print ("Error while uploading profile picture to storage : \(error?.localizedDescription)")
                    return
                    
                }else{
                    print(metadata!)
                    if let profilePictureUrl = metadata?.downloadURL()?.absoluteString{
                        let studentReference = ref.child("Drivers").child(self.driverUid!)
                        let values = ["profilePictureUrl": profilePictureUrl]
                        studentReference.updateChildValues(values, withCompletionBlock: { (errorStorage, ref) in
                            if errorStorage != nil {
                                print ("Error saving profile picture in database: \(errorStorage?.localizedDescription)")
                                return
                            } else{
                                print ("Successefully saved profile picture \(profilePictureUrl)")
                            }
                        })
                        
                        
                    }
                    
                }
            })
        }
        
        
        self.dismiss(animated: true, completion: nil)
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
