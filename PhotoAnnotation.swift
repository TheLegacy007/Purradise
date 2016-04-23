//
//  PhotoAnnotation.swift
//  Purradise
//
//  Created by Nhat Truong on 4/23/16.
//  Copyright © 2016 The Legacy 007. All rights reserved.
//

import Foundation
import MapKit

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
}
