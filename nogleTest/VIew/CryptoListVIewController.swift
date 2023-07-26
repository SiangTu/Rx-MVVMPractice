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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.cryptoList.subscribe (onNext: { value in
            Task {
                await MainActor.run {
                    self.tableView.reloadData()
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(CryptoTableViewCell.self, forCellReuseIdentifier: CryptoTableViewCell.reuseIdentifier)
        view.rowHeight = 100
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var sortButtons: [UIButton] = {
        var buttons: [UIButton] = []
        viewModel.sortTypes.forEach { type in
            let button = UIButton()
            button.setTitle(type.title, for: .normal)
            button.backgroundColor = .systemBlue
            button.rx.tap.subscribe(onNext:  {
                self.viewModel.currentSortType = type
            })
            .disposed(by: disposeBag)
            buttons.append(button)
        }
        return buttons
    }()
        
    private var disposeBag = DisposeBag()
    
    private let viewModel: CryptoListViewModel

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        sortButtons.forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(50)
                make.width.equalTo(80)
            }
        }
        let stackView = UIStackView(arrangedSubviews: sortButtons)
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.equalTo(view).offset(10)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(view)
        }
    }
}

extension CryptoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = viewModel.getNumOfRows()
        return n
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CryptoTableViewCell.reuseIdentifier, for: indexPath) as! CryptoTableViewCell
        cell.symbolLabel.text = viewModel.getSymbolName(indexPath: indexPath)
        cell.priceLabel.text = viewModel.getPrice(indexPath: indexPath)
        return cell
    }
}
