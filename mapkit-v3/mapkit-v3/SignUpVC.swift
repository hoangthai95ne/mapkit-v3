//
//  SignUpVC.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/9/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTxt: TJTextField!
    @IBOutlet weak var phoneTxt: TJTextField!
    @IBOutlet weak var emailTxt: TJTextField!
    @IBOutlet weak var passwordTxt: TJTextField!
    
    let imagePicker = UIImagePickerController()
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TextField delegate
        nameTxt.delegate = self
        phoneTxt.delegate = self
        emailTxt.delegate = self
        passwordTxt.delegate = self
        
        imagePicker.delegate = self
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width / 2
        profileImageView.clipsToBounds = true
        
        //Set up ActivityView
        activity.center = self.view.center
        self.view.addSubview(activity)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //Set up ActivityView
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
    
    //Hide keyboard
    func hideKeyboard() {
        nameTxt.endEditing(true)
        phoneTxt.endEditing(true)
        emailTxt.endEditing(true)
        passwordTxt.endEditing(true)
    }
    
    //MARK: TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointMake(0, 200), animated: true)
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

    //MARK: Button Event
    @IBAction func changeProfileImageButtonPressed(sender: UIButton) {
        
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
    
    @IBAction func signUpButtonPressed(sender: MaterialButton) {
        
        hideKeyboard()
        
        let rootRef = Firebase(url: ROOT_REF)
        
        if let email = emailTxt.text, let pwd = passwordTxt.text, let phoneNumber = phoneTxt.text, let name = nameTxt.text {
            
            if email == "" || pwd == "" || name == "" || phoneNumber == "" {
                showErrorAlert("Error", msg: "Please enter all Text Field")
            } else {
                var checkEmail = true
                for char in Data.shared.usernameWithEmail(email).characters {
                    switch char {
                    case ".": checkEmail = false
                    case "#": checkEmail = false
                    case "$": checkEmail = false
                    case "[": checkEmail = false
                    case "]": checkEmail = false
                    case "@": checkEmail = false
                    default: break
                    }
                }
                
                if checkEmail {
                    self.startActivityView()
                    rootRef.createUser(email, password: pwd, withCompletionBlock: { error in 
                        if error != nil {
                            switch error.code {
                            case EMAIL_TAKEN: self.showErrorAlert("Error", msg: "Email is already signed up") 
                            case INVALID_EMAIL: self.showErrorAlert("Failed", msg: "Email address is invalid.")
                            default: break
                            }
                        } else {
                            let userDictionary = ["email": email, "pwd": pwd, "phoneNumber": phoneNumber, "name": name]
                            NSUserDefaults.standardUserDefaults().setObject(userDictionary, forKey: USER_DICTIONARY)
                            NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(self.profileImageView.image!), forKey: USER_PHOTO)
                            
                            //Save Person
                            let person = Person(email: email, name: name, phoneNumber: phoneNumber, locationCoordinate: CLLocationCoordinate2DMake(0, 0), profilePhoto: self.profileImageView.image!)
                            Data.shared.savePerson(person)
                            Data.shared.checkRegisterSuccess = true
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                        self.stopActivityView()
                    })
                } else {
                    self.showErrorAlert("Error", msg: "email must not contain '.' '#' '$' '[' ']' or '@'")
                    self.startActivityView()
                }
            }
        }
    }
    
    @IBAction func smallLoginButtonPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    
    
    
    
    
    
    
}
