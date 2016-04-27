//
//  CameraController.swift
//  Purradise
//
//  Created by Nhat Truong on 4/10/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation
import Parse
import DGActivityIndicatorView
import QBImagePickerController
import ImageSlideshow

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, QBImagePickerControllerDelegate {
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var buttonPictureAndCamera: UIButton!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var makeupButton: [UIButton]!
    @IBOutlet var toSetBackgroundColorForType: [UIButton]!
    @IBOutlet var toSetBackgroundColorForAction: [UIButton]!
    @IBOutlet weak var topImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    var camera_flag = false
    var resizedImage: [UIImage] = []
    var point: PFGeoPoint?
    var objectName = "Other"
    var requiredAction = "Other"
    var geoLocationValid = false
    lazy var locationManager = CLLocationManager()
    
    let activityIndicatorView = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType.RotatingSquares, tintColor: UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0), size: 70.0)
    
    // A very cold place, Antarctica
    var latitude = 82.8628
    var longitude = 135.0000
    var geoLocation = PFGeoPoint(latitude: 82.8628, longitude: 135.0000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        slideshow.backgroundColor = UIColor.whiteColor()
        slideshow.slideshowInterval = 5.0
        slideshow.pageControlPosition = PageControlPosition.InsideScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = UIColor.whiteColor();
        slideshow.pageControl.pageIndicatorTintColor = UIColor.lightGrayColor();
        
        // Make up
        for eachButton in makeupButton {
            eachButton.layer.cornerRadius = 5
            eachButton.layer.borderWidth = 0.5
            eachButton.layer.borderColor = eachButton.tintColor.CGColor
        }
        selectedImageView.layer.cornerRadius = 5
        selectedImageView.clipsToBounds = true
        
        // Place holder and border for textview
        descriptionTextView.text = "How would you describe it?"
        descriptionTextView.textColor = UIColor.lightGrayColor()
        descriptionTextView.delegate = self
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        descriptionTextView.layer.cornerRadius = 5
        
        // Just make it looked like the textview
        self.location.delegate = self
        location.layer.borderWidth = 0.5
        location.layer.borderColor = UIColor.lightGrayColor().CGColor
        location.layer.cornerRadius = 5
        
        // Tune in keyboard's events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        navigationItem.title = ""
        
        // Location service
        locationManager.delegate = self
        
        // Tap and long tap for buttonPictureAndCamera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraController.normalTap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraController.longTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        buttonPictureAndCamera.addGestureRecognizer(tapGesture)
        buttonPictureAndCamera.addGestureRecognizer(longGesture)
       
    }
    
    override func viewWillAppear(animated: Bool) {
        if camera_flag == false {
        // Activate the camera now if possible
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil ||    UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil { // if has camera
                let vc = UIImagePickerController()
                vc.delegate = self
                vc.allowsEditing = true
                vc.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(vc, animated: true, completion: nil)
                camera_flag = true
            }
        }
    }
    
    @IBAction func onTapPetTypeSelection(sender: UIButton) {
        for button in toSetBackgroundColorForType {
            button.backgroundColor = UIColor.whiteColor()
        }
        sender.backgroundColor = UIColor.greenColor()
        
        switch sender.currentTitle! {
        case "Dog":
            objectName = sender.currentTitle!
        case "Cat":
            objectName = sender.currentTitle!
        default: break
        }
    }
    
    @IBAction func onTapActionSelection(sender: UIButton) {
        for button in toSetBackgroundColorForAction {
            button.backgroundColor = UIColor.whiteColor()
        }
        sender.backgroundColor = UIColor.greenColor()
        
        switch sender.currentTitle! {
        case "Adopt":
            requiredAction = sender.currentTitle!
        case "Rescue":
            requiredAction = sender.currentTitle!
        case "Lo&Fo":
            requiredAction = sender.currentTitle!
        default: break
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "How would you describe it?"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    deinit {
        print("Observer is deinited in CameraVC")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1) {
            self.bottomViewConstraint.constant = keyboardFrame.size.height
            self.topViewConstraint.constant = 0 - (keyboardFrame.size.height)
            self.topImageConstraint.constant = 0 - (keyboardFrame.size.height)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.1) {
            self.bottomViewConstraint.constant = 4
            self.topViewConstraint.constant = 8
            self.topImageConstraint.constant = 8
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        
        UIView.animateWithDuration(0.1) {
            self.bottomViewConstraint.constant = 4
            self.topViewConstraint.constant = 8
            self.topImageConstraint.constant = 8
        }
    }
    
    @IBAction func onTapPost(sender: UIBarButtonItem) {
        
        if (resizedImage.count != 0) {
            activityIndicatorView.center = self.view.center
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()

            UserMedia.postUserImage(resizedImage, withObjectName: objectName, withRequiredAction: requiredAction, withLocation: location.text, withGeoLocation: geoLocation, withGeoLocationValid: geoLocationValid, withDescription: descriptionTextView.text, withCompletion: { (success: Bool, error: NSError?) in
                if error != nil {
                    print("Error uploading")
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.removeFromSuperview()
                }
                if success {
                    print("Post successfully")
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.removeFromSuperview()
                    //self.performSegueWithIdentifier("feed", sender: nil)
                    
                }
            })
            self.dismissViewControllerAnimated(true, completion: nil)

            
        } else {
            // An image is required.
            let alertVC = UIAlertController(
                title: "No Image",
                message: "Sorry, an image is required for a post!",
                preferredStyle: .Alert)
            let okAction = UIAlertAction(
                title: "OK",
                style:.Default,
                handler: nil)
            alertVC.addAction(okAction)
            presentViewController(alertVC, animated: true, completion: nil)
        }
        // Don't wait for the network (insert images into the post directly as we had the images locally).
    }
    
    @IBAction func onTapCancelButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        selectedImageView.image = editedImage
        self.resizedImage.removeAll()
        // print(editedImage)
        resizedImage.append(editedImage)
        // print(resizedImage.count)
        if picker.sourceType == .Camera {
            navigationItem.title = "From Camera"
        } else {
            navigationItem.title = "From Library"
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func dismissPhotoPicker(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        let manager = PHImageManager.defaultManager()
        self.resizedImage.removeAll()
        print("assets is \(assets.count)")
        let option = PHImageRequestOptions()
//        option.synchronous = true
        option.resizeMode = PHImageRequestOptionsResizeMode.Exact
        option.deliveryMode =  PHImageRequestOptionsDeliveryMode.HighQualityFormat
        option.version = PHImageRequestOptionsVersion.Current
//        option.networkAccessAllowed = true
        
        for asset in assets as! [PHAsset] {
            
            let originalWidth  = CGFloat(asset.pixelWidth)
            let originalHeight = CGFloat(asset.pixelHeight)
            var x: CGFloat = 0.0
            var y: CGFloat = 0.0
            var edge: CGFloat = 0.0
            
            if (originalWidth > originalHeight) {
                // landscape
                edge = originalHeight
                x = (originalWidth - edge) / 2.0
                y = 0.0
                
            } else if (originalHeight > originalWidth) {
                // portrait
                edge = originalWidth
                x = 0.0
                y = (originalHeight - originalWidth) / 2.0
            } else {
                // square
                edge = originalWidth
            }
            
            let square = CGRectMake(x, y, edge, edge)
            let cropRect = CGRectApplyAffineTransform(square, CGAffineTransformMakeScale(1.0 / originalWidth, 1.0 / originalHeight))
            option.normalizedCropRect = cropRect
            manager.requestImageForAsset(asset, targetSize: CGSize(width: edge, height:  edge), contentMode: .AspectFit, options: option, resultHandler: { (result, info) in
                self.resizedImage.append(result!)
                self.selectedImageView.image = result
                print(info)
                print(result)
                print("You selected \(self.resizedImage.count)")
            })
        }
        
        for i in 0..<resizedImage.count {
            self.slideshow.setImageInputs([ImageSource(image: self.resizedImage[i])])
        }

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func normalTap() {
        print("Normal tap")
        // Activate camera roll
//        let picker = UIImagePickerController()
        let picker = QBImagePickerController()
    
//        picker.allowsEditing = true
//        picker.sourceType = .PhotoLibrary
//        picker.delegate = self
        picker.allowsMultipleSelection = true
        picker.minimumNumberOfSelection = 1
        picker.maximumNumberOfSelection = 5
        picker.showsNumberOfSelectedAssets = true
        picker.delegate = self
        picker.prompt = "Select photos"
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func longTap(sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == .Began {
            print("UIGestureRecognizerStateBegan")
            // Activate the camera
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil ||  UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil { // if has camera
                let vc = UIImagePickerController()
                vc.delegate = self
                vc.allowsEditing = true
                vc.sourceType = UIImagePickerControllerSourceType.Camera
                
                self.presentViewController(vc, animated: true, completion: nil)
            } else {
                let alertVC = UIAlertController(
                    title: "No Camera",
                    message: "Sorry, this device has no camera",
                    preferredStyle: .Alert)
                let okAction = UIAlertAction(
                    title: "OK",
                    style:.Default,
                    handler: nil)
                alertVC.addAction(okAction)
                presentViewController(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func getLocation(sender: UIButton) {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 200
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            self.location.text = ""
            var addToString = ""
            
            // Location name may not be available in VN
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.location.text = locationName as String
            }
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                if (addToString != "") {
                    addToString = addToString + ", " + (street as String)
                    self.location.text = addToString
                } else {
                    self.location.text = street as String
                }
            }
            
            // SubLocality
            addToString = self.location.text!
            if let subLocality = placeMark.addressDictionary!["SubLocality"] as? NSString {
                if (addToString != "") {
                    addToString = addToString + ", " + (subLocality as String)
                    self.location.text = addToString
                } else {
                    self.location.text = subLocality as String
                }
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                if (addToString != "") {
                    addToString = addToString + ", " + (city as String)
                    self.location.text = addToString
                } else {
                    self.location.text = city as String
                }
                print("Location is \(self.location.text)")
            }
        })
    }
    
}

extension CameraController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            print("Start updating current location")
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            geoLocationValid = true
            geoLocation = PFGeoPoint(location: location)
        }
    }
}