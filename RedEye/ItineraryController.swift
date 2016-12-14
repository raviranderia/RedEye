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
    var markers = [GMSMarker]()
     var mapView = GMSMapView()
    //var markers = NSSet()
     var  dictinaryAddresses = [String: Double]()
    var studentPlaceID: String?
    var studentPlaceIDs : [String] = []
    var polyline = GMSPolyline()
  

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Itinerary"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Georgia", size: 34)!, NSForegroundColorAttributeName: Constants.Colors.redColor]
        
        self.fetchStudentsAddresses {}
       
        //self.drawMarkers()
        
        getRouteAPI{}

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 42.33, longitude: -71.08, zoom: 13.0, bearing:0,viewingAngle: 0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.setMinZoom(10, maxZoom: 18)
        mapView.settings.scrollGestures = true
        view = mapView
    }
    
    func drawMarkers(){
         print("DICTIONARY ADDRESSES VIEW DID LOAD \(self.dictinaryAddresses.count) \(self.dictinaryAddresses.values)")
        for address in self.dictinaryAddresses {
            print("HELLO")
            print("LOOP ADDRESS \(address)")
//            let marker = GMSMarker()
//            marker.position = CLLocationCoordinate2D (latitude: address.key)
    }
    }
    
    func fetchStudentsAddresses(handleComplete: @escaping DownloadComplete){
        var studentIDRequest: String = ""
        var studentFirstName = ""
        var studentLastName = ""
        FIRDatabase.database().reference().child("Address").observe(.childAdded, with: {(snapshot) in
            
            
           if let dictionary = snapshot.value as? [String : AnyObject] {
//                 for i in 0..<dictionary.count{
//                    
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
                print("STUDENT ID \(self.studentPlaceID )")
                
            }
            self.studentPlaceIDs.append(self.studentPlaceID!)
            print("STUDENT PLACE ID ARRAY \(self.studentPlaceIDs)")
            
            if let studentID = dictionary["studentID"] as? String{
                studentIDRequest = studentID
                print("STUDENT ID \(studentIDRequest)")
                             FIRDatabase.database().reference().child("Students").child("\(studentIDRequest)").observe(.value, with: {(snapshot) in
                
                                
                                if let dictionary = snapshot.value as? [String : AnyObject] {
                                    if let firstName = dictionary["firstName"] as? String{
                                        studentFirstName = firstName
                                        print("STUDENT FIRST NAME \(studentFirstName)")
                                    }
                                    if let lastName = dictionary["lastName"] as? String{
                                        studentLastName = lastName
                                        print("STUDENT LAST NAME \(studentLastName)")
                                    }
                                   
//                                    self.studentPlaceIDs.append(self.studentPlaceID!)
                                }
                               // DispatchQueue.main.async{
                                    var marker = GMSMarker()
                                    marker.position = CLLocationCoordinate2D(latitude: latitudeRequest, longitude: longitudeRequest)
                                    marker.appearAnimation = kGMSMarkerAnimationPop
                                    marker.icon = GMSMarker.markerImage(with: Constants.Colors.redColor)
                                    print("FIRST NAME \(studentFirstName) LAST NAME \(studentLastName)")
                                    marker.title = "\(studentFirstName) \(studentLastName)"
                                    print("MARKER TITLE \(marker.title)")
                                    if (marker.map == nil){
                                        marker.map = self.mapView
                                        self.markers.append(marker)
                                        
                                        
                                        
                                   // }
                                }
                              
                             } , withCancel: nil)

            }

            }
            print("SNAPSHOT ADDRESS \(snapshot)")
        } , withCancel: nil)
 
         handleComplete()
        
       
        
    }
    
        
        
    
    
    override var prefersStatusBarHidden: Bool{
        return true;
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5, 0, self.bottomLayoutGuide.length + 5, 0)
    }
    
    func getRouteAPI(completed: @escaping DownloadComplete){
        Alamofire.request("\(Constants.URL.googleMapDirectionAPI)\(Constants.Google.DESTINATION)\("EigxNzUgUHJlc2lkZW50cyBMbiwgUXVpbmN5LCBNQSAwMjE2OSwgVVNB")\(Constants.Google.WAYPOINTS)\("ChIJaXb0bp1544kRT1twn2TEHq4")\(Constants.Google.API_KEY)").responseJSON { response in
            print("ITINERARY URL \("\(Constants.URL.googleMapDirectionAPI)\(Constants.Google.DESTINATION)\("EigxNzUgUHJlc2lkZW50cyBMbiwgUXVpbmN5LCBNQSAwMjE2OSwgVVNB")\(Constants.Google.WAYPOINTS)\("ChIJaXb0bp1544kRT1twn2TEHq4")\(Constants.Google.API_KEY)")")
            
            let result = response.result
            if let dictionary = result.value as? Dictionary<String, AnyObject>{
                
                var encodedPolyline = ""
//                if let results = dictionary["geocoded_waypoints"] as? [Dictionary<String, AnyObject>]{
//                    print ("RESULTS ITINERARY API : \(results)")
                    if let routes = dictionary["routes"] as? [Dictionary<String, AnyObject>] {
                        print("ROUTE \(routes)")
                        if let overviewPolyline = routes[0]["overview_polyline"] as? Dictionary<String, AnyObject> {
                            if let points = overviewPolyline["points"] as? String {
                                encodedPolyline = points
                                  print("POINTS \(points)")
                                var encodedPath = GMSPath()
                                encodedPath = GMSPath(fromEncodedPath:encodedPolyline)!
                                self.polyline = GMSPolyline(path: encodedPath)
                                self.polyline.strokeWidth = 7
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
