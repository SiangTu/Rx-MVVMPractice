//
//  CryptoListViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation
import RxSwift
import RxCocoa

class CryptoListViewModel: NSObject {
            
    private let getCryptoSymbolsUseCase = GetCryptoSymbolsUseCase()
    
    private let getCryptoPriceUseCase = GetCryptoPriceWebSocketUseCase()
    
    private var disposeBag = DisposeBag()

    var cryptoList = BehaviorRelay<[CryptoModel]>(value: [])

    private var cryptoDict = BehaviorRelay<[String: CryptoModel]>(value: [:])
    
    func getNumOfRows() -> Int {
        cryptoList.value.count
    }
    
    func getCryptoModel(indexPath: IndexPath) -> CryptoModel? {
        guard cryptoList.value.indices.contains(indexPath.row) else { return nil }
        return cryptoList.value[indexPath.row]
    }
    
    func fetchData() {
        let a = cryptoDict.asObservable()
        a.subscribe { dict in
//            print("😀")
//            print(dict)
            let list = dict.map {
                $1
            }
            Task {
                await MainActor.run {
                    self.cryptoList.accept(list)
                }
            }
        }.disposed(by: disposeBag)
        
        Task {
            let symbols = try await getCryptoSymbolsUseCase.execute()
            var dict: [String: CryptoModel] = [:]
            symbols.forEach {
                dict[$0] = CryptoModel(symbol: $0)
            }
            cryptoDict.accept(dict)
            let observeable = try await getCryptoPriceUseCase.execute()
            var combineDict: [String: CryptoModel] = [:]
            combineDict = cryptoDict.value
            observeable.subscribe { dict in
                dict.forEach { (key, value) in
                    if combineDict[key] != nil {
                        combineDict[key] = value
                    }
                }
                // TODO: queue
                self.cryptoDict.accept(combineDict)
            }.disposed(by: disposeBag)
        }
    }
    
}
