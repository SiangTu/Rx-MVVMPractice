//
//  CGFloatExtension.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import Foundation

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
