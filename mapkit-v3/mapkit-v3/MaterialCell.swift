//
//  MaterialCell.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/2/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit

class MaterialCell: UITableViewCell {


    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        
    }

    func configureCell(group: Group) {
        
        self.nameLabel.text = group.name
        self.descLabel.text = group.description
        self.profilePhoto.image = group.photo
        
    }

}
