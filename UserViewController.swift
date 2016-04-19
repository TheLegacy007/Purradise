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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
