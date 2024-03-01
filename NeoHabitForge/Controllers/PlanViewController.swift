//
//  PlanViewController.swift
//  NeoHabitForge
//
//  Created by Диас Сайынов on 28.02.2024.

import UIKit
import SnapKit

class PlanViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, TimePickerViewControllerDelegate, GoalsViewControllerDelegate {
    
    lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    
    lazy var pages: [UIViewController] = [
        Page1ViewController(),
        Page2ViewController(),
        GoalsViewController(),
        HabitsViewController(),
    ]
    
    private var currentPageIndex = 0
    
    private let pageIndicatorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        view.addSubview(pageIndicatorStackView)
        pageIndicatorStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
    }
    
    func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.frame = view.bounds
        
        if let firstViewController = pages.first {
            pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        for view in pageViewController.view.subviews {
            if let pageControl = view as? UIPageControl {
                pageControl.isHidden = true
                break
            }
        }
        
        for page in pages {
            if let customPage = page as? TimePickerViewController {
                customPage.delegate = self
            }
            if let goalsViewController = page as? GoalsViewController {
                goalsViewController.delegate = self
            }
        }

        setupPageIndicator()
    }
    
    func nextPageRequested() {
        guard let currentViewController = pageViewController.viewControllers?.first,
                let currentIndex = pages.firstIndex(of: currentViewController) else {
            return
        }
            
        let nextIndex = min(currentIndex + 1, pages.count - 1)
        let nextViewController = pages[nextIndex]
        self.currentPageIndex = nextIndex
        updatePageIndicator()
        pageViewController.setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard pages.count > previousIndex else {
            return nil
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return nil
        }
        guard pages.count > nextIndex else {
            return nil
        }
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: firstViewController) else {
            return 0
        }
        return index
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let currentViewController = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: currentViewController) else {
            return
        }
        currentPageIndex = index
        updatePageIndicator()
    }

    // Setup custom page indicator
    private func setupPageIndicator() {
        for _ in pages {
            let indicatorView = UIView()
            indicatorView.backgroundColor = .gray
            indicatorView.layer.cornerRadius = 2
            pageIndicatorStackView.addArrangedSubview(indicatorView)
            indicatorView.snp.makeConstraints { make in
                make.width.equalTo(60)
                make.height.equalTo(8)
            }
        }
        updatePageIndicator()
    }
    
    private func updatePageIndicator() {
        for (index, subview) in pageIndicatorStackView.arrangedSubviews.enumerated() {
            guard let indicatorView = subview as? UIView else {
                continue
            }
            
            if index <= currentPageIndex {
                indicatorView.backgroundColor = .green
            } else {
                indicatorView.backgroundColor = .gray
            }
        }
    }
}



class Page1ViewController: TimePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "В какое время вы обычно просыпаетесь?"
        subTitleLabel.text = "Выберите ваше обычное время подъема"
        
        datePicker.selectRow(8 + 24 * 50, inComponent: 0, animated: false)
        datePicker.selectRow(0 + 60 * 50, inComponent: 1, animated: false)
    }
}

class Page2ViewController: TimePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "В какое время вы обычно ложитесь спать?"
        subTitleLabel.text = "Ваше завершение дня"
        
        datePicker.selectRow(23 + 24 * 50, inComponent: 0, animated: false)
        datePicker.selectRow(0 + 60 * 50, inComponent: 1, animated: false)
    }
}
