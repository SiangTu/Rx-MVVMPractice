//
//  CryptoModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation

struct CryptoModel: Decodable {
    
    init(symbol: String, future: Bool = false, price: Double? = nil) {
        self.symbol = symbol
        self.future = future
        self.price = price
    }
    
    let symbol: String
    let future: Bool
    var price: Double?
}
