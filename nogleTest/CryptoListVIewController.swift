//
//  CryptoListVIewController.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit
import SnapKit

class CryptoListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.reuseIdentifier)
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private let viewModel = CryptoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.fetchData()
    }
    
    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.margins.equalTo(view)
        }
    }
}

extension CryptoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.reuseIdentifier, for: indexPath) as! CryptoTableViewCell
        guard let cryptoModel = viewModel.getCryptoModel(indexPath: indexPath) else {
            return cell
        }
        cell.symbolLabel.text = cryptoModel.symbol
        cell.priceLabel.text = cryptoModel.price
        return cell
    }
}
