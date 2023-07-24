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
    
    init(cryptoDict: Observable<[String: CryptoModel]>) {
        self.cryptoDict = cryptoDict
        cryptoDict.map { dict in
            dict.map { $1 }
                .sorted {
                    $0.symbol < $1.symbol
                }
        }
        .subscribe {
            self.cryptoList.accept($0)
        }
        .disposed(by: disposeBag)
    }
    
    var cryptoList = BehaviorRelay<[CryptoModel]>(value: [])
    
    func getNumOfRows() -> Int {
        cryptoList.value.count
    }
    
    func getCryptoModel(indexPath: IndexPath) -> CryptoModel? {
        guard cryptoList.value.indices.contains(indexPath.row) else { return nil }
        return cryptoList.value[indexPath.row]
    }
    
    private var disposeBag = DisposeBag()

    private var cryptoDict: Observable<[String: CryptoModel]>

}
