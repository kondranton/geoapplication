//
//  Extensions.swift
//  Geoapps
//
//  Created by Anton Kondrashov on 23/11/2016.
//  Copyright © 2016 Anton Kondrashov. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
  var WKT: String{
    return "\(longitude) \(latitude)"
  }
}
