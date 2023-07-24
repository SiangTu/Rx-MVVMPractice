//
//  CryptoListVIewController.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class CryptoListViewController: UIViewController {
    
    init(cryptoDict: Observable<[String: CryptoModel]>) {
        self.viewModel = CryptoListViewModel(cryptoDict: cryptoDict)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.reuseIdentifier)
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private let viewModel: CryptoListViewModel
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.cryptoList.asObservable().subscribe (onNext: { value in
            Task {
                await MainActor.run {
                    self.tableView.reloadData()
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.margins.equalTo(view)
        }
    }
    var firstT = true
}

extension CryptoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = viewModel.getNumOfRows()
        return n
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.reuseIdentifier, for: indexPath) as! CryptoTableViewCell
        guard let cryptoModel = viewModel.getCryptoModel(indexPath: indexPath) else {
            return cell
        }
        cell.symbolLabel.text = cryptoModel.symbol
        cell.priceLabel.text = cryptoModel.price
        if cryptoModel.price != nil, firstT {
            print(Date().timeIntervalSince1970)
            firstT = false
        }
        return cell
    }
}
