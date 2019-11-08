//
//  ListVC.swift
//  onTheMap
//
//  Created by Lola M on 7/21/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class ListVC : UITableViewController {
    
    var studentsLocations: [studentLocation]! {
        return Global.shared.studentsLocations
    }
    
    @IBAction func reload(_ sender: Any) {
        APIViewController.getStudentLocation { (errorMessage) in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self.alert( title: "Error", message: errorMessage)
                    return
                }
                    self.tableView.reloadData()
                }
            }
        }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        APIViewController.deletesSession {(errorMessage) in
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
            reload(self)
        } else {
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return studentsLocations?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.imageView?.image = UIImage(named: "icon_pin")
        cell.textLabel?.text = studentsLocations[indexPath.row].firstName
        cell.detailTextLabel?.text = studentsLocations[indexPath.row].mediaURL
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = studentsLocations[indexPath.row]
        guard  let toOpen = studentLocation.mediaURL,
            let url = URL(string: toOpen)
            else {
                return
        }
        UIApplication.shared.open(url, options: [:])
    }
}

