//
//  ViewController.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: viewModel.getAllPageTitle())
        view.backgroundColor = .brown
        view.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        return view
    }()
    
    private lazy var pageViewController: CustomPagingViewController = {
        let pages = viewModel.getAllPage()
        let pageVCs = pages.map { getVC($0) }
        let vc = CustomPagingViewController(pages: pageVCs)
        vc.pageDelegate = self
        return vc
    }()
    
    private var spotViewController: CryptoListViewController = {
        let vc = CryptoListViewController()
        vc.view.backgroundColor = .red
        return vc
    }()
    
    private var futureViewController: CryptoListViewController = {
        let vc = CryptoListViewController()
        vc.view.backgroundColor = .blue
        return vc
    }()
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)
        view.addSubview(segmentedControl)
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(100)
        }
    }
    
    private func getVC(_ page: ViewModel.Page) -> UIViewController {
        switch page {
        case .spot:
            return spotViewController
        case .futures:
            return futureViewController
        }
    }

    @objc
    private func segmentedControlChanged(sender: UISegmentedControl) {
        pageViewController.move(to: sender.selectedSegmentIndex)
    }

}

extension ViewController: CustomPagingViewControllerDelegate {
    func didPageChange(index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
}

