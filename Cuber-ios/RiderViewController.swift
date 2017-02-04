//
//  RiderViewController.swift
//  Cuber-ios
//
//  Created by Pourpre on 2/2/17.
//  Copyright © 2017 Pourpre. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RiderViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    
    //--------------------------------------
    //MARK: - Variable declaration
    //--------------------------------------

    var locationManeger = CLLocationManager()
    var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var riderRequestActive = false
    var driverOnTheWay = false
    
    //--------------------------------------
    //MARK: - IBOutlet declaration
    //--------------------------------------
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callACuberLbl: UIButton!
    @IBOutlet weak var messageLbl: UILabel!
    
    
    //--------------------------------------
    //MARK: - Function declaration
    //--------------------------------------
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            if !driverOnTheWay {
            
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.map.setRegion(region, animated: true)
                
                
                self.map.removeAnnotations(self.map.annotations)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = userLocation
                annotation.title = "Your Location"
                
                self.map.addAnnotation(annotation)
            }
            //
            // Live update rider location in the RiderRequest
            // TO DO: Implement a way to update only if necessary
            //
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                        
                        riderRequest["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        
                        riderRequest.saveInBackground()
                        
                    }
                }
            
            })
            //
            //End of Live update
            //
        }
        
        if riderRequestActive == true {
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in

                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                        
                        if let driverUsername = riderRequest["driverResponded"] {
                            
                            let query = PFQuery(className: "DriverLocation")
                            
                            query.whereKey("username", equalTo: driverUsername)
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                if let driverLocations = objects {
                                    
                                    for driverLocationObject in driverLocations {
                                        
                                        if let driverLocation = driverLocationObject["location"] as? PFGeoPoint {
                                            
                                            self.driverOnTheWay = true
                                            
                                            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            let riderCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            
                                            let distance = riderCLLocation.distance(from: driverCLLocation) / 1000
                                            
                                            let roundedDistance = round(distance * 100) / 100
                                            
                                            self.messageLbl.text = "Your driver is \(roundedDistance)km away"
                                            
                                            self.callACuberLbl.isHidden = true
                                            
                                            let latDelta = abs(driverLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            
                                            let lonDelta = abs(driverLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            
                                            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                            
                                            self.map.removeAnnotations(self.map.annotations)
                                            
                                            self.map.setRegion(region, animated: true)
                                            
                                            
                                            let userLocationAnnotation = MKPointAnnotation()
                                            
                                            userLocationAnnotation.coordinate = self.userLocation
                                            
                                            userLocationAnnotation.title = "Your location"
                                            
                                            self.map.addAnnotation(userLocationAnnotation)
                                            
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            driverLocationAnnotation.title = "Your driver"
                                            
                                            self.map.addAnnotation(driverLocationAnnotation)

                                            
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    
    //--------------------------------------
    //MARK: - IBAction declaration
    //--------------------------------------
    
    @IBAction func callACuberBtn(_ sender: UIButton) {
        
        if riderRequestActive {
            
            riderRequestActive = false
            callACuberLbl.setTitle("Call a cUBER", for: [])
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                        
                        riderRequest.deleteInBackground()
                            
                    }
                }
            })
            
        } else {
            
            if userLocation.latitude != 0 && userLocation.longitude != 0 {
                
                riderRequestActive = true
                self.callACuberLbl.setTitle("Cancel", for: [])
                
                let riderRequest = PFObject(className: "RiderRequest")
                
                riderRequest["username"] = PFUser.current()?.username
                
                riderRequest["email"] = PFUser.current()?.email
                
                print(userLocation.latitude)
                
                riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                
                riderRequest.saveInBackground(block: { (success, error) in
                    
                    if success {
                        
                        
                        
                    } else {
                        
                        self.riderRequestActive = false
                        self.callACuberLbl.setTitle("Call a cUBER", for: [])
                        self.displayAlert(title: "Could not call a cUBER", message: "Please try again!")
                        
                    }
                    
                })
                
            } else {
                
                self.displayAlert(title: "Could not call a cUBER", message: "Cannot detect your location.")
                
            }
        }
    }
    
    

    
    //--------------------------------------
    //MARK: - Override Function declaration
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callACuberLbl.isHidden = true
        callACuberLbl.layer.cornerRadius = 5.0
        
        map.layer.cornerRadius = 10.0
        map.layer.borderWidth = 1.5
        map.layer.borderColor = UIColor.lightGray.cgColor
        
        locationManeger.delegate = self
        locationManeger.desiredAccuracy = kCLLocationAccuracyBest
        locationManeger.requestWhenInUseAuthorization()
        locationManeger.startUpdatingLocation()
        
        let query = PFQuery(className: "RiderRequest")
        
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            if let riderRequests = objects {
                
                if riderRequests.count > 0 {
                    
                    self.riderRequestActive = true
                    self.callACuberLbl.setTitle("Cancel", for: [])
                }
            }
            
            self.callACuberLbl.isHidden = false
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "riderLogoutSegue" {
        
            locationManeger.stopUpdatingLocation()
            PFUser.logOut()
            
        }
    }
 

}
