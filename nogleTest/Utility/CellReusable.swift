//
//  CellReusable.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit

protocol CellReusable {}

extension CellReusable where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var cellNib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}

extension UITableViewCell: CellReusable {}
extension UITableViewHeaderFooterView: CellReusable {}
extension UICollectionReusableView: CellReusable {}
