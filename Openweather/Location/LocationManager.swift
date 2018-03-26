//
//  LocationManager.swift
//  Openweather
//
//  Created by Raviraju Vysyaraju on 22/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject,CLLocationManagerDelegate {
    static let sharedInstance = LocationManager()
    var locationManagerObj: CLLocationManager!
    var locationStatus : NSString = "Not Started"
    var lastKnownLocation : CLLocationCoordinate2D?
    var postalCode: String? = nil
    // Location Manager helper stuff
    private override init() {
    }
    func initLocationManager(locManager: CLLocationManager = CLLocationManager()) {
        self.locationManagerObj = locManager
        locationManagerObj.delegate = self
        locationManagerObj.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManagerObj.requestWhenInUseAuthorization()
        locationManagerObj.distanceFilter = 500
        locationManagerObj.startUpdatingLocation()
    }
    
    func isLocationServicesEnabled() -> Bool {
        var isLocationEnabled = Bool()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case CLAuthorizationStatus.restricted:
                isLocationEnabled = false
            break
            case CLAuthorizationStatus.denied:
                isLocationEnabled = false
                break
            case CLAuthorizationStatus.notDetermined:
                isLocationEnabled = false
                break
            default:
                isLocationEnabled = true
            }
        }
        return isLocationEnabled
    }
    // MARK: -
    // MARK: CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        
        self.lastKnownLocation = coord
        print(coord.latitude)
        print(coord.longitude)
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeatherNotification"), object: nil)
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, error) in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                self.displayLocationInfo(pm)
                print (self.displayLocationInfo(pm))
            } else {
                print("Problem with the data received from geocoder")
            }
        }

        locationManagerObj.stopUpdatingLocation()
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            self.locationManagerObj.stopUpdatingLocation()
            //let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            self.postalCode = containsPlacemark.postalCode ?? nil
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            
            NSLog("Location to Allowed")
            // Start location services
            locationManagerObj.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print(error)
    }
}

