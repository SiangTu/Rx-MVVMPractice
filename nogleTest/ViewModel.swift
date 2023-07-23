//
//  ViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit

class ViewModel {
    
    enum Page: CaseIterable {
        case spot
        case futures
        
        var title: String {
            switch self {
            case .futures:
                return "Future"
            case .spot:
                return "Spot"
            }
        }
    }
    
    let pages = Page.allCases
}
