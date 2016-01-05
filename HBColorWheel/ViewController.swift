//
//  ViewController.swift
//  HBColorWheel
//
//  Created by Hunter Bryant on 1/4/16.
//  Copyright © 2016 Hunter Bryant. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	// Init ColorPicker with white
	var selectedColor: UIColor = UIColor(hue: 1.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
	var selectedIntensity: CGFloat = 0.0

	@IBOutlet weak var colorWheel: HBColorWheel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// Setup Color Picker
		colorWheel.viewDelegate = self
		colorWheel.setViewColor(selectedColor)

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshColor() {
		
	}



}

