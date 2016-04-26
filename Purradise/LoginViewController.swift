//
//  LoginViewController.swift
//  Purradise
//
//  Created by Nhat Truong on 4/9/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKLoginKit
import Parse

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, FBSDKSharingDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var makeupButtons: [UIButton]!
    
    
    @IBAction func onTapRegister(sender: UIButton) {
        let user: PFUser = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        if(user.username == "" && user.password == "") {
            self.alertShow("Please enter user name and password")
            return
        }
        
        user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if(error == nil) {
                print("Register success")
                let alertVC = UIAlertController(
                    title: "Welcome to Purradise!",
                    message: "We hope you and your pets love Purradise.",
                    preferredStyle: .Alert)
                let okAction = UIAlertAction(
                    title: "OK",
                    style:.Default,
                    handler: nil)
                alertVC.addAction(okAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
                
                // Perhaps move to the HomeViewController (TabBarController) instead of Login is pressed.
            }
            else {
                // Get the localized text desctiption and show to the user - TO BE IMPROVED.
                self.alertShow(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func onTapLogin(sender: UIButton) {
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) { (user : PFUser?, error: NSError?) -> Void in
            if(error == nil){
                print("Login success")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewControllerWithIdentifier("TabBarController")
                self.presentViewController(vc, animated: true, completion: nil)
            }
            else {
                self.alertShow(error!.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView = UIImageView(frame: CGRectMake(0, 0, 100, 100))
//        imageView.center = CGPoint(x: view.center.x, y: 150)
//        imageView.image = UIImage(named: "fb-art")
//        view.addSubview(imageView)
//        
//        label = UILabel(frame: CGRectMake(0,0,200,30))
//        label.center = CGPoint(x: view.center.x, y: 250)
//        label.text = "Not Logged In"
//        label.textAlignment = NSTextAlignment.Center
//        view.addSubview(label)
        
        // Make up
        for eachButton in makeupButtons {
            eachButton.layer.cornerRadius = 5
            eachButton.layer.borderWidth = 0.5
            eachButton.layer.borderColor = eachButton.tintColor.CGColor
        }
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = CGPoint(x: view.center.x, y: 450)
        loginButton.delegate = self
        loginButton.publishPermissions = ["publish_actions"]
        view.addSubview(loginButton)
        
        
        //getFacebookUserInfo()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("didCompleteWithResult")
        
        getFacebookUserInfo()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton?) {
        print("loginButtonDidLogOut")
        //imageView.image = UIImage(named: "fb-art.jpg")
        //label.text = "Not Logged In"
    }
    
    func getFacebookUserInfo() {
        if(FBSDKAccessToken.currentAccessToken() != nil){
        //print permissions, such as public_profile
            print(FBSDKAccessToken.currentAccessToken().permissions)
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                
                self.performSegueWithIdentifier("LoginToHomeSegue", sender: self)
                //self.label.text = result.valueForKey("name") as? String
                
//                let FBid = result.valueForKey("id") as? String
//                
//                let url = NSURL(string: "https://graph.facebook.com/\(FBid!)/picture?type=large&return_ssl_resources=1")
//                self.imageView.image = UIImage(data: NSData(contentsOfURL: url!)!)
            })
        } else {

        }
    }
    
    
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("didCompleteWithResults")
        alertShow("Photo")
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print("didFailWithError")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
    
    func alertShow(typeStr: String) {
        let alertController = UIAlertController(title: "", message: typeStr+" Posted!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}