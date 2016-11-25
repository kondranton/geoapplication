//
//  DraggableAnnotationView.swift
//  Geoapps
//
//  Created by Anton Kondrashov on 24/11/2016.
//  Copyright © 2016 Anton Kondrashov. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class DraggableAnnotationView: MGLAnnotationView {
  init(reuseIdentifier: String, size: CGFloat) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    // `draggable` is a property of MGLAnnotationView, disabled by default.
    isDraggable = true
    
    // This property prevents the annotation from changing size when the map is tilted.
    scalesWithViewingDistance = false
    
    // Begin setting up the view.
    frame = CGRect(x: 0, y: 0, width: size, height: size)
    
  }
  
  // These two initializers are forced upon us by Swift.
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // Custom handler for changes in the annotation’s drag state.
  override func setDragState(_ dragState: MGLAnnotationViewDragState, animated: Bool) {
    super.setDragState(dragState, animated: animated)
    
    switch dragState {
    case .starting:
      print("Starting", terminator: "")
      startDragging()
    case .dragging:
      print(".", terminator: "")
    case .ending, .canceling:
      print("Ending")
      endDragging()
    case .none:
      return
    }
  }
  
  // When the user interacts with an annotation, animate opacity and scale changes.
  func startDragging() { }
  
  func endDragging() { }
}
