//
//  ViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit

class ViewModel {
    
    enum Page: String, CaseIterable {
        case spot = "Spot"
        case futures = "Future"
    }
    
    let pages = Page.allCases
    
    func getAllPage() -> [Page] {
        return Page.allCases
    }
    
    func getAllPageTitle() -> [String] {
        Page.allCases.map { $0.rawValue }
    }
    
}
