//
//  MemberCell.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/7/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {

//    @IBOutlet weak var memberPHoto: UIImageView!
//    @IBOutlet weak var memberNameLable: UILabel!
    
    @IBOutlet weak var memberPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        memberPhoto.layer.cornerRadius = memberPhoto.bounds.size.width / 2
        memberPhoto.clipsToBounds = true
        nameLabel.sizeToFit()
        
    }
    
    func configureCell(member: Person) {
        self.nameLabel.text = member.name
        self.memberPhoto.image = member.profilePhoto
    }

    

}
