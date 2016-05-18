//
//  MembersListVC.swift
//  mapkit-v3
//
//  Created by HoangThai on 5/10/16.
//  Copyright © 2016 techmaster. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import Firebase

class MembersListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SlideMenuControllerDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupPhoto: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var joinGroupButton: UIButton!
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.slideMenuController()?.delegate = self
        
        groupPhoto.layer.cornerRadius = groupPhoto.bounds.size.width / 2
        groupPhoto.clipsToBounds = true
        groupPhoto.image = Data.shared.choosenGroup.photo
        groupPhoto.contentMode = .ScaleAspectFill
        
        editView.layer.cornerRadius = editView.bounds.size.width / 2
        editView.clipsToBounds = true
        
        groupName.text = Data.shared.choosenGroup.name
        groupName.sizeToFit()

    }
    
    //Setup ActivityView
    func startActivityView() {
        activity.hidden = false
        activity.startAnimating()
//        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func stopActivityView() {
        activity.hidden = true
        activity.stopAnimating()
//        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //
        self.activity.center = self.view.center
        self.view.addSubview(self.activity)
    }
    
    //MARK: Slide Menu Controller Delegate
    func rightWillOpen() {
        //Your are leader
        startActivityView()
        self.tableView.reloadData()
        if self.tableView.numberOfRowsInSection(1) >= 1 {
            stopActivityView()
        }
        if Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email) == Data.shared.choosenGroup.leaderUsername {
            changeButtonType("REMOVE GROUP", color: UIColor.redColor())
        } else {
            var checkInGroup = false
            for username in Data.shared.choosenGroup.member_Usernames {
                if Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email) == username {
                    checkInGroup = true
                }
            }
            //Your in group
            if checkInGroup {
                changeButtonType("LEAVE GROUP", color: UIColor.redColor())
            } else {
                changeButtonType("JOIN GROUP", color: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1))
            }
        }
    }
    
    func rightDidOpen() {
        self.tableView.reloadData()
    }
    
    //MARK: Join Group
    func joinGroup() {
        let newMember_Ref = Firebase(url: "\(ROOT_REF)/groups/\(Data.shared.choosenGroup.leaderUsername)/\(GROUP_MEMBERS_USERNAMES)")
        newMember_Ref.updateChildValues(["\(Data.shared.choosenGroup.member_Usernames.count)": "\(Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email))"])
        self.slideMenuController()?.closeRight()
    }
    
    //MARK: Leave Group
    func leaveGroup() {
        for i in 0..<Data.shared.choosenGroup.member_Usernames.count {
            if (Data.shared.usernameWithEmail(Data.shared.mySelfPerson.email)) == Data.shared.choosenGroup.member_Usernames[i] {
                let members_username_ref = Firebase(url: "\(ROOT_REF)/groups/\(Data.shared.choosenGroup.leaderUsername)/\(GROUP_MEMBERS_USERNAMES)/\(i)")
                members_username_ref.removeValue()
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Delete Group
    func deleteGroup() {
        Data.shared.checkDeleteGroupOnce = true
        let group_username_Ref = Firebase(url: "\(ROOT_REF)/groups/\(Data.shared.choosenGroup.leaderUsername)")
        group_username_Ref.removeValue()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: TableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.shared.membersInChoosenGroup.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let member = Data.shared.membersInChoosenGroup[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("memberCell") as? MemberCell {
            cell.configureCell(member) 
            return cell
        } else {
            let cell = MemberCell()
            cell.configureCell(member)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let slideMenuController = self.slideMenuController() {
            Data.shared.checkSelectMemberOnList = true
            Data.shared.memberSelectedOnList = Data.shared.membersInChoosenGroup[indexPath.row]
            slideMenuController.closeRight()
        }
    }
    
    //MARK: Button Event
    @IBAction func changeGroupPhotoButtonPressed(sender: UIButton) {
        if let slideMenuController = self.slideMenuController() {
            Data.shared.checkShowGroupDestination = true
            slideMenuController.closeRight()
        }
    }
    
    func changeButtonType(title: String, color: UIColor) {
        joinGroupButton.setTitle(title, forState: .Normal)
        joinGroupButton.backgroundColor = color
    }
    
    @IBAction func JoinGroupButtonPressed(sender: UIButton) {
        if sender.titleForState(.Normal) == "JOIN GROUP" {
            Data.shared.checkDelete = false
            joinGroup()
            changeButtonType("LEAVE GROUP", color: UIColor.redColor())
        } else if sender.titleForState(.Normal) == "LEAVE GROUP" {
            leaveGroup()
        } else if sender.titleForState(.Normal) == "REMOVE GROUP" {
            deleteGroup()
        }
    }
    
    
}
