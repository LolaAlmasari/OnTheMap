//
//  studentLocationViewController.swift
//  onTheMap
//
//  Created by Lola M on 7/13/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

struct studentLocation: Codable {
    let createdAt: String?
    let firstName: String?
    let lastName: String?
    let latitude: Double?
    let longtude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectId: String?
    let uniqueKey: String?
    let updatedAt: String?
}
