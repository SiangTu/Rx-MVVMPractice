//
//  GetCryptoSymbolsUseCase.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation

struct GetCryptoSymbolsUseCase {
    
    struct ResponseValue: Decodable {
        struct Data: Decodable {
            let symbol: String
            let future: Bool
        }
        let data: [Data]
    }
    
    func execute() async throws -> [CryptoModel] {
        let url = URL(string: urlStr)
        let (data, _) = try await URLSession.shared.data(from: url!)
        let decoder = JSONDecoder()
        let responseValue = try decoder.decode(ResponseValue.self, from: data)
        return responseValue.data.map { CryptoModel(symbol: $0.symbol, future: $0.future) }
    }
    
    private let urlStr = "https://api.btse.com/futures/api/inquire/initial/market"
    
}
