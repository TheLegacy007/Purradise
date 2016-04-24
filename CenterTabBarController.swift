//
//  CenterTabBarController.swift
//  Purradise
//
//  Created by Nhat Truong on 4/10/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit

class CenterTabBarController: UITabBarController {
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = uicolorFromHex(0xffd700)
        tabBar.barTintColor = UIColor.whiteColor()
        tabBar.translucent = false
        
        let centerButton = UIButton(type: .Custom)
        let buttonImage = UIImage(named: "paw")
        let numTabs = self.viewControllers!.count
        
        if buttonImage != nil{
            let screenWidth = UIScreen.mainScreen().bounds.size.width
            centerButton.frame = CGRectMake(0, 0, screenWidth / CGFloat(numTabs), self.tabBar.frame.size.height)
            centerButton.setImage(buttonImage, forState: .Normal)
            centerButton.tintColor = UIColor.whiteColor()
            centerButton.backgroundColor = UIColor(red: 18/255.0, green: 86/255.0, blue: 136/255.0, alpha: 1.0)
            
            centerButton.center = self.tabBar.center
            
            centerButton.addTarget(self, action: #selector(CenterTabBarController.showCamera(_:)), forControlEvents: .TouchUpInside)
            
            self.view.addSubview(centerButton)
        }
    }
    
    func showCamera(sender: UIButton!){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let cameraPicker = mainStoryboard.instantiateViewControllerWithIdentifier("CameraPopup")
        self.presentViewController(cameraPicker, animated: false, completion: nil)
    }
}
