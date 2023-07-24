//
//  GetCryptoSymbolsUseCase.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation

struct GetCryptoSymbolsUseCase {
    
    struct ResponseData: Decodable {
        struct Data: Decodable {
            let symbol: String
        }
        let data: [Data]
    }
    
    func execute() async throws -> [String] {
        let url = URL(string: urlStr)
        let (data, _) = try await URLSession.shared.data(from: url!)
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(ResponseData.self, from: data)
        return responseData.data.map { $0.symbol }
    }
    
    private let urlStr = "https://api.btse.com/futures/api/inquire/initial/market"
    
}
