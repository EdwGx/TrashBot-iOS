//
//  UIColorExtension.swift
//  TrashBot
//
//  Created by Edward Guo on 2015-12-25.
//  Copyright © 2015 Peiliang Guo. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    var hex: String {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (NSString(format: "%02lX%02lX%02lX", lroundf(Float(red) * 255.0), lroundf(Float(green) * 255.0), lroundf(Float(blue) * 255.0)) as String)
    }
}