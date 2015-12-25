//
//  ColorInfoView.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-22.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import UIKit

class ColorInfoView: UIVisualEffectView {
    let label = UILabel()
    let colorDisplay = UIView()
    let whiteView = UIView()
    var color: UIColor? {
        didSet {
            if color != nil {
               label.text = "#\(color!.hex)"
                colorDisplay.backgroundColor = color
                whiteView.hidden = false
            } else {
                whiteView.hidden = true
            }
        }
    }
    init(frame: CGRect) {
        let effect = UIBlurEffect(style: .ExtraLight)
        super.init(effect: effect)
        
        label.text = "Tap to Learn"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 44)
        
        let vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: effect))
        self.contentView.addSubview(vibrancyView)
        
        vibrancyView.addSubview(label)
        
        addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        whiteView.layer.cornerRadius = 5.0
        whiteView.hidden = true
        whiteView.layer.masksToBounds = true
        whiteView.backgroundColor = UIColor.blackColor()
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(whiteView)
        
        addConstraint(NSLayoutConstraint(item: whiteView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 0.0, constant: 36.0))
        addConstraint(NSLayoutConstraint(item: whiteView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 0.0, constant: 36.0))
        
        addConstraint(NSLayoutConstraint(item: whiteView, attribute: .Trailing, relatedBy: .Equal, toItem: label, attribute: .Leading, multiplier: 1.0, constant: -5.0))
        addConstraint(NSLayoutConstraint(item: whiteView, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        whiteView.addSubview(colorDisplay)
        colorDisplay.translatesAutoresizingMaskIntoConstraints = false
        colorDisplay.layer.cornerRadius = 3.0
        colorDisplay.layer.masksToBounds = true
        colorDisplay.backgroundColor = UIColor.redColor()
        
        whiteView.addConstraint(NSLayoutConstraint(item: colorDisplay, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 0.0, constant: 30.0))
        whiteView.addConstraint(NSLayoutConstraint(item: colorDisplay, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 0.0, constant: 30.0))
        
        whiteView.addConstraint(NSLayoutConstraint(item: colorDisplay, attribute: .CenterX, relatedBy: .Equal, toItem: whiteView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        whiteView.addConstraint(NSLayoutConstraint(item: colorDisplay, attribute: .CenterY, relatedBy: .Equal, toItem: whiteView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
