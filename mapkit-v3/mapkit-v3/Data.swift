//
//  Data.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/10/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import CoreLocation
import MapKit

class Data {
        
    static var shared = Data()
    
    var rootRef = Firebase(url: ROOT_REF)
    var person_Ref = Firebase(url: "\(ROOT_REF)/persons")
    var photo_Ref = Firebase(url: "\(ROOT_REF)/photos")
    var group_Ref = Firebase(url: "\(ROOT_REF)/groups")
    
    var mySelfPerson = Person()
    
    var loadedGroups = [Group]()
    var choosenGroup = Group()
    
    var checkRegisterSuccess = false
    
    var membersInChoosenGroup = [Person]()
    var checkLoadMembersInChoosenGroupDone = false
    var annotationsOfMembersInChoosenGroup = [PinAnnotation]()
    
    var checkDelete = false
    var checkDeleteGroupOnce = false
    var checkSelectMemberOnList = false
    var checkShowGroupDestination = false
    var checkFirstLoggin = true
    var memberSelectedOnList = Person()
    
    
    func usernameWithEmail(email: String) -> String! {
        if email.containsString("@") {
            return email.componentsSeparatedByString("@")[0]
        } else {
            return email
        }
    }
    
    //Resize Image
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //MARK: Save person to Firebase
    func savePerson(person: Person) {

        let person_UID = person_Ref.childByAppendingPath("\(usernameWithEmail(person.email))")
        let personDict = [PERSON_NAME: person.name, PERSON_PHONE_NUMBER: person.phoneNumber, PERSON_LATITUDE: person.locationCoordinate.latitude, PERSON_LONGTITUDE: person.locationCoordinate.longitude]
        person_UID.setValue(personDict)
        
        person.profilePhoto = resizeImage(person.profilePhoto, newWidth: 200)
        let imageData: NSData = UIImagePNGRepresentation(person.profilePhoto)!
        let base64String = imageData.base64EncodedStringWithOptions([])
        let photo_UID = photo_Ref.childByAppendingPath("\(usernameWithEmail(person.email))")
        let photoDict = [PERSON_PROFILE_PHOTO: base64String]
        photo_UID.setValue(photoDict)
        
    }
    
    //MARK: UPDATE person location 
    func updatePersonLocation(person: Person) {
        
        let username = usernameWithEmail(person.email)
        let latitude = Firebase(url: "\(ROOT_REF)/persons/\(username)/\(PERSON_LATITUDE)")
        let longtitude = Firebase(url: "\(ROOT_REF)/persons/\(username)/\(PERSON_LONGTITUDE)")
        
        latitude.setValue(person.locationCoordinate.latitude)
        longtitude.setValue(person.locationCoordinate.longitude)
        
    }
    
    //MARK: Load person with email
    func personWithEmail(email: String, withBlock block: (Person! -> Void)!) {
        
        let person = Person()
        person.email = email
        let username = usernameWithEmail(email)
//        var checkStringDone = false
//        var checkImageDone = false
        
        person.profilePhoto = UIImage(named: "placeholder")!
        
        let user_Ref = Firebase(url: "\(ROOT_REF)/persons/\(username)")
        user_Ref.observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    switch snap.key {
                    case PERSON_LATITUDE: person.locationCoordinate.latitude = snap.value.doubleValue
                    case PERSON_LONGTITUDE: person.locationCoordinate.longitude = snap.value.doubleValue
                    case PERSON_NAME: person.name = snap.value as! String
                    case PERSON_PHONE_NUMBER: person.phoneNumber = snap.value as! String
                    default: break
                    }
                }
            }
            block(person)
//            checkStringDone = true
//            //
//            checkImageDone = true
//            if checkImageDone {
//                block(person)
//            }
        }
        
//        let user_photo_Ref = Firebase(url: "\(ROOT_REF)/photos/\(username)")
//        user_photo_Ref.observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) in
//            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
//                for snap in snapshots {
//                    if let base64EncodedString = snap.value as? String {
//                        if let base64Decoded = NSData(base64EncodedString: base64EncodedString, options:NSDataBase64DecodingOptions(rawValue: 0)) {
//                            person.profilePhoto = UIImage(data: base64Decoded)!
//                        }                        
//                    } 
//                }
//            }
//            
//            checkImageDone = true
//            if checkStringDone {
//                block(person)
//            }
//        }
    }
    
    func photoWithPerson(person: Person, image block: (UIImage -> Void)!) {
        let username = usernameWithEmail(person.email)
        let user_photo_Ref = Firebase(url: "\(ROOT_REF)/photos/\(username)")
        var image: UIImage?
        user_photo_Ref.observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let base64EncodedString = snap.value as? String {
                        if let base64Decoded = NSData(base64EncodedString: base64EncodedString, options:NSDataBase64DecodingOptions(rawValue: 0)) {
                            image = UIImage(data: base64Decoded)!
                        }                        
                    } 
                }
            }
            block(image!)
        }
    }
    
    //MARK: Save Group
    func saveGroup(group: Group) {
        
        group.photo = resizeImage(group.photo, newWidth: 200)
        let imageData: NSData = UIImagePNGRepresentation(group.photo)!
        let base64String = imageData.base64EncodedStringWithOptions([])
        
        let group_ID = group_Ref.childByAppendingPath("\(group.leaderUsername)")
        let groupDict = [GROUP_NAME: group.name, GROUP_DESTINATION_LATITUDE: group.destinationCoordinate.latitude, GROUP_DESTINATION_LONGTITUDE: group.destinationCoordinate.longitude, GROUP_DESCRIPTION: group.description]
        group_ID.setValue(groupDict)
        
        let member_Ref = group_ID.childByAppendingPath(GROUP_MEMBERS_USERNAMES)
        member_Ref.setValue(group.member_Usernames as [String])
        
        if group.member_Usernames.count == 1 {
            let photo_group = photo_Ref.childByAppendingPath("group_\(group.leaderUsername)")
            let photoDict = [GROUP_PROFILE_PHOTO: base64String]
            photo_group.setValue(photoDict)
        }
        
    }
    
    //MARK: Load Groups
    func loadGroups(withBlock block: ([Group]! -> Void)!, loadImageComplete Block: () -> ()) {
        
        self.group_Ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                self.loadedGroups = []
                for snap in snapshots {
                    if let groupDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        
                        //it's error when try retrieving member_uids as Array
                        let member_UIDs_Ref = Firebase(url: "\(ROOT_REF)/groups/\(key)/\(GROUP_MEMBERS_USERNAMES)")
                        member_UIDs_Ref.observeSingleEventOfType(.Value, withBlock: { snapshot1 in 
                            
                            var member_Usernames = [String]()
                            
                            
                            
                            if let snapshots1 = snapshot1.children.allObjects as? [FDataSnapshot] {
                                for snap1 in snapshots1 {
                                    member_Usernames.append(snap1.value as! String)
                                }
                                
                                //Create group and apend
                                let group = Group(name: groupDict[GROUP_NAME] as! String, leaderUsername: key, photo: UIImage(named: "placeholder")!, destinationCoordinate: CLLocationCoordinate2DMake((groupDict[GROUP_DESTINATION_LATITUDE]?.doubleValue)!, (groupDict[GROUP_DESTINATION_LONGTITUDE]?.doubleValue)!), description: groupDict[GROUP_DESCRIPTION] as! String, member_Usernames: member_Usernames)
                                self.loadedGroups.append(group)
                                if (snapshots.count == self.loadedGroups.count) {
                                    block(self.loadedGroups)
                                }
//                                block(self.loadedGroups)
                                
                                dispatch_async(dispatch_get_global_queue(0, 0), { 
                                    self.loadPhotoWithKey("group_\(key)", withBlock: { image in
                                        //old
                                        //                                    let group = Group(name: groupDict[GROUP_NAME] as! String, leaderUsername: key, photo: image, destinationCoordinate: CLLocationCoordinate2DMake((groupDict[GROUP_DESTINATION_LATITUDE]?.doubleValue)!, (groupDict[GROUP_DESTINATION_LONGTITUDE]?.doubleValue)!), description: groupDict[GROUP_DESCRIPTION] as! String, member_Usernames: member_Usernames)
                                        //                                    self.loadedGroups.append(group)
                                        //                                    if (snapshots.count == self.loadedGroups.count) {
                                        //                                        block(self.loadedGroups)
                                        //                                    }
                                        
                                        //new
                                        for i in 0 ..< self.loadedGroups.count {
                                            if self.loadedGroups[i].leaderUsername == key {
                                                self.loadedGroups[i].photo = image
                                            }
                                        }
                                        Block();
                                        
                                    })
                                })
                                
                                
                            }
                            
                        })
                    }
                }
            }
        })
    }
    
    //Load photo
    func loadPhotoWithKey(key: String, withBlock block: ((UIImage!) -> Void)!) {
        
        var image = UIImage()
        let photoWithKey_Ref = Firebase(url: "\(ROOT_REF)/photos/\(key)")
        photoWithKey_Ref.observeSingleEventOfType(.Value, withBlock: {snapshot in 
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    if let base64Decoded = NSData(base64EncodedString: snap.value as! String, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                        image = UIImage(data: base64Decoded)!
                    }
                }
                block(image)
            }
        })
    }

    //New group added
    func newGroupAddedHandle(withBlock block: (Group! -> Void)!) {
        photo_Ref.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            
            let newGroup = Group()
            let photoKey = snapshot.key as String
            var checkExist = false
            var checkBlockDone1 = false
            var checkBlockDone2 = false
            var checkBlockDone3 = false
            if photoKey.containsString("_") {
                newGroup.leaderUsername = photoKey.componentsSeparatedByString("_")[1]
                
                for loadedGroup in self.loadedGroups {
                    if loadedGroup.leaderUsername == newGroup.leaderUsername { checkExist = true }
                }
                
                if !checkExist {
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        for snap in snapshots {
                            if let base64Decoded = NSData(base64EncodedString: snap.value as! String, options: NSDataBase64DecodingOptions(rawValue: 0)) {
                                newGroup.photo = UIImage(data: base64Decoded)!
                            }
                        }
                        checkBlockDone1 = true
                        if checkBlockDone2 && checkBlockDone3 {
                            block(newGroup)
                            return;
                        }
                    }
                    let groupWithUsername_Ref = Firebase(url: "\(ROOT_REF)/groups/\(newGroup.leaderUsername)")
                    groupWithUsername_Ref.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) in
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            for snap in snapshots {
                                switch snap.key {
                                case GROUP_NAME: newGroup.name = snap.value as! String
                                case GROUP_DESCRIPTION: newGroup.description = snap.value as! String
                                case GROUP_DESTINATION_LATITUDE: newGroup.destinationCoordinate.latitude = snap.value.doubleValue
                                case GROUP_DESTINATION_LONGTITUDE: newGroup.destinationCoordinate.longitude = snap.value.doubleValue
                                default: break
                                }
                            }
                        }
                        checkBlockDone2 = true
                        if checkBlockDone1 && checkBlockDone3 {
                            block(newGroup)
                            return;
                        }
                    })
                    let member_usernames_Ref = Firebase(url: "\(ROOT_REF)/groups/\(newGroup.leaderUsername)/\(GROUP_MEMBERS_USERNAMES)")
                    member_usernames_Ref.observeSingleEventOfType(.Value, withBlock: { snapshot in 
                        var member_Usernames = [String]()
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            for snap1 in snapshots {
                                member_Usernames.append(snap1.value as! String)
                            }
                        }
                        newGroup.member_Usernames = member_Usernames
                        checkBlockDone3 = true
                        if checkBlockDone1 && checkBlockDone2 {
                            block(newGroup)
                            return;
                        }
                    })
                }
            }
        }
    }
    
    
    //MARK: New member Added
    func newMemberUsernameAddedOnGroup(group: Group, withBlock newMemberUsername:(String! -> Void)!) {
        let memberUsername_OnGroup_Ref = Firebase(url: "\(ROOT_REF)/groups/\(group.leaderUsername)/\(GROUP_MEMBERS_USERNAMES)")
        memberUsername_OnGroup_Ref.observeEventType(.ChildAdded) { (snapshot: FDataSnapshot!) in
            if let _ = group.member_Usernames.indexOf(snapshot.value as! String) {
                
            } else {
                newMemberUsername(snapshot.value as! String)
            }
        }
    }
    
    //MARK: member leave
    func memberLeftOnGroup(group: Group, withBlock block:(String! -> Void)!) {
        let memberUsername_OnGroup_Ref = Firebase(url: "\(ROOT_REF)/groups/\(group.leaderUsername)/\(GROUP_MEMBERS_USERNAMES)")
        memberUsername_OnGroup_Ref.observeEventType(.ChildRemoved) { (snapshot: FDataSnapshot!) in
            if (Data.shared.checkDelete) {
                return
            }
            if let _ = group.member_Usernames.indexOf(snapshot.value as! String) {
                block(snapshot.value as! String)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}