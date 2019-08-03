//
//  ColourConstant.swift
//  WeatherZone
//
//  Created by Nischal Hada on 3/8/19.
//  Copyright © 2019 NischalHada. All rights reserved.
//

import UIKit

extension UIColor {
    static var viewBackgroundColor: UIColor {
        return UIColor(rgb: 0x8D9BA3)
    }
}


extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}