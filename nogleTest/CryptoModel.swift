//
//  CryptoModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation

struct CryptoModel: Decodable {
    
    init(symbol: String, price: String? = nil) {
        self.symbol = symbol
        self.price = price
    }
    
    let symbol: String
    var price: String?
}
