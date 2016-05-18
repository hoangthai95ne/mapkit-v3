//
//  Group.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/10/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class Group {
    
    var leaderUsername: String = ""
    var name: String = ""
    var photo: UIImage = UIImage()
    var destinationCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var description: String = ""
    var member_Usernames: [String] = []
    
    init() {
        leaderUsername = ""
        name = ""
        photo = UIImage()
        destinationCoordinate = CLLocationCoordinate2D()
        description = ""
        member_Usernames = []
    }
    
    init(name: String, leaderUsername: String, photo: UIImage, destinationCoordinate: CLLocationCoordinate2D, description: String, member_Usernames: [String]) {
        self.name = name
        self.leaderUsername = leaderUsername
        self.photo = photo
        self.destinationCoordinate = destinationCoordinate
        self.description = description
        self.member_Usernames = member_Usernames
    }
}