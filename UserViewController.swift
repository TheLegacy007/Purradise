//
//  UserViewController.swift
//  Purradise
//
//  Created by Nhat Truong on 4/17/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import Parse
import FBSDKLoginKit

class UserViewController: UIViewController {
    

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var cloudData: [PFObject]!
    var refreshControl:UIRefreshControl!
   
    
    @IBAction func onLogout(sender: UIBarButtonItem) {
        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            if error != nil {
                print("Error logging out Parse")
            } else {
                print("Success logging out Parse")
            }
        }
        // Logout with FB
        FBSDKLoginManager().logOut()
        performSegueWithIdentifier("toLoginSegue", sender: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = PFUser.currentUser()?.username
        
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(UserViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        refresh(self)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func refresh(sender: AnyObject){
        let username = PFUser.currentUser()!.username!
        print("username ", username)
        let query = PFQuery(className: "UserMedia")
        query.orderByDescending("createdAt")
        query.whereKey("authorName", equalTo: username)
        
        
        query.cachePolicy = .NetworkElseCache
        
        query.findObjectsInBackgroundWithBlock { (object:[PFObject]?, error:NSError?) -> Void in
            if object != nil && object?.count != 0{
                self.cloudData = object!
                print(object)
                self.tableView.reloadData()

            }
        }
        self.refreshControl.endRefreshing()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        refresh(self)
        userImage.layer.borderColor = UIColor.whiteColor().CGColor
        userImage.layer.masksToBounds = false
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        
        userImage.layer.borderWidth = 3.0
        userImage.contentMode = UIViewContentMode.ScaleAspectFill
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cloudData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        let userMedia = self.cloudData[indexPath.section] as PFObject
        
        cell.userCell = userMedia

        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 0.1
        cell.clipsToBounds = true

        
        return cell
        
    }
}

