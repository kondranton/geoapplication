//
//  RelationsViewController.swift
//  Geoapps
//
//  Created by Anton Kondrashov on 23/11/2016.
//  Copyright © 2016 Anton Kondrashov. All rights reserved.
//

import UIKit

class RelationsViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  var text: String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textView.text = text
    // Do any additional setup after loading the view.
  }
  
  
}
