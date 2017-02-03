//
//  RiderLocationViewController.swift
//  Cuber-ios
//
//  Created by Pourpre on 2/3/17.
//  Copyright © 2017 Pourpre. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RiderLocationViewController: UIViewController, MKMapViewDelegate {

    //--------------------------------------
    //MARK: - variable declaration
    //--------------------------------------
    
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var requestUsername = ""
    
    //--------------------------------------
    //MARK: - IBOutlet declaration
    //--------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptRequestLbl: UIButton!
    
    
    //--------------------------------------
    //MARK: - IBAction declaration
    //--------------------------------------
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        
        dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func acceptRequestBtn(_ sender: UIButton) {
        
        let query = PFQuery(className: "RiderRequest")
        
        query.whereKey("username", equalTo: requestUsername)
        
        query.findObjectsInBackground { (objects, error) in
        
            if let riderRequests = objects {
            
                for riderRequest in riderRequests {
                
                    riderRequest["driverResponded"] = PFUser.current()?.username
                    
                    riderRequest["driverEmail"] = PFUser.current()?.email
                    
                    riderRequest.saveInBackground()
                    
                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                    
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                    
                        if let placemarks = placemarks {
                        
                            if placemarks.count > 0 {
                            
                                let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                                
                                let mapItem = MKMapItem(placemark: mKPlacemark)
                                
                                mapItem.name = self.requestUsername
                                
                                let launchOption = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                
                                mapItem.openInMaps(launchOptions: launchOption)
                                
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    //--------------------------------------
    //MARK: - Override Function declaration
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptRequestLbl.layer.cornerRadius = 5.0
        
        map.layer.cornerRadius = 10.0
        map.layer.borderWidth = 1.5
        map.layer.borderColor = UIColor.lightGray.cgColor
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestUsername
        map.addAnnotation(annotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "riderLocationLogoutSegue" {
            
            PFUser.logOut()
            
        }
    }
}
