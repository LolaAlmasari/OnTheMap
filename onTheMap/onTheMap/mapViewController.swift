//
//  mapViewController.swift
//  onTheMap
//
//  Created by Lola M on 7/21/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController, MKMapViewDelegate {
    
    var studentsLocations: [studentLocation]! {
        return Global.shared.studentsLocations
    }
    
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func reload(_ sender: Any) {
        APIViewController.getStudentLocation { (errorMessage) in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self.alert( title: "Error", message: errorMessage)
                    return
                }
                self.updateAnnotations()
            }
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        APIViewController.deletesSession { (errorMessage) in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self.alert( title: "Error", message: errorMessage)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if studentsLocations == nil {
            reload(self) }
        else {
            self.updateAnnotations()
        }
    }
    
    func updateAnnotations () {
        var annotations = [MKPointAnnotation] ()
        for studentLocation in studentsLocations {
            let lat = CLLocationDegrees(studentLocation.latitude ?? 0)
            let long = CLLocationDegrees(studentLocation.longtude ?? 0)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentLocation.firstName ?? ""
            let last = studentLocation.lastName ?? ""
            let mediaURL = studentLocation.mediaURL ?? ""
            
            let annotation = MKPointAnnotation ()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            if !map.annotations.contains(where: { $0.title == annotation.title }) {
                annotations.append(annotation)
            }
        }
        print("new annotation = ", annotations.count)
        map.addAnnotations(annotations)
        if annotations.count > 0 {
            map.selectAnnotation(annotations.first!, animated: true)
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pinId"
        
        var pinView = map.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.tintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView!
    }
    
    
    func mapView(_ map: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            guard let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen)
                else { return }
            app.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
