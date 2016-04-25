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
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var cloudData: [PFObject]!
    
    @IBOutlet weak var collectionView: UICollectionView!
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
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
                self.collectionView.reloadData()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension UserViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Set the number of items in your collection view.
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let grid = collectionView.dequeueReusableCellWithReuseIdentifier("UserCollectionViewCell", forIndexPath: indexPath) as! UserCollectionViewCell
                let userMedia = self.cloudData[indexPath.item] as PFObject
                grid.userCell = userMedia
        
        return grid
    }
}