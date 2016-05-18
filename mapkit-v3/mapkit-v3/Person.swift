//
//  Person.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/10/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class Person {
    
    var email: String = ""
    var name: String = ""
    var phoneNumber: String = ""
    var locationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var profilePhoto: UIImage = UIImage()
    
    init() {
        self.email = ""
        self.name = ""
        self.phoneNumber = ""
        self.locationCoordinate = CLLocationCoordinate2D()
        profilePhoto = UIImage()
    }
    
    init(email: String, name: String, phoneNumber: String, locationCoordinate: CLLocationCoordinate2D, profilePhoto: UIImage) {
        self.email = email
        self.name = name
        self.locationCoordinate = locationCoordinate
        self.phoneNumber = phoneNumber
        self.profilePhoto = profilePhoto
    }
    
}