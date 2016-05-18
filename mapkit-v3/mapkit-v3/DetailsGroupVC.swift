//
//  DetailsGroupVC.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/10/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import SlideMenuControllerSwift

class DetailsGroupVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var direction: MKDirections?
    var overLay = MKOverlay?()
    
    var getCurrentLocation = true
    
    var setRegionOnce = true
    var destinationAnnotation = PinAnnotation()    
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        if (locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization))) {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        
        
        //MARK: Load members and new Added members
        Data.shared.checkLoadMembersInChoosenGroupDone = false
        for memberUsername in Data.shared.choosenGroup.member_Usernames {
            Data.shared.personWithEmail(memberUsername, withBlock: { [weak self](person: Person!) in
                guard let strongSelf = self else { return }
                Data.shared.membersInChoosenGroup.append(person)
                Data.shared.photoWithPerson(person, image: { image in
                    person.profilePhoto = image
                })
                (strongSelf.slideMenuController()?.rightViewController as? MembersListVC)?.tableView.reloadData()
                if (Data.shared.choosenGroup.member_Usernames.count == Data.shared.membersInChoosenGroup.count) && !Data.shared.checkLoadMembersInChoosenGroupDone {
                    Data.shared.checkLoadMembersInChoosenGroupDone = true
                    
                    //Load members done, pin annotations to them
                    strongSelf.addAnnotationOfMembers(Data.shared.membersInChoosenGroup)
                    
                    //Update members location
                    strongSelf.updateMembersLocationFromGroup(Data.shared.choosenGroup)
                    
                    //Expect to new member added
                    Data.shared.newMemberUsernameAddedOnGroup(Data.shared.choosenGroup, withBlock: { newMemberUsername in
                        Data.shared.choosenGroup.member_Usernames.append(newMemberUsername)
                        Data.shared.personWithEmail(newMemberUsername, withBlock: { person in
                            Data.shared.membersInChoosenGroup.append(person)
                            
                            //Add new Annotation
                            let username = person.email
                            let pointAnnotation = PinAnnotation(person.locationCoordinate, withColor: UIColor.purpleColor(), withTitle: username, withSubTitle: person.phoneNumber)
                            Data.shared.annotationsOfMembersInChoosenGroup.append(pointAnnotation)
                            self?.mapView.addAnnotation(Data.shared.annotationsOfMembersInChoosenGroup.last!)
                        })
                    })
                    
                    //If someone leave group
                    Data.shared.memberLeftOnGroup(Data.shared.choosenGroup, withBlock: { leftMemberUsername in
                        if let index = Data.shared.choosenGroup.member_Usernames.indexOf(leftMemberUsername) {
                            Data.shared.choosenGroup.member_Usernames.removeAtIndex(index)
                        }
                        if let index = Data.shared.membersInChoosenGroup.indexOf({ memberBlock -> Bool in 
                            if memberBlock.email == leftMemberUsername { return true }
                            else { return false }
                        }) 
                        {
                            Data.shared.membersInChoosenGroup.removeAtIndex(index)
                        }
                        let ref = Firebase(url: "\(ROOT_REF)/groups/\(Data.shared.choosenGroup.leaderUsername)/\(GROUP_MEMBERS_USERNAMES)")
                        ref.setValue(Data.shared.choosenGroup.member_Usernames)
                        Data.shared.checkDelete = true
                    })
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //
        activity.center = mapView.center
        mapView.addSubview(activity)
    }
    
    //MARK: Setup ActivityView
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

    
    //MARK: update members location
    func updateMembersLocationFromGroup(group: Group) {
        
        let persons_Ref = Firebase(url: "\(ROOT_REF)/persons")
        persons_Ref.observeEventType(.ChildChanged) { (snapshot: FDataSnapshot!) in
            
            let key = snapshot.key
            for memUsername in group.member_Usernames {
                if memUsername == key {
                    let memberLite = Person()
                    memberLite.email = key
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        for snap in snapshots {
                            switch snap.key {
                            case PERSON_NAME: memberLite.name = snap.value as! String
                            case PERSON_LATITUDE: memberLite.locationCoordinate.latitude = snap.value.doubleValue
                            case PERSON_LONGTITUDE: memberLite.locationCoordinate.longitude = snap.value.doubleValue
                            default: break
                            }
                        }
                        for annotation in Data.shared.annotationsOfMembersInChoosenGroup {
                            if annotation.title == memberLite.name {
                                annotation.coordinate = memberLite.locationCoordinate
                            }
                        }
                    }
                } 
            }
        }
    }
    
    //MARK: Add annotations
    func addAnnotationOfMembers(members: [Person]) {
        for mem in members {
            //Not pin yourself
            if (mem.email != Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email)) {
                let pointAnnotation = PinAnnotation(mem.locationCoordinate, withColor: UIColor.purpleColor(), withTitle: mem.name, withSubTitle: mem.phoneNumber)
                pointAnnotation.image = mem.profilePhoto
                Data.shared.annotationsOfMembersInChoosenGroup.append(pointAnnotation)
            }
        }
        self.mapView.addAnnotations(Data.shared.annotationsOfMembersInChoosenGroup)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if setRegionOnce {
            setRegionOnce = false
            
            let location: CLLocation = locations[locations.count - 1]
            let theRegion: MKCoordinateRegion = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.01, 0.01))
            self.mapView.setRegion(theRegion, animated: true)
            
            destinationAnnotation = PinAnnotation(Data.shared.choosenGroup.destinationCoordinate, withColor: UIColor.redColor(), withTitle: "Destination", withSubTitle: Data.shared.choosenGroup.name)
            
            self.mapView.addAnnotation(destinationAnnotation)
            setMapRegion(Data.shared.choosenGroup.destinationCoordinate)
            self.mapView.selectAnnotation(destinationAnnotation, animated: true)
        }
        
        if !getCurrentLocation {
            setCurrentLocation()
        }
        
        rightWillClose()
    }
    
    
    
    //MARK: Button Event
    @IBAction func directionButtonPressed(sender: UIButton) {    
        if getCurrentLocation {
            setCurrentLocation()
            sender.setImage(UIImage(named: "getCurrentLocation"), forState: .Normal) 
            getCurrentLocation = false
        } else {
            getCurrentLocation = true
            sender.setImage(UIImage(named: "blueLocation"), forState: .Normal)
            self.mapSetRegion((locationManager.location?.coordinate)!, toPoint: Data.shared.choosenGroup.destinationCoordinate)
        }
    }
    
    @IBAction func infoButtonPressed(sender: UIButton) {
        showErrorAlert("Information", msg: "Project evolution written by\n" +
            "HoangThai\nTechmaster.vn")
    }

    @IBAction func sosButtonPressed(sender: UIButton) {
        let sos_ref = Firebase(url: "\(ROOT_REF)/sos")
        let autoKey_ref = sos_ref.childByAutoId()
        let alert = UIAlertController(title: "Messages", message: "", preferredStyle: .ActionSheet)
        let action1 = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let action2 = UIAlertAction(title: "I get stuck", style: .Default) { (action) in
            let sosDict = [SOS_USERNAME: Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email), SOS_GROUP: Data.shared.choosenGroup.name, SOS_MESSAGE: "Get stuck"]
            autoKey_ref.setValue(sosDict)
            let newAlert = UIAlertController(title: "SOS", message: "Sending SOS Messages.....", preferredStyle: .Alert)
            let stopAction = UIAlertAction(title: "Stop", style: .Default, handler: { (action) in
                autoKey_ref.removeValue()
            })
            newAlert.addAction(stopAction)
            self.presentViewController(newAlert, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(title: "I need a Doctor", style: .Default) { (action) in
            let sosDict = [SOS_USERNAME: Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email), SOS_GROUP: Data.shared.choosenGroup.name, SOS_MESSAGE: "Get Sick"]
            autoKey_ref.setValue(sosDict)
            let newAlert = UIAlertController(title: "SOS", message: "Sending SOS Messages.....", preferredStyle: .Alert)
            let stopAction = UIAlertAction(title: "Stop", style: .Default, handler: { (action) in
                autoKey_ref.removeValue()
            })
            newAlert.addAction(stopAction)
            self.presentViewController(newAlert, animated: true, completion: nil)
        }
        let action4 = UIAlertAction(title: "There's been an accident", style: .Default) { (action) in
            let sosDict = [SOS_USERNAME: Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email), SOS_GROUP: Data.shared.choosenGroup.name, SOS_MESSAGE: "There's been an accident"]
            autoKey_ref.setValue(sosDict)
            let newAlert = UIAlertController(title: "SOS", message: "Sending SOS Messages.....", preferredStyle: .Alert)
            let stopAction = UIAlertAction(title: "Stop", style: .Default, handler: { (action) in
                autoKey_ref.removeValue()
            })
            newAlert.addAction(stopAction)
            self.presentViewController(newAlert, animated: true, completion: nil)
        }
        let action5 = UIAlertAction(title: "I'm Lost", style: .Default) { (action) in
            let sosDict = [SOS_USERNAME: Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email), SOS_GROUP: Data.shared.choosenGroup.name, SOS_MESSAGE: "Lost"]
            autoKey_ref.setValue(sosDict)
            let newAlert = UIAlertController(title: "SOS", message: "Sending SOS Messages.....", preferredStyle: .Alert)
            let stopAction = UIAlertAction(title: "Stop", style: .Default, handler: { (action) in
                autoKey_ref.removeValue()
            })
            newAlert.addAction(stopAction)
            self.presentViewController(newAlert, animated: true, completion: nil)
        }
        let action6 = UIAlertAction(title: "Help", style: .Default) { (action) in
            let sosDict = [SOS_USERNAME: Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email), SOS_GROUP: Data.shared.choosenGroup.name, SOS_MESSAGE: "Help"]
            autoKey_ref.setValue(sosDict)
            let newAlert = UIAlertController(title: "SOS", message: "Sending SOS Messages.....", preferredStyle: .Alert)
            let stopAction = UIAlertAction(title: "Stop", style: .Default, handler: { (action) in
                autoKey_ref.removeValue()
            })
            newAlert.addAction(stopAction)
            self.presentViewController(newAlert, animated: true, completion: nil)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        alert.addAction(action5)
        alert.addAction(action6)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func rightWillClose() {
        if Data.shared.checkSelectMemberOnList {
            Data.shared.checkSelectMemberOnList = false
            for annotaion in Data.shared.annotationsOfMembersInChoosenGroup {
                
                let username = Data.shared.memberSelectedOnList.name
                if username == annotaion.title {
                    
                    let toPlace = MKPlacemark(coordinate: annotaion.coordinate, addressDictionary: nil)
                    self.setMapRegion(toPlace.coordinate)
                    self.mapView.selectAnnotation(annotaion, animated: true)
                }
            }
        }
        
        if Data.shared.checkShowGroupDestination {
            Data.shared.checkShowGroupDestination = false
            self.setMapRegion(Data.shared.choosenGroup.destinationCoordinate)
            self.mapView.selectAnnotation(destinationAnnotation, animated: true)
        }
    }
    
    func setCurrentLocation() {
        
        let coordinate = locationManager.location?.coordinate
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate!, span)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func setMapRegion(coordinate: CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)        
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
        
    } 
    
    //MARK: Route Path
    func routePath(fromPlace: MKPlacemark, toPlace: MKPlacemark) {
        
        startActivityView()
        
        let request = MKDirectionsRequest()
        
        let fromItemMap = MKMapItem(placemark: fromPlace)
        request.source = fromItemMap
        let toMapItem = MKMapItem(placemark: toPlace)
        request.destination = toMapItem
        
        direction = MKDirections(request: request)
        direction!.calculateDirectionsWithCompletionHandler { [weak self](response, error) in
            
            guard let strongSelf = self else { return }
            
            if error != nil {
                print(error?.code)
                if error?.code == 5 {
                    strongSelf.setMapRegion(toPlace.coordinate)
                    strongSelf.showErrorAlert("Error", msg: "Directions Not Available")
                    strongSelf.stopActivityView()
                }
                print(error)
            } else {
                strongSelf.mapSetRegion(fromPlace.coordinate, toPoint: toPlace.coordinate)
                strongSelf.showRoute(response!)
                strongSelf.stopActivityView()
            }
        }
    }
    
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes {
            self.overLay = route.polyline
            self.mapView.addOverlay(self.overLay!, level: .AboveRoads)
        }
    }
    
    func mapSetRegion(fromPoint: CLLocationCoordinate2D, toPoint: CLLocationCoordinate2D) {
        
        let centerPoint = CLLocationCoordinate2DMake((fromPoint.latitude + toPoint.latitude) / 2, (fromPoint.longitude + toPoint.longitude) / 2)
        var latitudeDelta = (fromPoint.latitude - toPoint.latitude) * 1.5
        if latitudeDelta < 0 { latitudeDelta = -1 * latitudeDelta }
        var longtitudeDelta = (fromPoint.longitude - toPoint.longitude) * 1.5
        if longtitudeDelta < 0 { longtitudeDelta = -1 * longtitudeDelta }
        let span = MKCoordinateSpanMake(latitudeDelta, longtitudeDelta)
        let region = MKCoordinateRegionMake(centerPoint, span)
        self.mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    //MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.isMemberOfClass(PinAnnotation) {
            var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier("pinAnnotation")
            if annotationView != nil {
                annotationView?.annotation = annotation
                return annotationView
            } else {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinAnnotation")
                annotationView?.canShowCallout = true
                
                (annotationView as? MKPinAnnotationView)?.pinTintColor = (annotation as? PinAnnotation)?.color
                (annotationView as? MKPinAnnotationView)?.animatesDrop = true
                
                let button = UIButton(frame: CGRectMake(0, 0, 50, 50))
                button.tag = 0
                button.backgroundColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1.0)
                let imageView = UIImageView(image: UIImage(named: "car50"))
                imageView.frame = CGRectMake(0, 0, 30, 30)
                imageView.center = button.center
                button.addSubview(imageView)
                
                annotationView?.leftCalloutAccessoryView = button
                
                let rightButton = UIButton(frame: CGRectMake(0, 0, 50, 50))
                rightButton.tag = 1
                rightButton.backgroundColor = UIColor.clearColor()
                let rightImageView = UIImageView(image: UIImage(named: "call128"))
                rightImageView.frame = CGRectMake(0, 0, 30, 30)
                rightImageView.center = button.center
                rightButton.addSubview(rightImageView)

                annotationView?.rightCalloutAccessoryView = rightButton
            }
            
            return annotationView
            
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if (view.annotation?.title)! == "Destination" {
            if (control as! UIButton).tag == 0 {
                let currentLocation = locationManager.location?.coordinate
                let fromPlace = MKPlacemark(coordinate: currentLocation!, addressDictionary: nil)
                let toPlace = MKPlacemark(coordinate: Data.shared.choosenGroup.destinationCoordinate, addressDictionary: nil)
                self.setMapRegion(toPlace.coordinate)
                self.mapView.selectAnnotation(destinationAnnotation, animated: true)
                if self.mapView.overlays.count != 0 {
                    self.mapView.removeOverlay(self.overLay!)
                    self.routePath(fromPlace, toPlace: toPlace)
                } else {
                    self.routePath(fromPlace, toPlace: toPlace)
                }
            } else {
                let alert = UIAlertController(title: "Message", message: "Call team leader: \(Data.shared.membersInChoosenGroup[0].name)\nWith number: \(Data.shared.membersInChoosenGroup[0].phoneNumber)", preferredStyle: .Alert)
                let action = UIAlertAction(title: "YES", style: .Default, handler: { action in
                    let phoneNumber: String = Data.shared.membersInChoosenGroup[0].phoneNumber
                    if let url = NSURL(string: "tel://\(phoneNumber)") {
                        UIApplication.sharedApplication().openURL(url)
                    }
                })
                let cancel = UIAlertAction(title: "NO", style: .Cancel, handler: { action in
                    //nil
                })
                alert.addAction(cancel)
                alert.addAction(action)
                presentViewController(alert, animated: true, completion: nil)
            }
        }
        else {
            for annotaion in Data.shared.annotationsOfMembersInChoosenGroup {
                if (view.annotation?.title)! == annotaion.title {
                    if (control as! UIButton).tag == 0 {
                        let currentLocation = locationManager.location?.coordinate
                        let fromPlace = MKPlacemark(coordinate: currentLocation!, addressDictionary: nil)
                        let toPlace = MKPlacemark(coordinate: annotaion.coordinate, addressDictionary: nil)
                        self.setMapRegion(toPlace.coordinate)
                        
                        self.mapView.selectAnnotation(annotaion, animated: true)
                        
                        if self.mapView.overlays.count != 0 {
                            self.mapView.removeOverlay(self.overLay!)
                            self.routePath(fromPlace, toPlace: toPlace)
                        } else {
                            self.routePath(fromPlace, toPlace: toPlace)
                        }
                    } else if (control as! UIButton).tag == 1 {
                        let phoneNumber: String = ((view.annotation?.subtitle)!)!
                        let username: String = ((view.annotation?.title)!)!
                        let alert = UIAlertController(title: "Message", message: "Call \(username)\nWith number: \(phoneNumber)", preferredStyle: .Alert)
                        let action = UIAlertAction(title: "YES", style: .Default, handler: { action in
                            if let url = NSURL(string: "tel://\(phoneNumber)") {
                                UIApplication.sharedApplication().openURL(url)
                            }
                        })
                        let cancel = UIAlertAction(title: "NO", style: .Cancel, handler: { action in
                            //nil
                        })
                        alert.addAction(cancel)
                        alert.addAction(action)
                        presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    

        
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
