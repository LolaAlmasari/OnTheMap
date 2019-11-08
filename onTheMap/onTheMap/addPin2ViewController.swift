//
//  addPin2ViewController.swift
//  onTheMap
//
//  Created by Lola M on 7/21/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class addPin2ViewController: UIViewController {

    var locationCoordinates: CLLocationCoordinate2D!
    var locationName: String!
    
    @IBOutlet weak var link: UITextField!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var submet: UIButton!
    
    
    @IBAction func submet(_ sender: Any) {
        
        APIViewController.postStudentLocation(locationName: locationName, locationCoordinate: locationCoordinates, mediaURL: link.text ?? "") { (errorMessage) in
            DispatchQueue.main.async {
                if errorMessage != nil {
                    self.alert(title: "Error", message: "errorMessage")
                    return
                }
                self.parent!.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let annotation = MKPointAnnotation()
        annotation.title = locationName ?? ""
        annotation.coordinate = locationCoordinates!
        map.addAnnotation(annotation)
        
        let viewRegion = MKCoordinateRegion(center: locationCoordinates!, latitudinalMeters: 200, longitudinalMeters: 200)
        
        map.setRegion(viewRegion, animated: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

