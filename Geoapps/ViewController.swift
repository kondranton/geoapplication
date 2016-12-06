//
//  ViewController.swift
//  Geoapps
//
//  Created by Anton Kondrashov on 22/11/2016.
//  Copyright © 2016 Anton Kondrashov. All rights reserved.
//

import UIKit
import Mapbox
import GEOSwift

class ViewController: UIViewController, MGLMapViewDelegate {
  
  @IBOutlet var mapView: MGLMapView!
  
  var countries = [CountryDrawing]()
  
  var figureAnnotation: MGLAnnotation?
  var figureCoordinates = [CLLocationCoordinate2D]()
  
  let colors: [UIColor] = [.blue, .red, .yellow, .green, .white]
  
  //MARK: - Actions
  
  @IBAction func clearBtnTap(_ sender: UIBarButtonItem) {
    figureCoordinates = []
    buildAndDisplayPolyline()
  }
  @IBAction func toPolygonTap(_ sender: UIBarButtonItem) {
    buildAndDisplayPolygon()
  }
  
  var panGestureRecognizer: UIPanGestureRecognizer?
  @IBAction func segmentControlSwitch(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 1{
      panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
      mapView.addGestureRecognizer(panGestureRecognizer!)
    } else {
      if panGestureRecognizer != nil{
        mapView.removeGestureRecognizer(panGestureRecognizer!)
      }
    }
  }
  
  //MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpMapView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // Draw the polygon after the map has initialized
    if countries.count == 0{
      drawLayout()
    }
  }
  
  //MARK: - Custom methods
  
  func drawLayout(){
    for url in Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "countries", localization: nil)!{
      let country = CountryDrawing(with: url)
      country.draw(on: mapView)
      countries.append(country)
    }
  }
  func setUpMapView(){
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.setCenter(CLLocationCoordinate2D(latitude: 53.520486, longitude: 37.673541), zoomLevel: 1, animated: false)
    mapView.delegate = self
    
    // double tapping zooms the map, so ensure that can still happen
    let doubleTap = UITapGestureRecognizer(target: self, action: nil)
    doubleTap.numberOfTapsRequired = 2
    mapView.addGestureRecognizer(doubleTap)
    
    // delay single tap recognition until it is clearly not a double
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
    singleTap.require(toFail: doubleTap)
    mapView.addGestureRecognizer(singleTap)
    
    
  }
  
  var beginLocation: CLLocationCoordinate2D?
  func handlePan(pan: UIPanGestureRecognizer){
    
    let location: CLLocationCoordinate2D = mapView.convert(pan.location(in: mapView), toCoordinateFrom: mapView)
    switch pan.state{
    case .began:
      beginLocation = location
    case.changed:
      guard let beginLocation = beginLocation else { return }
      
      let dlat = beginLocation.latitude - location.latitude
      let dlong = beginLocation.longitude - location.longitude
      
      var newFigureCoordinates = [CLLocationCoordinate2D]()
      for coordinate in figureCoordinates {
        let newCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude - dlat, longitude: coordinate.longitude - dlong)
        newFigureCoordinates.append(newCoordinate)
      }
      
      figureCoordinates = newFigureCoordinates
      
      if figureAnnotation is Polygon? {
        buildAndDisplayPolygon()
      } else {
        buildAndDisplayPolyline()
      }
      
      self.beginLocation = location
    case .ended:
      beginLocation = nil
    default: break
    }
  }
  
  func handleSingleTap(tap: UITapGestureRecognizer) {
    // convert tap location (CGPoint)
    // to geographic coordinates (CLLocationCoordinate2D)
    let location: CLLocationCoordinate2D = mapView.convert(tap.location(in: mapView), toCoordinateFrom: mapView)
    
    // create an array of coordinates for our polyline
    figureCoordinates.append(location)
    buildAndDisplayPolyline()
  }
  
  func buildAndDisplayPolyline(){
    clearAnnotation()
    
    if figureCoordinates.count != 0 {
      figureAnnotation = MGLPolyline(coordinates: &figureCoordinates, count: UInt(figureCoordinates.count))
      mapView.addAnnotation(figureAnnotation!)
    }
  }
  
  func buildAndDisplayPolygon(){
    clearAnnotation()
    
    if figureCoordinates.count >= 3 {
      
      //close polyline
      figureCoordinates.append(figureCoordinates.first!)
      
      figureAnnotation = MGLPolygon(coordinates: &figureCoordinates, count: UInt(figureCoordinates.count))
      mapView.addAnnotation(figureAnnotation!)
    }
  }
  
  private func clearAnnotation(){
    if let annotation = figureAnnotation{
      mapView.removeAnnotation(annotation)
    }
  }
  
  private func getFigureWKT()-> String?{
    if figureCoordinates.count == 1{
      return "POINT(\(figureCoordinates[0].WKT))"
    }
    
    var coordinateString = ""
    for coordinate in figureCoordinates.prefix(figureCoordinates.count - 1) {
      coordinateString.append("\(coordinate.WKT), ")
    }
    coordinateString.append("\(figureCoordinates.last!.WKT)")
    
    if let _ = figureAnnotation as? MGLPolyline{
      return "LINESTRING(\(coordinateString))"
    }
    
    if let _ = figureAnnotation as? MGLPolygon{
      return "POLYGON((\(coordinateString)))"
    }
    
    return nil
  }
  
  //MARK: - MGLMapViewDelegate
  
  func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
    return 0.5
  }
  func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
    return .black
  }
  
  func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
    let randomIndex = Int(arc4random()) % colors.count
    return colors[randomIndex]
  }
  
  func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  
  //MARK:- Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showRelations", let destination = segue.destination as? RelationsViewController{
      
      guard let wktString = getFigureWKT() else { return }
      let geometry = Geometry.create(wktString)!
      var relationString = ""
      
      for country in countries{
        if let disjoint = country.geometry?.disjoint(geometry), !disjoint{
          relationString.append("\(country.name) \n")
        }
        
        if let intersects = country.geometry?.intersects(geometry), intersects{
          relationString.append("\t intersects drawn figure\n")
        }
        
        if let crosses = country.geometry?.crosses(geometry), crosses{
          relationString.append("\t crosses drawn figure\n")
        }
        if let contains = country.geometry?.contains(geometry), contains{
          relationString.append("\t contains drawn figure\n")
        }
        if let covers = country.geometry?.covers(geometry), covers{
          relationString.append("\t covers drawn figure\n")
        }
        if let overlaps = country.geometry?.overlaps(geometry), overlaps{
          relationString.append("\t overlaps drawn figure\n")
        }
        if let within = country.geometry?.within(geometry), within{
          relationString.append("\t is within drawn figure\n")
        }
        if let touches = country.geometry?.touches(geometry), touches{
          relationString.append("\t touches drawn figure\n")
        }
        
        if let disjoint = country.geometry?.disjoint(geometry), !disjoint{
          if let intersectionWKT = country.geometry?.intersection(geometry).WKT{
            relationString.append("\t \(intersectionWKT)\n")
          }
        }
        
        
      }
      
      print(relationString)
      destination.text = relationString
      
    }
  }
}

