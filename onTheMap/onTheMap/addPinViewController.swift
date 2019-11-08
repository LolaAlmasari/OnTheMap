//
//  addPinViewController.swift
//  onTheMap
//
//  Created by Lola M on 7/21/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

class addPinViewController: UIViewController {
    
    var locationCoordinates: CLLocationCoordinate2D!
    var locationName: String!
    
    @IBOutlet weak var wherelabel: UILabel!
    @IBOutlet weak var region: UITextField!
    @IBOutlet weak var find: UIButton!
    
    @IBAction func find(_ sender: Any) {
        guard let locationName = region.text?.trimmingCharacters(in: .whitespaces), !locationName.isEmpty
            else {
                let alert = UIAlertController (title: "Warning", message: "City Name Shouldn't Be Empty", preferredStyle: .alert)
                return
        }
        getCoordinateFrom(Location: locationName) {
            (locationCoordinates, Error) in
            DispatchQueue.main.async {
                if let error = Error {
                    self.alert(title: "error", message: "try different city name")
                    print(error.localizedDescription)
                    return
                }
                self.locationCoordinates = locationCoordinates
                self.locationName = locationName
                self.performSegue(withIdentifier: "showLastVC", sender: self)
            }
        }
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func getCoordinateFrom(Location: String, complition: @escaping(_ coordinate: CLLocationCoordinate2D?, _ Error: Error?) -> ()) {
        CLGeocoder().geocodeAddressString(Location) {
            placemarks, Error in
            complition(placemarks?.first?.location?.coordinate, Error)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLastVC" {
            let vc = segue.destination as! addPin2ViewController
            vc.locationCoordinates = locationCoordinates
            vc.locationName = locationName
        }
    }
}
