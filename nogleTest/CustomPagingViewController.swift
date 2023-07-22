//
//  CustomPagingViewController.swift
//  nogleTest
//
//  Created by 杜襄 on 2023/7/22.
//

import UIKit

protocol CustomPagingViewControllerDelegate: AnyObject {
    func didPageChange(index: Int)
}

class CustomPagingViewController: UIPageViewController {
    // MARK: Lifecycle

    init(pages: [UIViewController]) {
        self.pages = pages
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    weak var pageDelegate: CustomPagingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if pages.indices.contains(0) {
            setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        }
    }

    func move(to index: Int) {
        guard pages.indices.contains(index) else { return }

        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse

        setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
        pageDelegate?.didPageChange(index: index)
    }

    func reload(pages: [UIViewController]) {
        if pages.indices.contains(0) {
            self.pages = pages
            setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        }
    }

    func removeSwipeGesture() {
        view.subviews.forEach { view in
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
                return
            }
        }
    }

    // MARK: Private

    private var pages: [UIViewController]

    private var currentIndex: Int {
        guard let vc = viewControllers?.first else { return 0 }
        return pages.firstIndex(of: vc) ?? 0
    }
}

extension CustomPagingViewController: UIPageViewControllerDelegate {
    func pageViewController(_: UIPageViewController, didFinishAnimating _: Bool, previousViewControllers _: [UIViewController], transitionCompleted _: Bool) {
        guard let currentViewController = viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController) else { return }

        pageDelegate?.didPageChange(index: currentIndex)
    }
}

extension CustomPagingViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex: Int = pages.firstIndex(of: viewController) else { return nil }

        let priviousIndex: Int = currentIndex - 1
        return priviousIndex < 0 ? nil : pages[priviousIndex]
    }

    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex: Int = pages.firstIndex(of: viewController) else { return nil }

        let nextIndex: Int = currentIndex + 1
        return nextIndex > pages.count - 1 ? nil : pages[nextIndex]
    }
}
