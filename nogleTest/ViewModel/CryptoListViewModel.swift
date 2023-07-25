//
//  CryptoListViewModel.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/23.
//

import Foundation
import RxSwift
import RxCocoa

class CryptoListViewModel {
    
    enum SortType: CaseIterable {
        case charDescending
        case charAscending
        
        var title: String {
            switch self {
            case .charAscending:
                return "A-Z"
            case .charDescending:
                return "Z-A"
            }
        }
    }
    
    init(cryptoDict: Observable<[String: CryptoModel]>) {
        self.cryptoDict = cryptoDict
        cryptoDict.map { [weak self] dict in
            let list = dict.map { $1 }
            return self?.sort(list) ?? list
        }
        .subscribe { [weak self] in
            self?.cryptoListRelay.accept($0)
        }
        .disposed(by: disposeBag)
    }
     
    let sortTypes: [SortType] = SortType.allCases
    
    private(set) lazy var cryptoList = cryptoListRelay.asObservable()
    
    var currentSortType: SortType = .charAscending {
        didSet {
            cryptoListRelay.accept(sort(cryptoListRelay.value))
        }
    }
    
    func getNumOfRows() -> Int {
        cryptoListRelay.value.count
    }
    
    func getSymbolName(indexPath: IndexPath) -> String? {
        guard cryptoListRelay.value.indices.contains(indexPath.row) else { return nil }
        return cryptoListRelay.value[indexPath.row].symbol
    }
    
    func getPrice(indexPath: IndexPath) -> String? {
        guard cryptoListRelay.value.indices.contains(indexPath.row) else { return nil }
        guard let price = cryptoListRelay.value[indexPath.row].price else { return nil }
        return String(price)
    }

    private let cryptoListRelay = BehaviorRelay<[CryptoModel]>(value: [])

    private var disposeBag = DisposeBag()

    private var cryptoDict: Observable<[String: CryptoModel]>
        
    private func sort(_ list: [CryptoModel]) -> [CryptoModel] {
        switch currentSortType {
        case .charAscending:
            return list.sorted { $0.symbol < $1.symbol }
        case .charDescending:
            return list.sorted { $0.symbol > $1.symbol }
        }
    }

}
