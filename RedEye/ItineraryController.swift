//
//  ItineraryController.swift
//  RedEye
//
//  Created by Marie Fonkou on 11/24/16.
//  Copyright © 2016 Marie Fonkou. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import GoogleMaps

class ItineraryController: UIViewController {
    
     var studentAddress = StudentAddress()
    var studentAddresses = [StudentAddress]()
   // var scheduleId: String = ""
    var markers = [GMSMarker]()
     var mapView = GMSMapView()
    //var markers = NSSet()
     var  dictinaryAddresses = [String: Double]()
    var studentPlaceID: String?
    var studentPlaceIDs : [String] = []
    var polyline = GMSPolyline()
    var waypointsString = Constants.Google.WAYPOINTS
    var waypointsList = ""
    var waypointsFormatted = ""
  

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getRouteAPI {
            
        }
       
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Itinerary"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
        self.fetchStudentsAddresses { (studentAddress) in
            
            self.waypointsFormatted = studentAddress
            
        }
        
        // getRouteAPI{}

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 42.33, longitude: -71.08, zoom: 15.0, bearing:0,viewingAngle: 0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.tiltGestures = true
        mapView.setMinZoom(10, maxZoom: 18)
        mapView.settings.scrollGestures = true
        view = mapView
        
    }
    
    func fetchStudentsAddresses(completionHandler: @escaping (_ studentAddresses: String) -> ()){
        var studentIDRequest: String = ""
        var studentFirstName = ""
        var studentLastName = ""
        let defaults = UserDefaults.standard
        let scheduleId = defaults.string(forKey: "studentScheduleId")
        

            FIRDatabase.database().reference().child("Schedule").child(scheduleId!).child("Reservations").observe(.childAdded, with: {(snapshot) in
                let addressReference = Constants.URL.ref.child("Address").child(snapshot.key)
                addressReference.observe(.value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String : AnyObject] {
                        
                        
                        var latitudeRequest: Double = 0.0
                        var longitudeRequest: Double = 0.0
                        
                        if let latitude = dictionary["studentAddressLatitude"] as? Double{
                            latitudeRequest = latitude
                        }
                        if let longitude = dictionary["studentAddressLongitude"] as? Double{
                            longitudeRequest = longitude
                        }
                        if let placeID = dictionary["studentPlaceID"] as? String{
                            self.studentPlaceID = placeID
                            
                        }
                        
                        self.studentPlaceIDs.append("\(self.studentPlaceID!)|place_id:")
                        self.waypointsList = self.studentPlaceIDs.joined(separator: "")
                        self.waypointsFormatted = self.waypointsList.chopSuffix(10)
                        completionHandler(self.waypointsFormatted)
                        print(self.waypointsFormatted)
                        
                        if let studentID = dictionary["studentID"] as? String{
                            studentIDRequest = studentID
                            FIRDatabase.database().reference().child("Students").child("\(studentIDRequest)").observe(.value, with: {(snapshot) in
                                
                                
                                if let dictionary = snapshot.value as? [String : AnyObject] {
                                    if let firstName = dictionary["firstName"] as? String{
                                        studentFirstName = firstName
                                    }
                                    if let lastName = dictionary["lastName"] as? String{
                                        studentLastName = lastName
                                    }
                                    
                                }
                                //DispatchQueue.main.async{
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: latitudeRequest, longitude: longitudeRequest)
                                marker.appearAnimation = kGMSMarkerAnimationPop
                                marker.icon = GMSMarker.markerImage(with: Constants.Colors.redColor)
                                marker.title = "\(studentFirstName) \(studentLastName)"
                                if (marker.map == nil){
                                    marker.map = self.mapView
                                    self.markers.append(marker)
                                    }
                                //}
                                
                            } , withCancel: nil)
                        }
                    }
                    
                } , withCancel: nil)
               
                
            } , withCancel: nil)
        
        
        }
    
    
    override var prefersStatusBarHidden: Bool{
        return true;
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5, 0, self.bottomLayoutGuide.length + 5, 0)
        
    }
    
    func getRouteAPI(completed: @escaping DownloadComplete){
          print(self.waypointsFormatted)
        
        let waypointUrl = self.waypointsFormatted.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        Alamofire.request("\(Constants.URL.googleMapDirectionAPI)\(Constants.Google.DESTINATION)ChIJ4VzPmRl644kRw5bUbgV-4UY\(Constants.Google.WAYPOINTS)\(waypointUrl)\(Constants.Google.API_KEY)").responseJSON { response in
            print("ITINERARY URL \("\(Constants.URL.googleMapDirectionAPI)\(Constants.Google.DESTINATION)ChIJ4VzPmRl644kRw5bUbgV-4UY\(Constants.Google.WAYPOINTS)\(waypointUrl)\(Constants.Google.API_KEY)")")
            
            let result = response.result
            print(result.error.debugDescription, result.description)
            if let dictionary = result.value as? Dictionary<String, AnyObject>{
                
                var encodedPolyline = ""
                    if let routes = dictionary["routes"] as? [Dictionary<String, AnyObject>] {
                        print("ROUTE \(routes)")
                        if let overviewPolyline = routes[0]["overview_polyline"] as? Dictionary<String, AnyObject> {
                            if let points = overviewPolyline["points"] as? String {
                                encodedPolyline = points
                                  print("POINTS \(points)")
                                var encodedPath = GMSPath()
                                encodedPath = GMSPath(fromEncodedPath:encodedPolyline)!
                                self.polyline = GMSPolyline(path: encodedPath)
                                self.polyline.strokeWidth = 3
                                self.polyline.strokeColor = Constants.Colors.redColor
                                self.polyline.map = self.mapView
                                
                            }
                        }

                    
                }
        
            }

            completed()
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
        

}

extension String {
    
    func chopSuffix(_ count: Int = 1) -> String {
        return self.substring(to: self.characters.index(self.endIndex, offsetBy: -count))
    }
}


