//
//  MapViewController.swift
//  Purradise
//
//  Created by Nhat Truong on 4/23/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import UIKit
import MapKit
import Parse


class MapViewController: UIViewController {
    
    var currentAnnotation: PhotoAnnotation!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var geoLocation: PFGeoPoint?
    var petImage: UIImage!
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.mapType = MKMapType.Hybrid
        mapView.mapType = MKMapType.Standard

        mapView.delegate = self
        
        print("geolocation", geoLocation)
        let coordinate = CLLocationCoordinate2DMake(geoLocation!.latitude, geoLocation!.longitude)

        let sfRegion = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        

        let annotation = PhotoAnnotation() // MKPointAnnotation()
        annotation.coordinate = coordinate
        // annotation.title = "Picture!"
        annotation.photo = petImage
        mapView.addAnnotation(annotation)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.delegate = nil
        mapView.removeFromSuperview()
        mapView = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension MapViewController: MKMapViewDelegate{
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("viewForAnnotation")
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
        
        let resizeRenderImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        resizeRenderImageView.layer.borderColor = UIColor.redColor().CGColor
        resizeRenderImageView.layer.masksToBounds = false
        resizeRenderImageView.layer.cornerRadius = resizeRenderImageView.frame.height/2
        resizeRenderImageView.clipsToBounds = true
        
        resizeRenderImageView.layer.borderWidth = 2.0
        resizeRenderImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // create it if it's te first time
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
            
            let button = MyUIButton(type: .DetailDisclosure)
            button.annotation = annotation as! PhotoAnnotation
            annotationView!.rightCalloutAccessoryView = button
        }
        
        let imageView = annotationView!.leftCalloutAccessoryView as! UIImageView
        // imageView.image = UIImage(named: "camera")
        imageView.image = thumbnail
        annotationView!.image = thumbnail
        
        // NOTE: you can take advantage of iOS 9 .detailCalloutAccessoryView
        // if #available(iOS 9, *) {
        //   annotationView!.detailCalloutAccessoryView = someCoolUIViewInstance
        // }
        return annotationView
    }

}

class MyUIButton: UIButton {
    var annotation: PhotoAnnotation!
}