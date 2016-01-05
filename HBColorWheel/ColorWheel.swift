//
//  ColorWheel.swift
//  HBColorWheel
//
//  Created by Hunter Bryant on 1/4/16.
//  Copyright © 2016 Hunter Bryant. All rights reserved.
//

import UIKit

class ColorWheel: UIView {

	//MARK: Properties
	
	var color: UIColor!
	var intensity: CGFloat!
	
	//Layer for drawing
	var wheelLayer: CALayer!
	var indicatorLayer: CAShapeLayer!
	var point: CGPoint!
	var indicatorCircleRadius: CGFloat = 14.0

	//Scaling for retina
	let scale: CGFloat = UIScreen.mainScreen().scale
	
	//Delegation
	var delegate: HBColorWheel?
	
	
	//MARK: Initialization
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder);
	}
	
	init(frame: CGRect, color: UIColor) {
		super.init(frame: frame)
		
		//Retina scaling
		let mainScreen: UIScreen = UIScreen.mainScreen()
		var onePixel: CGFloat = 1.0 / mainScreen.scale
		if mainScreen.respondsToSelector("nativeScale") {
			onePixel = 1.0 / mainScreen.nativeScale
		}
		
		//Layer for color wheel
		self.color = color
		wheelLayer = CALayer()
		wheelLayer.frame = CGRectMake(20, 20, self.frame.width-40, self.frame.height-40)
		
		// Layers for crosshairs
		let crosshairLayer = CAShapeLayer()
		let minConstraint = min((frame.width),(frame.height))
		crosshairLayer.path = UIBezierPath(rect: CGRectMake(frame.width/2-wheelLayer.frame.width/2+10, minConstraint/2 - onePixel/2, self.frame.width-55, onePixel)).CGPath
		
		let crosshairLayerVert = CAShapeLayer()
		crosshairLayerVert.path = UIBezierPath(rect: CGRectMake(minConstraint/2 - onePixel/2, frame.height/2-wheelLayer.frame.height/2+10, onePixel, self.frame.height-55)).CGPath
		
		crosshairLayer.strokeColor = UIColor(red: 113/255, green: 121/255, blue: 140/255, alpha: 1.0).CGColor
		crosshairLayerVert.strokeColor = UIColor(red: 113/255, green: 121/255, blue: 140/255, alpha: 1.0).CGColor
		
		self.layer.addSublayer(crosshairLayerVert)
		self.layer.addSublayer(crosshairLayer)

		wheelLayer.contents = createColorWheel(wheelLayer.frame.size)
		self.layer.addSublayer(wheelLayer)
		
		// Layer for the indicator
		indicatorLayer = CAShapeLayer()
		indicatorLayer.fillColor = nil
		self.layer.addSublayer(indicatorLayer)
		
		setViewColor(color);
		
	}
	
	
	//MARK: Utility functions
	
	func setViewColor(color: UIColor) {
		// Update the entire view with a given color
		var hue: CGFloat = 0.0
		var saturation: CGFloat = 0.0
		var brightness: CGFloat = 1.0
		var alpha: CGFloat = 0.0
		
		let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		if (!ok) {
			print("HBColorWheel: exception <The color provided to HBColorControl is not convertible to HSV>")
		}
		
		self.color = color
		self.intensity = saturation
		point = pointAtHueSaturation(hue, saturation: saturation)
		
		drawIndicator()

	}
	
	func pointAtHueSaturation(hue: CGFloat, saturation: CGFloat) -> CGPoint {
		// Get a point (x,y) in the wheel for a given hue and saturation
		let dimension: CGFloat = min(wheelLayer.frame.width, wheelLayer.frame.height)
		let radius: CGFloat = saturation * dimension / 2
		let x = dimension / 2 + radius * cos(hue * CGFloat(M_PI) * 2) + 20
		let y = dimension / 2 + radius * sin(hue * CGFloat(M_PI) * 2) + 20
		return CGPointMake(x, y)
	}
	
	func hueSaturationAtPoint(position: CGPoint) -> (hue: CGFloat, saturation: CGFloat) {
		// Get hue and saturation for a given point (x,y) in the wheel
		
		let c = CGRectGetWidth(wheelLayer.frame) * scale / 2
		let dx = CGFloat(position.x - c) / c
		let dy = CGFloat(position.y - c) / c
		let d = sqrt(CGFloat (dx * dx + dy * dy))
		
		let saturation: CGFloat = d
		
		var hue: CGFloat
		if (d == 0) {
			hue = 0;
		} else {
			hue = acos(dx/d) / CGFloat(M_PI) / 2.0
			if (dy < 0) {
				hue = 1.0 - hue
			}
		}
		return (hue, saturation)
	}
	
	
	//MARK: Indicator Functions
	
	func drawIndicator() {
		// Draw the indicator
		if (point != nil) {
			indicatorLayer.path = UIBezierPath(roundedRect: CGRect(x: point.x-indicatorCircleRadius, y: point.y-indicatorCircleRadius, width: indicatorCircleRadius*2, height: indicatorCircleRadius*2), cornerRadius: indicatorCircleRadius).CGPath
			indicatorLayer.fillColor = self.color.CGColor
		}
	}
	
	func getIndicatorCoordinate(coord: CGPoint) -> (point: CGPoint, isCenter: Bool) {
		// Making sure that the indicator can't get outside the Hue and Saturation wheel
		
		let dimension: CGFloat = min(wheelLayer.frame.width, wheelLayer.frame.height)
		let radius: CGFloat = dimension/2
		let wheelLayerCenter: CGPoint = CGPointMake(wheelLayer.frame.origin.x + radius, wheelLayer.frame.origin.y + radius)
		
		let dx: CGFloat = coord.x - wheelLayerCenter.x
		let dy: CGFloat = coord.y - wheelLayerCenter.y
		let distance: CGFloat = sqrt(dx*dx + dy*dy)
		var outputCoord: CGPoint = coord
		
		// If the touch coordinate is outside the radius of the wheel, transform it to the edge of the wheel with polar coordinates
		if (distance > radius) {
			let theta: CGFloat = atan2(dy, dx)
			outputCoord.x = radius * cos(theta) + wheelLayerCenter.x
			outputCoord.y = radius * sin(theta) + wheelLayerCenter.y
		}
		
		// If the touch coordinate is close to center, focus it to the very center at set the color to white
		let whiteThreshold: CGFloat = 8
		var isCenter = false
		if (distance < whiteThreshold) {
			outputCoord.x = wheelLayerCenter.x
			outputCoord.y = wheelLayerCenter.y
			isCenter = true
		}
		return (outputCoord, isCenter)
	}
	
	
	//MARK: Drawing Wheel
	
	func createColorWheel(size: CGSize) -> CGImageRef {
		// Creates a bitmap of the Hue Saturation wheel
		let originalWidth: CGFloat = size.width
		let originalHeight: CGFloat = size.height
		let dimension: CGFloat = min(originalWidth*scale, originalHeight*scale)
		let bufferLength: Int = Int(dimension * dimension * 4)
		
		let bitmapData: CFMutableDataRef = CFDataCreateMutable(nil, 0)
		CFDataSetLength(bitmapData, CFIndex(bufferLength))
		let bitmap = CFDataGetMutableBytePtr(bitmapData)
		
		for (var y: CGFloat = 0; y < dimension; y++) {
			for (var x: CGFloat = 0; x < dimension; x++) {
				var hsv: HSV = (hue: 0, saturation: 0, brightness: 0, alpha: 0)
				var rgb: RGB = (red: 0, green: 0, blue: 0, alpha: 0)
				
				let color = hueSaturationAtPoint(CGPointMake(x, y))
				let hue = color.hue
				let saturation = color.saturation
				var a: CGFloat = 0.0
				if (saturation < 1.0) {
					// Antialias the edge of the circle.
					if (saturation > 0.99) {
						a = (1.0 - saturation) * 100
					} else {
						a = 1.0;
					}
					
					hsv.hue = hue
					hsv.saturation = 0.4
					hsv.brightness = 1.0
					hsv.alpha = a
					rgb = hsv2rgb(hsv)
				}
				if(saturation > 0.87) {
					let offset = Int(4 * (x + y * dimension))
					bitmap[offset] = UInt8(rgb.red*255)
					bitmap[offset + 1] = UInt8(rgb.green*255)
					bitmap[offset + 2] = UInt8(rgb.blue*255)
					bitmap[offset + 3] = UInt8(rgb.alpha*255)
				}
			}
		}
		
		// Convert the bitmap to a CGImage
		let colorSpace: CGColorSpaceRef? = CGColorSpaceCreateDeviceRGB()
		let dataProvider: CGDataProviderRef? = CGDataProviderCreateWithCFData(bitmapData)
		let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrderDefault.rawValue | CGImageAlphaInfo.Last.rawValue)
		let imageRef: CGImageRef? = CGImageCreate(Int(dimension), Int(dimension), 8, 32, Int(dimension) * 4, colorSpace, bitmapInfo, dataProvider, nil, false, CGColorRenderingIntent.RenderingIntentDefault)
		return imageRef!
	}


	//MARK: Touch Functions
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		indicatorCircleRadius = 44.0
		// Set reference to the location of the touch in member point
		if let touch = touches.first {
			point = touch.locationInView(self)
		}
		
		let indicator = getIndicatorCoordinate(point)
		point = indicator.point
		var color = (hue: CGFloat(0), saturation: CGFloat(0))
		if !indicator.isCenter  {
			color = hueSaturationAtPoint(CGPointMake(point.x*scale, point.y*scale))
		}
		self.color = UIColor(hue: color.hue, saturation: color.saturation, brightness: 1.0, alpha: 1.0)
		
		// Notify delegate of the new Hue and Saturation
		delegate?.hueAndSaturationSelected(color.hue, saturation: color.saturation)
		delegate?.viewDelegate?.refreshColor()
		
		drawIndicator()
		
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		// Set reference to the location of the touchesMoved in member point
		if let touch = touches.first {
			point = touch.locationInView(self)
		}
		let indicator = getIndicatorCoordinate(point)
		point = indicator.point
		var color = (hue: CGFloat(0), saturation: CGFloat(0))
		if !indicator.isCenter  {
			color = hueSaturationAtPoint(CGPointMake(point.x*scale, point.y*scale))
		}
		self.color = UIColor(hue: color.hue, saturation: color.saturation, brightness: 1.0, alpha: 1.0)
		
		// Notify delegate of the new Hue and Saturation
		delegate?.hueAndSaturationSelected(color.hue, saturation: color.saturation)
		delegate?.viewDelegate?.refreshColor()
		
		// Draw the indicator
		drawIndicator()
		
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		indicatorCircleRadius = 14.0
		// Set reference to the location of the touch in member point
		if let touch = touches.first {
			point = touch.locationInView(self)
		}
		
		let indicator = getIndicatorCoordinate(point)
		point = indicator.point
		var color = (hue: CGFloat(0), saturation: CGFloat(0))
		if !indicator.isCenter  {
			color = hueSaturationAtPoint(CGPointMake(point.x*scale, point.y*scale))
		}
		
		self.color = UIColor(hue: color.hue, saturation: color.saturation, brightness: 1.0, alpha: 1.0)
		
		// Notify delegate of the new Hue and Saturation
		delegate?.hueAndSaturationSelected(color.hue, saturation: color.saturation)
		delegate?.viewDelegate?.refreshColor()
		
		
		// Draw the indicator
		drawIndicator()
	}


}







