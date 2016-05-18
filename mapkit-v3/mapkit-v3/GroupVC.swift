//
//  GroupVC.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/9/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import Firebase

class GroupVC: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activity.center = self.view.center
        self.view.addSubview(self.activity)
        
        //Any group is removed
        groupIsRemove(withBlock: { leaderUsername in
            let photo_username_Ref = Firebase(url: "\(ROOT_REF)/photos/group_\(leaderUsername)")
            photo_username_Ref.removeValue()
            if let index = Data.shared.loadedGroups.indexOf({ groupBlock -> Bool in
                if leaderUsername == groupBlock.leaderUsername {
                    return true
                } else {
                    return false
                }
            }) { Data.shared.loadedGroups.removeAtIndex(index) }
            Data.shared.checkDeleteGroupOnce = false
        })
        
        //First login
        
        
        
    }
    
    
    //Setup ActivityView
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("firstLogin") != nil {
            self.startActivityView()
        } else {
            let alert = UIAlertController(title: "So Glad!", message: "Now, choose an available Team\nOr Create your a one", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: {action in 
                self.startActivityView()
            })        
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
            
            //
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "firstLogin")
        }
        
        self.title = "Groups"
        
        self.navigationController?.navigationBarHidden = false
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(GroupVC.rightBarBtnPressed))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        var once = true
//        Data.shared.loadGroups(withBlock: { [weak self] loadedGroups in 
//            guard let strongSelf = self else { return }
//            strongSelf.tableView.reloadData()
//            if once {
//                strongSelf.stopActivityView()
//                once = false
//            }
//            
//            //Expect new group added
//            Data.shared.newGroupAddedHandle { newGroup in
//                Data.shared.loadedGroups.append(newGroup)
//                strongSelf.tableView.reloadData()
//            }
//        })
        
        Data.shared.loadGroups(withBlock: { [weak self] (groups: [Group]!) in
            guard let strongSelf = self else { return }
            strongSelf.tableView.reloadData()
            if once {
                strongSelf.stopActivityView()
                once = false
            }
            
            //Expect new group added
            Data.shared.newGroupAddedHandle { newGroup in
                Data.shared.loadedGroups.append(newGroup)
                strongSelf.tableView.reloadData()
            }
            
            //SOS
            strongSelf.receiveSOS()
            
        }) { self.tableView.reloadData() }
    }
    
    //MARK: SOS
    func receiveSOS() {
        
        var myGroups = [Group]()
        for group in Data.shared.loadedGroups {
            for memUsername in group.member_Usernames {
                if Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email) == memUsername {
                    myGroups.append(group)
                }
            }
        }
        let sos_ref = Firebase(url: "\(ROOT_REF)/sos")
        var username: String?
        var inGroup: String?
        var message: String?
        sos_ref.observeEventType(.ChildAdded) { [weak self](snapshot: FDataSnapshot!) in
            guard let strongSelf = self else { return }
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    switch snap.key {
                    case SOS_USERNAME: username = snap.value as? String
                    case SOS_GROUP: inGroup = snap.value as? String
                    case SOS_MESSAGE: message = snap.value as? String
                    default: break
                    }
                }
            }
            for group in myGroups {
                for memUsername in group.member_Usernames {
                    if username == memUsername {
                        //Not alert yourself
                        if Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email) != username {
                            let alert = UIAlertController(title: "SOS", message: "\(username!) in \(inGroup!) is \(message!), help him!!", preferredStyle: .Alert)
                            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(action)
                            strongSelf.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func groupIsRemove(withBlock block: (String! -> Void)!) {
        let group_Ref = Firebase(url: "\(ROOT_REF)/groups")
        group_Ref.observeEventType(.ChildRemoved) { (snapshot: FDataSnapshot!) in
            if Data.shared.checkDeleteGroupOnce {
                Data.shared.checkDeleteGroupOnce = false
                block(snapshot.key)
            }
        }
    }
    
    //Right Bar Button
    func rightBarBtnPressed() {
        
        self.performSegueWithIdentifier("newGroup", sender: nil)
        
    }
    
    //MARK: TableView Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.shared.loadedGroups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let groupAtIndexPath = Data.shared.loadedGroups[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as? MaterialCell {
            cell.configureCell(groupAtIndexPath)
            return cell
        } else {
            let cell = MaterialCell()
            cell.configureCell(groupAtIndexPath)
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailGroup" {
            Data.shared.choosenGroup = Data.shared.loadedGroups[(tableView.indexPathForSelectedRow?.row)!]
            Data.shared.membersInChoosenGroup = []
            Data.shared.annotationsOfMembersInChoosenGroup = []
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
