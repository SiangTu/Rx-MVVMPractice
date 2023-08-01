//
//  ViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import Foundation
import RxSwift
import RxCocoa

class CrypyoPagingViewModel {
    
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
            let basicDict = try await fetchCryptoBasicInfo()
            cryptoDict.accept(basicDict)
            try await subscribeCryptoPrice()
        }
    }
    
    private var disposeBag = DisposeBag()
    
    private var cryptoDict = BehaviorRelay<[String: CryptoModel]>(value: [:])
    
    private let getCryptoSymbolsUseCase = GetCryptoSymbolsUseCase()
    
    private let getCryptoPriceUseCase = GetCryptoPriceWebSocketUseCase()
    
    private func fetchCryptoBasicInfo() async throws -> [String: CryptoModel] {
        let symbols = try await getCryptoSymbolsUseCase.execute()
        var dict: [String: CryptoModel] = [:]
        symbols.forEach {
            dict[$0.symbol] = $0
        }
        return dict
    }
    
    private func subscribeCryptoPrice() async throws {
        let webSocketDict = try await getCryptoPriceUseCase.execute()
        webSocketDict.subscribe { [weak self] dict in
            guard var tempDict = self?.cryptoDict.value else { return }
            dict.forEach { (key, value) in
                if let oldValue = tempDict[key] {
                    tempDict[key] = CryptoModel(symbol: key, future: oldValue.future, price: value.price)
                }
            }
            self?.cryptoDict.accept(tempDict)
        }.disposed(by: disposeBag)
    }
}
