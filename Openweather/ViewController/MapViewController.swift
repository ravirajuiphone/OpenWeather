//
//  MapViewController.swift
//  Openweather
//
//  Created by Rakesh Tatekonda on 23/03/2018.
//  Copyright © 2018 Raviraju Vysyaraju. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!
    let annotation = MKPointAnnotation()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        if let latitude = LocationManager.sharedInstance.lastKnownLocation?.latitude{
            mapview.region.center.latitude = latitude
        }
        if let longitude = LocationManager.sharedInstance.lastKnownLocation?.longitude{
            mapview.region.center.longitude = longitude
        }
        if let location = LocationManager.sharedInstance.lastKnownLocation{
            annotation.coordinate = location
            mapview.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.0275, 0.0275)
            let region = MKCoordinateRegionMake(location, span)

            mapview.setRegion(region, animated: false)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            //pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        if let annotationView = pinView {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named:"pinIcon")!
        }
        return pinView
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
