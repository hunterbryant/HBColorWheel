//
//  HBColorWheel.swift
//  HBColorWheel
//
//  Created by Hunter Bryant on 1/4/16.
//  Copyright © 2016 Hunter Bryant. All rights reserved.
//

import UIKit

class HBColorWheel: UIView {

	//MARK: Properties
	
	var viewDelegate: ViewController?
	var colorWheel: ColorWheel!
	
	var color: UIColor!
	var hue: CGFloat = 0.0
	var intensity: CGFloat = 0.0
	
	//MARK: Initialization

	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	//MARK: Functions
	
	func setViewColor(color: UIColor) {
		var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 1.0, alpha: CGFloat = 0.0
		let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		if (!ok) {
			print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
		}
		self.hue = hue
		self.intensity = saturation
		self.color = color
		setup()
	}
	
	func setup() {
		// Remove all subviews
		let views = self.subviews
		for view in views {
			view.removeFromSuperview()
		}
		
		let width = self.bounds.width
		self.backgroundColor = UIColor(red: 34/255, green: 38/255, blue: 51/255, alpha: 1.0) /* #222633 */

		//Initialize a color wheel and add it to the view
		colorWheel = ColorWheel(frame: CGRect(x: 0, y: 0, width: width, height: width), color: self.color)
		colorWheel.delegate = self
		self.addSubview(colorWheel)
	}
	
	func hueAndSaturationSelected(hue: CGFloat, saturation: CGFloat) {
		self.hue = hue
		self.intensity = saturation
		self.color = UIColor(hue: self.hue, saturation: self.intensity, brightness: 1.0, alpha: 1.0)
		viewDelegate?.selectedColor = color
		viewDelegate?.selectedIntensity = saturation
	}
	
}





