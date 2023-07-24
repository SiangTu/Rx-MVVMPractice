//
//  ViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import Foundation
import RxSwift
import RxCocoa

class CrtpyoPagingViewModel {
    
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

    func getCryptoDict(page: Page) -> Observable<[String: CryptoModel]> {
        return cryptoDict.map { dict in
            dict.filter { (key, value) in
                value.future == (page == .futures)
            }
        }.asObservable()
    }
    
    func fetchData() {
        Task {
            let symbols = try await getCryptoSymbolsUseCase.execute()
            var dict: [String: CryptoModel] = [:]
            symbols.forEach {
                dict[$0.symbol] = $0
            }
            cryptoDict.accept(dict)
            let observeable = try await getCryptoPriceUseCase.execute()
            var combineDict: [String: CryptoModel] = [:]
            combineDict = cryptoDict.value
            observeable.subscribe { dict in
                print("😅")
                dict.forEach { (key, value) in
                    if let oldValue = combineDict[key] {
                        combineDict[key] = CryptoModel(symbol: key, future: oldValue.future, price: value.price)
                    }
                }
                // TODO: queue
                self.cryptoDict.accept(combineDict)
            }.disposed(by: disposeBag)
        }
    }
    
    private var disposeBag = DisposeBag()
    
    private var cryptoDict = BehaviorRelay<[String: CryptoModel]>(value: [:])
    
    private let getCryptoSymbolsUseCase = GetCryptoSymbolsUseCase()
    
    private let getCryptoPriceUseCase = GetCryptoPriceWebSocketUseCase()
}
