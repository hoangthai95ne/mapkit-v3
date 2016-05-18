//
//  SlideMenuVC.swift
//  mapkit-simple-v2
//
//  Created by HoangThai on 5/7/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class SlideMenuVC: SlideMenuController, SlideMenuControllerDelegate {

    
    var group = Group()
    
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Main"){
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewControllerWithIdentifier("Right"){
            self.rightViewController = controller
        }
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        self.addRightBarButtonWithImage(UIImage(named: "menu20")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Data.shared.choosenGroup.name
    }
}
