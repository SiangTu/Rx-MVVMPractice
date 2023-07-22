//
//  UIColorExtension.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
