//
//  CryptoListViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation
import Combine

class CryptoListViewModel: NSObject {
    
    private var cryptoModels: [CryptoModel] = []
        
    private let getCryptoSymbolsUseCase = GetCryptoSymbolsUseCase()
    
    private let getCryptoPriceUseCase = GetCryptoPriceWebSocketUseCase()
    
    private var cancellables = Set<AnyCancellable>()

    func getNumOfRows() -> Int {
        cryptoModels.count
    }
    
    func getCryptoModel(indexPath: IndexPath) -> CryptoModel? {
        guard cryptoModels.indices.contains(indexPath.row) else { return nil }
        return cryptoModels[indexPath.row]
    }
    
    func fetchData() {
        Task {
            let publisher = try await getCryptoPriceUseCase.execute()
            publisher
                .receive(on: DispatchQueue.main)
                .sink { dict in
                    print(dict)
                }.store(in: &cancellables)
        }
    }
    
}
