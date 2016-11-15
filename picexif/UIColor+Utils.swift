//
//  UIColor+Utils.swift
//  picexif
//
//  Created by Simon on 05/11/2016.
//  Copyright © 2016 Simon. All rights reserved.
//

import Foundation

extension UIColor {
    static func withRGB(red: Int, green: Int, blue: Int) -> UIColor{
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
