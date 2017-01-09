//
//  ProfileController.swift
//  RedEye
//
//  Created by Marie Fonkou on 10/17/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import CoreLocation
import Alamofire


// 1. Pick profile picture from Camera library. Profile picture is uploaded in the circle frame and as a blurry background image
// 2. Select major using the picker view. 
// => the selected major is the one that will be save in the database : No save button
// 3. Enter address with Address autocompletion
// => the selected address is the one that will be save in the database: No save button


extension UISearchBar {
    public func setSerchTextcolor(color: UIColor) {
        let clrChange = subviews.flatMap { $0.subviews }
        guard let sc = (clrChange.filter { $0 is UITextField }).first as? UITextField else { return }
        sc.textColor = color
    }
}

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate , UITextFieldDelegate,  CLLocationManagerDelegate,GMSAutocompleteViewControllerDelegate{
    
    @IBOutlet var studentFirstNameLabel: UILabel!
    
    @IBOutlet weak var studentLastName: UILabel!
    
    @IBOutlet weak var backgroundPicture: UIImageView!
    
    @IBOutlet weak var profileInfoHolderView: UIView!
    
    @IBOutlet weak var profilePictureImage: UIImageView!

    @IBOutlet weak var majorTextField: profileTextField!
    
    @IBOutlet var addressTextField: profileTextField!
    
    @IBOutlet weak var majorPicker: UIPickerView!
    
    var studentAddress = StudentAddress()
    
    var addresses = [StudentAddress]()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    @IBAction func addressFieldTapped(_ sender: Any) {
        let autoComplete = GMSAutocompleteViewController()
        autoComplete.delegate = self
     
        autoComplete.searchDisplayController?.searchBar.setSerchTextcolor(color: UIColor.red)
   
        
        //self.locationManager.startUpdatingLocation()
        self.present(autoComplete, animated: true, completion: nil)
    }
 
    
    @IBAction func signoutPressed(_ sender: UIButton) {
        
        if (FIRAuth.auth()?.currentUser?.uid) != nil{
            
            try? FIRAuth.auth()?.signOut()
            var appDelegate: AppDelegate
            appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.window?.rootViewController
                = self.storyboard?.instantiateViewController(withIdentifier: "driverOrStudentVC")
      
        }
    }

    
    var majors = ["Accountig", "Accounting", "African Studies", "African-American Studies", "Air Force ROTC", "American Sign Language", "Analytics","Anthropology","Arabic","Architecture","Army","Art","Asian Studies","Behavioral Neuroscience","Biochemistry","Bioengineering","Bioinformatics","Biology","Biology","Biotechnology","Business","Business Administration","Business Law","Career Development","Chemistry & Chemical Biology","Chemistry","Chinese","Civil & Enviro Eng","Commerce & Economic Dev","Communication Studies","Comp Engneering Tech","Computer Science","Computer Systems Engineering","Construction Mangmnt","Criminal Justice","Culture","Data Analytics","Data Science","Deaf Studies","Design","Digital Media","Economics","Education","Energy Systems","English","Information Systems","Health Science"]
    

    //var majors = [Major]()
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.view.backgroundColor = UIColor.black
        self.profileInfoHolderView.backgroundColor = UIColor.clear
        
        self.navigationController?.navigationBar.topItem?.title = "profile"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
        //        self.navigationController!.navigationBar.frame = CGRect(x:0, y:0, width:self.view.frame.size.width, height:80.0)
        
        self.profilePictureImage.layer.cornerRadius = profilePictureImage.frame.size.height / 2
        self.profilePictureImage.layer.masksToBounds = true
        self.profilePictureImage.layer.borderWidth = 5
        self.profilePictureImage.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        self.profilePictureImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addProfilePicture)))
        self.profilePictureImage.isUserInteractionEnabled = true
        
        
        self.profileInfoHolderView.layer.cornerRadius = 17
        self.profileInfoHolderView.layer.borderWidth = 2
        self.profileInfoHolderView.layer.borderColor = (Constants.Colors.grayColor).cgColor
        
        
        majorPicker.delegate = self
        majorPicker.dataSource = self
        
        majorTextField.delegate = self
        addressTextField.delegate = self
        
        majorTextField.inputView = majorPicker
        
        activityIndicator.center = self.view.center
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        self.profileInfoHolderView.isHidden=true
        self.majorTextField.isHidden = true
        self.addressTextField.isHidden = true
        self.studentFirstNameLabel.isHidden = true
        self.studentLastName.isHidden = true
        self.profilePictureImage.isHidden = true
        activityIndicator.startAnimating()
        
        
        
        self.fetchStudentInformation()
        self.fetchStudentAddress()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBarTextAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        UITextField.appearance(whenContainedInInstancesOf:[UISearchBar.self]).defaultTextAttributes = searchBarTextAttributes
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    func fetchStudentInformation(){
        
        let pictureCache = NSCache<NSString, UIImage>()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        
        var studentFirstName: String = ""
        var studentLastName:  String = ""
        var studentMajor: String = ""
        var studentProfilePicture: String = ""
        
        FIRDatabase.database().reference().child("Students").child(uid).observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
            print(snapshot)
            
            
            if snapshot.value is NSNull {
                return
            }
            let dictionary = snapshot.value as! [String:AnyObject]
            //DispatchQueue.main.async{
            
            if let firstName = dictionary["firstName"] as? String {
                studentFirstName = firstName
            }
            
            if let lastName = dictionary["lastName"] as? String {
                studentLastName = lastName
            }
            
            if let major = dictionary["studentMajor"] as? String {
                studentMajor = major
            }
            
            if let profilePictureUrl = dictionary["profilePictureUrl"] as? String{
                
                studentProfilePicture = profilePictureUrl
                print("student profile picture \(studentProfilePicture)")
            }
            //                        if let cachedPicture = pictureCache.object(forKey: profilePictureUrl as NSString)! as? UIImage{
            //                            self.profilePictureImage.image = cachedPicture
            //                            return
            //                        }

                        if studentProfilePicture == "No profile picture"{
                        DispatchQueue.main.async{
                            self.activityIndicator.stopAnimating()
                            self.profileInfoHolderView.isHidden=false
                            self.majorTextField.isHidden = false
                            self.addressTextField.isHidden = false
                            self.addressTextField.adjustsFontSizeToFitWidth = true;
                            self.studentFirstNameLabel.isHidden = false
                            self.studentLastName.isHidden = false
                            self.profilePictureImage.isHidden = false
                            self.studentFirstNameLabel.text = studentFirstName
                            self.studentLastName.text = studentLastName
                            self.majorTextField.text = studentMajor
                            self.profilePictureImage.image = UIImage(named:"Profile Picture Icon-2")
                            self.backgroundPicture.image = UIImage(named:"Profile Picture Icon-2")
                        }
                    } else{
                        
                    let url = studentProfilePicture
                    
                                    print("Succefully loaded profile picture")
                                    self.activityIndicator.stopAnimating()
                                    self.profileInfoHolderView.isHidden=false
                                    self.majorTextField.isHidden = false
                                   self.addressTextField.isHidden = false
                            self.addressTextField.adjustsFontSizeToFitWidth = true;
                                self.studentFirstNameLabel.isHidden = false
                                self.studentLastName.isHidden = false
                                self.profilePictureImage.isHidden = false
                                self.studentFirstNameLabel.text = studentFirstName
                                self.studentLastName.text = studentLastName
                               self.majorTextField.text = studentMajor
                            let placeHolderImage = UIImage.init(named: "Profile Picture Icon-2")
                            let imageUrl = NSURL(string: url)
                            self.profilePictureImage.sd_setImage(with: imageUrl as! URL, placeholderImage: placeHolderImage)
                            self.backgroundPicture.sd_setImage(with: imageUrl as! URL, placeholderImage: placeHolderImage)
                                    //self.profilePictureImage.loadImageWithCache(urlString: url)
                                    //self.backgroundPicture.loadImageWithCache(urlString: url)
                       
            }
        } , withCancel: nil)
        
    
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return majors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        self.view.endEditing(true)
        return majors[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
         return NSAttributedString(string: majors[row], attributes: [NSForegroundColorAttributeName:UIColor.gray])
    }
    
    func pickerView (_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        majorTextField.text = self.majors[row]
        print("didselectrow \( majorTextField.text)")
        majorPicker.isHidden = true
        majorTextField.isHidden = false
        addressTextField.isHidden = false
        self.addressTextField.adjustsFontSizeToFitWidth = true;
        self.saveStudentMajor()
        
    }
    
    func textFieldDidBeginEditing (_ textField: UITextField){
        if textField == self.majorTextField{
            print("textFieldDidBeginEditing \(textField)")

            majorPicker.isHidden = false
            majorTextField.isHidden = true
            addressTextField.isHidden = true
            majorTextField.endEditing(true)
        
        }
    }


   

    func saveStudentMajor(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let studentReference = Constants.URL.ref.child("Students").child(uid)
        let values = ["studentMajor": majorTextField.text]
        studentReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print ("Error saving major in database: \(error?.localizedDescription)")
                return
            } else{
                print ("Successefully saved major \(self.majorTextField.text)")
            }
        })
        
        }
    
    func saveStudentAddress(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let studentReference = Constants.URL.ref.child("Address").child(uid)
        let values = ["studentAddress": addressTextField.text!, "studentPlaceID": studentAddress.placeID, "studentID": uid]
        studentReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print ("Error saving address in database: \(error?.localizedDescription)")
                return
            } else{
                print ("Successefully saved address \(self.addressTextField.text)")
            }
        })
        
        
    }
    
    func fetchStudentAddress(){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
         FIRDatabase.database().reference().child("Address").child(uid).observeSingleEvent(of: .value, with: {(snapshot: FIRDataSnapshot) in
        
            if let dictionary = snapshot.value as? [String:AnyObject]{
                  self.addressTextField.text = dictionary["studentAddress"] as? String
            }
         })}
    
    
    
    
     func addProfilePicture() {
        
        let profilePicturePicker = UIImagePickerController()
        profilePicturePicker.delegate = self
        profilePicturePicker.allowsEditing = true
        profilePicturePicker.sourceType = .photoLibrary
        
        self.present(profilePicturePicker, animated: true, completion: nil)
    }
  
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        profilePictureImage.image = image
        backgroundPicture.image = image
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let ref = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
       
        let pictureName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_pictures").child("\(pictureName).png")
        if let uploadProfilePicture = UIImagePNGRepresentation(self.profilePictureImage.image!){
            storageRef.put(uploadProfilePicture, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print ("Error while uploading profile picture to storage : \(error?.localizedDescription)")
                    return
                    
                }else{
                    print(metadata!)
                    if let profilePictureUrl = metadata?.downloadURL()?.absoluteString{
                        let studentReference = ref.child("Students").child(uid)
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
    
  
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         self.dismiss(animated: true, completion: nil)
        }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print ("Fail to get auto complete address \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace){
        self.addressTextField.text! = place.formattedAddress!
        self.studentAddress._placeID = place.placeID
        self.getAddressCordinates{}
        self.saveStudentAddress()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func getAddressCordinates(completed: @escaping DownloadComplete){
        Alamofire.request("\(Constants.URL.googleGeocodingAPI)\(self.addressTextField.text!.replacingOccurrences(of: " ", with: ""))\(Constants.Google.GEOLOCATION_API_KEY )").responseJSON {
        response in
        let result = response.result
            if let dictionary = result.value as? Dictionary <String, AnyObject>{
                if let results = dictionary["results"] as? [Dictionary <String, AnyObject>]{
                    var latitudeRequest: Double = 0.0
                    var longitudeRequest: Double = 0.0
                    if let geometry = results[0]["geometry"] as?  Dictionary<String, AnyObject>{
                        if let location = geometry["location"] as? Dictionary<String, AnyObject> {
                            if let latitude = location["lat"] as? Double {
                                latitudeRequest = latitude
                                
                            }
                            if let longitude = location["lng"] as? Double{
                                longitudeRequest = longitude
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.studentAddress = StudentAddress(latitude:latitudeRequest, longitude:longitudeRequest)
                        print("ADDRESS CONSTRUCTOR \(self.studentAddress._latitude) \(self.studentAddress._longitude)")
                        self.saveLatAndLong()
                        self.addresses.append(self.studentAddress)
                    })
                   

                }
             
            }
       
            
        }
        completed()

        
    }
    
    func saveLatAndLong(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else{
            return
        }
        let ref = FIRDatabase.database().reference(fromURL: Constants.URL.firebaseDatabase)
        let studentReference = ref.child("Address").child(uid)
        let values = ["studentAddressLatitude" : self.studentAddress._latitude , "studentAddressLongitude" : self.studentAddress._longitude]
        print("save latitude \(self.studentAddress._latitude) and save longitude \(self.studentAddress._longitude)")
        studentReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil {
                print ("Error saving lat and long in database: \(error?.localizedDescription)")
                return
            } else{
                print ("Successefully saved lat and long \(self.studentAddress._latitude) \(self.studentAddress._longitude)")
            }
        })
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


