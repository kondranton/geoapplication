//
//  Country.swift
//  Geoapps
//
//  Created by Anton Kondrashov on 23/11/2016.
//  Copyright © 2016 Anton Kondrashov. All rights reserved.
//

import Foundation
import Mapbox
import GEOSwift
import SwiftyJSON

class CountryDrawing {
  
  var name: String = ""
  var geometry: Geometry?
  
  func draw(on map: MGLMapView){
    
    func drawPolygon(polygon: Polygon){
      //get all points of polygon
      var coordinates = [CLLocationCoordinate2D]()
      for point in polygon.exteriorRing.points{
        let nextLocation = CLLocationCoordinate2D(latitude: point.y, longitude: point.x)
        coordinates.append(nextLocation)
      }
      
      //create and display shape
      let polygonShape = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
      map.addAnnotation(polygonShape)
    }
    
    if geometry is MultiPolygon?{
      guard let countryGeometry = geometry as? MultiPolygon else { return }
      for polygon in countryGeometry.geometries{
        drawPolygon(polygon: polygon)
      }
    } else {
      guard let countryGeometry = geometry as? Polygon else {
        return
      }
      drawPolygon(polygon: countryGeometry)
    }
  }
  
  
  
  init(with geoJsonURL: URL){
    do{
      guard let geometries = try Geometry.fromGeoJSON(geoJsonURL) else { return }
      self.geometry = geometries[0]
      
      let data = try Data(contentsOf: geoJsonURL)
      let json = JSON(data: data)
      
      self.name = json["features"][0]["properties"]["name"].stringValue
      
    } catch let error {
      self.geometry = Geometry.create("POINT(0 0)")!
      print(error)
    }
    
  }
  
}
