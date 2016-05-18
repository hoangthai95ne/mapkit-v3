//
//  NewGroupVC.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/10/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import UIKit
import MapKit
import CoreLocation
import Firebase

class NewGroupVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var nameTxt: TJTextField!
    @IBOutlet weak var descriptrionTxt: TJTextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationTxt: TJTextField!
    
    var geoCoder = CLGeocoder()
    let imagePicker = UIImagePickerController()
    var groupDestination = CLLocationCoordinate2D()
    var group = Group()
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var foundPlace: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupImageView.layer.cornerRadius = groupImageView.bounds.size.width / 2
        groupImageView.clipsToBounds = true
        
        nameTxt.delegate = self
        destinationTxt.delegate = self
        descriptrionTxt.delegate = self
        
        
    }
    
    //Setup activityView
    func startActivityView() {
        activity.hidden = false
        activity.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopActivityView() {
        activity.hidden = true
        activity.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }

    
    //MARK: Button Event
    @IBAction func changeGroupPhotoButtonPressed(sender: UIButton) {
        imagePicker.delegate = self
        sender.setTitle("", forState: .Normal)
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let action0 = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in 
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let action1 = UIAlertAction(title: "Photo Library", style: .Default) { action in
            self.imagePicker.sourceType = .SavedPhotosAlbum
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: "Camera", style: .Default) { action in
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
                self.imagePicker.sourceType = .Camera
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            } else {
                self.showErrorAlert("Error", msg: "Camera is not available")
            }
        }
        
        alert.addAction(action0)
        alert.addAction(action1)
        alert.addAction(action2)
        
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, alert.view.bounds.size.width, alert.view.bounds.size.height)
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.groupImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    } 
    
    //MARK: TextField Delegate & geocoding
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        if textField == (self.destinationTxt)! {
            
            self.startActivityView()
            
            self.geoCoder.geocodeAddressString(self.destinationTxt.text!) { placemarks, error in
                
                if error != nil {
                    self.showErrorAlert("Error", msg: "Couldn't find location, try another")
                    self.stopActivityView()
                } else {
                    let foundPlace = placemarks![0]
                    self.updateMapView((foundPlace.location?.coordinate)!)
                    let foundPin = MKPointAnnotation()
                    foundPin.coordinate = (foundPlace.location?.coordinate)!
                    foundPin.title = foundPlace.description
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotation(foundPin)
                    
                    self.foundPlace = (foundPlace.location?.coordinate)!
                    
                    
                }
            }
        }
        return true
    }
    
    
    
    //MARK: Button Event
    @IBAction func submitButtonPressed(sender: MaterialButton) {
        
        if foundPlace != nil {
            
            //create Group
            self.group = Group(name: nameTxt.text!, 
                               leaderUsername: Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email), 
                               photo: groupImageView.image!, 
                               destinationCoordinate: foundPlace!, 
                               description: descriptrionTxt.text!, 
                               member_Usernames: [Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email)])
            
            var checkGroupIsAlreadyExist = false
            for _group in Data.shared.loadedGroups {
                if group.leaderUsername == _group.leaderUsername {
                    checkGroupIsAlreadyExist = true
                }
            }
            if checkGroupIsAlreadyExist {
                showErrorAlert("Error", msg: "You only can create 1 group")
            } else {
                Data.shared.saveGroup(group)
                let alert = UIAlertController(title: "Success", message: "You created a new group", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: {action in 
                    self.navigationController?.popViewControllerAnimated(true)
                })        
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            }
            
        } else {
            showErrorAlert("Error", msg: "Find a group destination")
        }
        
        
        
    }
    
    func updateMapView(coordinate: CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
        
        self.stopActivityView()
        
    }
    
    
    
    
    
}
