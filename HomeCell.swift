//
//  HomeCell.swift
//  Purradise
//
//  Created by Nhat Truong on 4/9/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import Parse
import Social
import ImageSlideshow
import FBSDKShareKit

protocol MapDelegate {
    func mapController(didGetMapData data: [String:AnyObject])
}

class HomeCell: UITableViewCell {
    
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var subdescriptionLabel: UILabel!
    @IBOutlet weak var tiltleSubView: UIView!
    @IBOutlet weak var backView: UIView!
    var trayOriginalCenter: CGPoint!
    var trayCenterWhenClosed: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    
    @IBOutlet weak var showDescription: UIImageView!
    @IBOutlet weak var trayView: UIView!
    
    @IBAction func onMapButton(sender: UIButton) {
        var data = [String:AnyObject]()
        data["geoLocation"] = geoLocation
        data["petImage"] = petImage
        
        self.openMap(data)


    }
    
    func openMap(data: [String:AnyObject]) {
        self.delegate?.mapController(didGetMapData: data)
    }
    
    
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    
    var transitionDelegate: ZoomAnimatedTransitioningDelegate?
    
    var geoLocation: PFGeoPoint!
    var petImage: UIImage!
   
    var delegate: MapDelegate!

    static let dateFormatter = NSDateFormatter()
    
    var imageArray: [UIImage] = []
    
    var homeCell: PFObject! {
        didSet {
            if let homeCell = homeCell {
                
                backView.hidden = true
                backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)

                
                slideshow.backgroundColor = UIColor.whiteColor()
                slideshow.slideshowInterval = 5.0
                slideshow.pageControlPosition = PageControlPosition.InsideScrollView
                slideshow.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor();
                slideshow.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor();
                
//                print(homeCell["likesCount"])
                let like = homeCell["likesCount"] as! Int
                if  like == 0 {
                    likeButton.setImage(UIImage(named: "like"), forState: .Normal)
                } else {
                    likeButton.setImage(UIImage(named: "like-on"), forState: .Normal)
                }
                
                likesCountLabel.text = String(homeCell["likesCount"])
                geoLocation = homeCell["geoLocation"] as! PFGeoPoint
                descriptionLabel.text = homeCell["description"] as? String
                let location = homeCell["location"] as! String
                let type = homeCell["objectName"] as! String
                let action = homeCell["requiredAction"] as! String

                let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
                content.contentURL = NSURL(string: "<INSERT STRING HERE>")
                content.contentTitle = subdescriptionLabel.text
                content.contentDescription = homeCell["description"] as? String
                content.imageURL = NSURL(string: "<INSERT STRING HERE>")
                
                let shareButton : FBSDKShareButton = FBSDKShareButton()
                //        shareButton.setImage(UIImage(named: "share"), forState: .Normal)
                //        shareButton.setTitle(nil, forState: .Normal)
                shareButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
                shareButton.center = CGPoint(x: 330, y: 16)
                shareButton.layer.masksToBounds = false
                shareButton.layer.cornerRadius = shareButton.frame.height/2
                shareButton.clipsToBounds = true
                shareButton.layer.borderColor = UIColor.whiteColor().CGColor
                shareButton.layer.borderWidth = 0.5
                shareButton.contentMode = UIViewContentMode.ScaleAspectFill
                print(shareButton.currentTitle)
                shareButton.setTitle(nil, forState: .Normal)
                shareButton.shareContent = content
                trayView.addSubview(shareButton)
                
                switch type {
                    case "Dog":
                        switch action {
                        case "Rescue": subdescriptionLabel.text = "A cute puppy needs to be rescued at \(location)"
                        case "Adopt": subdescriptionLabel.text = "A cute puppy needs a shelter at \(location)"
                        case "Lo&Fo": subdescriptionLabel.text = "A cute puppy is missing at \(location)"
                        case "Other": subdescriptionLabel.text = "A cute puppy needs your help at \(location)"
                        default: break

                        }
                    case "Cat":
                        switch action {
                        case "Rescue": subdescriptionLabel.text = "A cute kitty needs to be rescued at \(location)"
                        case "Adopt": subdescriptionLabel.text = "A cute kitty needs a shelter at \(location)"
                        case "Lo&Fo": subdescriptionLabel.text = "A cute kitty is missing at \(location)"
                        case "Other": subdescriptionLabel.text = "A cute kitty needs your help at \(location)"
                        default: break
                            
                        }

                    case "Other": subdescriptionLabel.text = "A cute animal needs your help at \(location)"
                default: break
                }
                
                // Support old database
                if let media = homeCell["media"] {
                    media.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) -> Void in
                        if let data = data {
                            self.slideshow.setImageInputs([ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!),ImageSource(image: UIImage(data: data)!)])
                            self.petImage = UIImage(data: data)
                        }
                    })
                }
                
                // WARNING: DIRTY CODES BELOW - SHOULD USE RECURSIVE!
                imageArray = [UIImage(named: "user.png")!, UIImage(named: "user.png")!, UIImage(named: "user.png")!, UIImage(named: "user.png")!, UIImage(named: "user.png")!]   // Make sure the array is always available for async-reading response.
                if let media0 = homeCell["image0"] {
                    print(media0)
                    media0.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                        if error == nil {
                            if let data = data {
                                self.imageArray[0] = (UIImage(data: data)!)
                                self.slideshow.setImageInputs([ImageSource(image: self.imageArray[0])])
                                self.petImage = UIImage(data: data)
                                print("Image 1")
                            }
                            if let media1 = homeCell["image1"] {
                                print(media1)
                                media1.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                                    if error == nil {
                                        if let data = data {
                                            self.imageArray[1] = (UIImage(data: data)!)
                                            self.slideshow.setImageInputs([ImageSource(image: self.imageArray[0]), ImageSource(image: self.imageArray[1])])
                                            print("Image 2")
                                        }
                                        if let media2 = homeCell["image2"] {
                                            print(media2)
                                            media2.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                                                if error == nil {
                                                    if let data = data {
                                                        self.imageArray[2] = (UIImage(data: data)!)
                                                        self.slideshow.setImageInputs([ImageSource(image: self.imageArray[0]), ImageSource(image: self.imageArray[1]), ImageSource(image: self.imageArray[2])])
                                                        print("Image 3")
                                                    }
                                                    if let media3 = homeCell["image3"] {
                                                        media3.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                                                            if error == nil {
                                                                if let data = data {
                                                                    self.imageArray[3] = (UIImage(data: data)!)
                                                                    self.slideshow.setImageInputs([ImageSource(image: self.imageArray[0]), ImageSource(image: self.imageArray[1]), ImageSource(image: self.imageArray[2]), ImageSource(image: self.imageArray[3])])
                                                                    print("Image 4")
                                                                }
                                                                if let media4 = homeCell["image4"] {
                                                                    media4.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) in
                                                                        if error == nil {
                                                                            if let data = data {
                                                                                self.imageArray[4] = (UIImage(data: data)!)
                                                                                self.slideshow.setImageInputs([ImageSource(image: self.imageArray[0]), ImageSource(image: self.imageArray[1]), ImageSource(image: self.imageArray[2]), ImageSource(image: self.imageArray[3]), ImageSource(image: self.imageArray[4])])
                                                                                print("Image 5")
                                                                                print("array count is \(self.imageArray.count)")
                                                                            }
                                                                        }
                                                                    })
                                                                }
                                                            }
                                                        })
                                                    }
                                                }
                                            })
                                        }
                                    }
                                })
                            }
                        }
                    })
                }
                
                // END OF WARNING!

            }
        }
    }
    
    
    
    func onTapSlideShow() {
        let ctr = FullScreenSlideshowViewController()
        ctr.pageSelected = {(page: Int) in
            self.slideshow.setScrollViewPage(page, animated: false)
        }
        
        ctr.initialPage = slideshow.scrollViewPage
        ctr.inputs = slideshow.images
        self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow)
        // Uncomment if you want disable the slide-to-dismiss feature
        
    

        ctr.transitioningDelegate = self.transitionDelegate
        self.window?.rootViewController?.presentViewController(ctr, animated: true, completion: nil)
    }
    
    @IBAction func onTapLikeButton(sender: UIButton) {
        // The following implementation is a very simple like button. Further improvement will be done. 
        likeButton.setImage(UIImage(named: "like-on"), forState: .Normal)

        let query = PFQuery(className:"UserMedia")
        query.getObjectInBackgroundWithId(homeCell.objectId!) { (cloudData: PFObject?, error: NSError?) in
            if error != nil {
                print("Can't get an obj for this cell")
            } else if let cloudData = cloudData {
                var likesCount = cloudData["likesCount"] as! Int
                likesCount += 1
                self.likesCountLabel.text = String(likesCount)
                cloudData.incrementKey("likesCount")
                cloudData.saveInBackground()
                self.backView.hidden = true
                
                self.backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
            }
        }
    }
    
    @IBAction func onTapFacebookShareButton(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            self.window?.rootViewController?.presentViewController(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
   
    func onTapDescription(sender: UITapGestureRecognizer){
        if self.trayView.center == self.trayCenterWhenClosed {
            self.backView.hidden = false

            self.backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
            self.trayView.center = self.trayCenterWhenOpen

        } else {
            self.backView.hidden = true

            self.backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
            self.trayView.center = self.trayCenterWhenClosed
        }
        

    }
    
    func onPanDescription(sender: UIPanGestureRecognizer){
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        let translation = sender.translationInView(trayView)
        let velocity = sender.velocityInView(trayView)
        
        if sender.state == UIGestureRecognizerState.Began {
            self.backView.hidden = false
            trayOriginalCenter = trayView.center
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            self.backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)

        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: { () -> Void in
                if velocity.y > 0 {
                    self.trayView.center = self.trayCenterWhenClosed
                    self.backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
                    self.backView.hidden = true

                } else if velocity.y == 0 {
                    self.backView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)

                
                } else if velocity.y < 0 {
                    self.trayView.center = self.trayCenterWhenOpen

                }

                }, completion: { (Bool) -> Void in

            })
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Make up Pet's image
        slideshow.clipsToBounds = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(HomeCell.onTapSlideShow))
        slideshow.addGestureRecognizer(recognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeCell.onTapDescription(_:)))
        showDescription.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(HomeCell.onPanDescription(_:)))
        trayView.addGestureRecognizer(panGesture)
        
        trayCenterWhenOpen = CGPoint(x: trayView.center.x, y:trayView.center.y - 350)
        trayCenterWhenClosed = trayView.center
       
//        tiltleSubView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        tiltleSubView.backgroundColor = UIColor.yellowColor()
        backView.hidden = true
        backView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
        
        trayView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0)
//        descriptionLabel.textColor = UIColor.whiteColor()
        subdescriptionLabel.textColor = UIColor.blackColor()
        subdescriptionLabel.sizeToFit()
        
        
        mapButton.layer.masksToBounds = false
        mapButton.layer.cornerRadius = mapButton.frame.height/2
        mapButton.clipsToBounds = true
        mapButton.layer.borderColor = UIColor.whiteColor().CGColor
        mapButton.layer.borderWidth = 1.0
        mapButton.contentMode = UIViewContentMode.ScaleAspectFill

        self.trayView.center = self.trayCenterWhenClosed


    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

