//
//  DriverViewController.swift
//  Cuber-ios
//
//  Created by Pourpre on 2/3/17.
//  Copyright © 2017 Pourpre. All rights reserved.
//

import UIKit
import Parse

class DriverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    //--------------------------------------
    //MARK: - variable declaration
    //--------------------------------------
    
    var locationManager = CLLocationManager()
    var requestUsernames = [String]()
    var requestLocations = [CLLocationCoordinate2D]()
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    
    //--------------------------------------
    //MARK: - IBOutlet declaration
    //--------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //--------------------------------------
    //MARK: - Function declaration
    //--------------------------------------
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestUsernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as UITableViewCell
        
        //Find distance between userLocation and requestLocations
        
        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let riderCLLocation = CLLocation(latitude: requestLocations[indexPath.row].latitude, longitude: requestLocations[indexPath.row].longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        
        let roundedDistance = round(distance * 100) / 100
        
        cell.textLabel?.text = requestUsernames[indexPath.row] + " - \(roundedDistance)km away"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showRiderLocationVCSegue", sender: indexPath.row)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            
            userLocation = location
            
            let query1 = PFQuery(className: "RiderRequest")
            query1.whereKeyDoesNotExist("driverResponded")
            
            let query2 = PFQuery(className: "RiderRequest")
            query2.whereKey("driverResponded", equalTo: "")

            
            let query = PFQuery.orQuery(withSubqueries: [query1, query2])
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            query.limit = 10
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                if let riderRequests = objects {
                    
                    self.requestUsernames.removeAll()
                    self.requestLocations.removeAll()
                    
                    for riderRequest in riderRequests {
                        
                        if let username = riderRequest["username"] as? String {
                            
                                self.requestUsernames.append(username)
                                
                                self.requestLocations.append(CLLocationCoordinate2D(latitude: (riderRequest["location"] as AnyObject).latitude, longitude: (riderRequest["location"] as AnyObject).longitude))

                        }
                    }
                    
                    self.tableView.reloadData()
                    
                }
            })
        }
        
    }
    
    //--------------------------------------
    //MARK: - Override Function declaration
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "driverLogoutSegue" {

            locationManager.stopUpdatingLocation()
            PFUser.logOut()
            
        } else if segue.identifier == "showRiderLocationVCSegue" {
            
            
            if let destination = segue.destination as? RiderLocationViewController {
                
                if let row = tableView.indexPathForSelectedRow?.row {
                    
                        destination.requestLocation = requestLocations[row]
                    
                        destination.requestUsername = requestUsernames[row]
                
                }
            }
        }
    }

}
