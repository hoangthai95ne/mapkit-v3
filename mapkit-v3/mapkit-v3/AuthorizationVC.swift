//
//  AuthorizationVC.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/9/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import Firebase

class AuthorizationVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addPicButton: UIButton!
    @IBOutlet weak var emailTxt: TJTextField!
    @IBOutlet weak var passwordTxt: TJTextField!
    
    var locationManager = CLLocationManager()
    
    let imagePicker = UIImagePickerController()
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var canUpdateLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width / 2
        profileImageView.clipsToBounds = true
        
        emailTxt.delegate = self
        passwordTxt.delegate = self
        
        //Set up ActivityView
        activity.center = self.view.center
        self.view.addSubview(activity)
        
        //
        locationManager.delegate = self
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        setUserFromLastSection()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        
        if Data.shared.checkRegisterSuccess {
            Data.shared.checkRegisterSuccess = false
            setUserFromLastSection()
        }
    }
    
    func setUserFromLastSection() {
        if let userDictionary = NSUserDefaults.standardUserDefaults().objectForKey(USER_DICTIONARY) as? Dictionary<String, String>{
            addPicButton.setTitle("", forState: .Normal) 
            emailTxt.text = userDictionary["email"]
            passwordTxt.text = userDictionary["pwd"]
            let imageData = NSUserDefaults.standardUserDefaults().objectForKey(USER_PHOTO)
            profileImageView.image = UIImage(data: imageData as! NSData)
        }
    }
    
    //    Call when navigationBar is hidden
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if canUpdateLocation {
            Data.shared.mySelfPerson.locationCoordinate = (locationManager.location?.coordinate)!
            Data.shared.updatePersonLocation(Data.shared.mySelfPerson)
        }
        
    }
    
    
    
    
    //MARK: Button Event
    @IBAction func authorization(sender: MaterialButton) {
        
        startActivityView()
        hideKeyboard()
        
        if let email = emailTxt.text, let pwd = passwordTxt.text {
            
            Data.shared.rootRef.authUser(email, password: pwd, withCompletionBlock: { error, authData in 
                
                if error != nil {
                    switch (error.code) {
                    case INVALID_EMAIL: self.showErrorAlert("Failed", msg: "Email address is invalid.")
                    case INVALID_USER: self.showErrorAlert("Failed", msg: "The username does not exist.")
                    case INVALID_PASSWORD: self.showErrorAlert("Failed", msg: "The password is incorrect.")
                    default: break
                    }
                    self.stopActivityView()
                } else {
                    
                    //Take person info from email
                    Data.shared.personWithEmail(email, withBlock: { [weak self] person in
                        
                        guard let strongSelf = self else { return }
                        
                        Data.shared.mySelfPerson = person
                        strongSelf.canUpdateLocation = true
                        
                        //Update Avata
                        let ref = Firebase(url: "\(ROOT_REF)/photos/\(Data.shared.usernameWithEmail(person.email))")
                        let image = Data.shared.resizeImage(strongSelf.profileImageView.image!, newWidth: 200)
                        let imageData: NSData = UIImagePNGRepresentation(image)!
                        let base64String = imageData.base64EncodedStringWithOptions([])
                        let photoDict = [PERSON_PROFILE_PHOTO: base64String]
                        ref.setValue(photoDict)
                        })
                    
                    //user for next section
                    let lastImage = self.profileImageView.image
                    NSUserDefaults.standardUserDefaults().setObject(email, forKey: "email")
                    NSUserDefaults.standardUserDefaults().setObject(pwd, forKey: "pwd")
                    NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(lastImage!), forKey: USER_PHOTO)
                    
                    self.stopActivityView()
                    
                    self.performSegueWithIdentifier("showGroup", sender: nil)
                    
                }
            })
        }
        
    }
    
    @IBAction func addPicButtonPressed(sender: UIButton) {
        
        hideKeyboard()
        
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
        
        self.profileImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func tutorialsButtonPressed(sender: UIButton) {
//        self.navigationController?.popViewControllerAnimated(true)
    }

    //Hide keyboard
    func hideKeyboard() {
        emailTxt.endEditing(true)
        passwordTxt.endEditing(true)
    }
    
    //MARK: TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 100), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
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
    
    
    
}
