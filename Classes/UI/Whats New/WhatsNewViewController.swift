//
//  WhatsNewViewController.swift
//  Pods
//
//  Created by Megan Efron on 8/8/17.
//
//

import UIKit
import Foundation

/// Class containing UIPageViewController to scroll horizontally through What's New content.
/// Can be initalized with `[WhatsNewDetailItem]` where a standard MPOL `WhatsNewViewController`
/// will be created on the fly, populated with the item's details and then cached.
/// Or for more customization, `WhatsNewViewController` can also be initalized with `[UIViewController]`
/// where each page of the `UIPageViewController` will display as each VC in the array provided.
open class WhatsNewViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Public Properties
    
    public weak var delegate: WhatsNewViewControllerDelegate?
    
    public var isSkippable: Bool = true {
        didSet {
            updateButton(hide: !isSkippable && self.currentIndex != lastIndex, animated: false)
        }
    }
    
    public var theme: WhatsNewTheme {
        didSet {
            applyTheme()
        }
    }

    // MARK: - Internal Properties
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let viewControllers: NSOrderedSet
    private let pageControl = UIPageControl()
    private let doneButton = UIButton(type: .custom)
    
    private var whatsNewDetailViewControllers: [WhatsNewDetailViewController]? {
        return viewControllers.array as? [WhatsNewDetailViewController]
    }
    
    private lazy var backgroundImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView(image: self.theme.backgroundImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    public required init(items: [WhatsNewDetailItem], theme: WhatsNewTheme = WhatsNewTheme()) {
        var viewControllers: [WhatsNewDetailViewController] = []
        for item in items {
            viewControllers.append(WhatsNewDetailViewController(item: item, theme: theme))
        }
        self.viewControllers = NSOrderedSet(array: viewControllers)
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Initialize with custom view controllers.
    /// - Important: Make sure you test that the content inside the view controllers 
    ///              don't overlap with the page view controllers buttons and page control.
    public required init(viewControllers: [UIViewController], theme: WhatsNewTheme = WhatsNewTheme()) {
        self.viewControllers = NSOrderedSet(array: viewControllers)
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup page VC
        pageViewController.setViewControllers([viewController(at: 0)!], direction: .forward, animated: false, completion: nil)
        pageViewController.view.frame = view.frame
        pageViewController.dataSource = self
        pageViewController.delegate = self
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = viewControllers.count
        pageControl.sizeToFit()
        view.addSubview(pageControl)
        
        doneButton.translatesAutoresizingMaskIntoConstraints  = false
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
        doneButton.addTarget(self, action: #selector(doneButtonTapped(button:)), for: .touchUpInside)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -5),
            
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 32),
            doneButton.widthAnchor.constraint(equalToConstant: 166)
        ])
        
        applyTheme()
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewControllers.index(of: viewController)
        return self.viewController(at: index - 1)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewControllers.index(of: viewController)
        return self.viewController(at: index + 1)
    }
    
    
    // MARK: - UIPageViewControllerDelegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        // Update page control
        pageControl.layer.add(CATransition(), forKey: nil)
        pageControl.currentPage = currentIndex
        
        // Update button
        if isSkippable {
            // Update text from skip to done from theme
            if currentIndex == lastIndex {
                updateButton(done: true, animated: true)
            } else if index(of: previousViewControllers.first!) == lastIndex {
                updateButton(done: false, animated: true)
            }
        } else {
            // Hide or show button
            let shouldHide = currentIndex != lastIndex
            if doneButton.isHidden != shouldHide {
                updateButton(hide: shouldHide, animated: true)
            }
        }
    }
    
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped(button: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if let delegate = delegate {
            delegate.whatsNewViewControllerDidTapDoneButton(self)
        }
    }
    
    
    // MARK: - Internal
    
    private func updateButton(done: Bool, animated: Bool) {
        if animated {
            doneButton.layer.add(CATransition(), forKey: nil)
        }
        
        if done {
            doneButton.setTitle(theme.buttonDoneText, for: .normal)
            doneButton.setTitleColor(theme.buttonDoneTextColor, for: .normal)
            doneButton.setBackgroundImage(UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 1.0, borderColor: theme.buttonDoneBorderColor, fillColor: theme.buttonDoneBackgroundColor), for: .normal)
        } else {
            doneButton.setTitle(theme.buttonSkipText, for: .normal)
            doneButton.setTitleColor(theme.buttonSkipTextColor, for: .normal)
            doneButton.setBackgroundImage(UIImage.resizableRoundedImage(cornerRadius: 4.0, borderWidth: 1.0, borderColor: theme.buttonSkipBorderColor, fillColor: theme.buttonSkipBackgroundColor), for: .normal)
        }
    }
    
    private func updateButton(hide: Bool, animated: Bool) {
        if animated {
            doneButton.layer.add(CATransition(), forKey: nil)
        }
        doneButton.isHidden = hide
    }
    
    private func applyTheme() {
        view.backgroundColor = theme.backgroundColor
        
        if let backgroundImage = theme.backgroundImage {
            backgroundImageView.image = backgroundImage
        }
        
        updateButton(done: !isSkippable || currentIndex == lastIndex, animated: false)
        doneButton.titleLabel?.font = theme.buttonFont
        
        pageControl.currentPageIndicatorTintColor = theme.pageControlCurrentTintColor
        pageControl.pageIndicatorTintColor = theme.pageControlTintColor
        
        // Update each detail VC with font and textColor
        if let viewControllers = whatsNewDetailViewControllers {
            for viewController in viewControllers {
                viewController.theme = theme
            }
        }
    }
    
    private var currentViewController: UIViewController? {
        return pageViewController.viewControllers?.first
    }
    
    private var currentIndex: Int {
        return viewControllers.index(of: currentViewController)
    }
    
    private var lastIndex: Int {
        return viewControllers.count - 1
    }
    
    private func viewController(at index: Int) -> UIViewController? {
        guard index >= 0, index < viewControllers.count else { return nil }
        return viewControllers[index] as! UIViewController
    }
    
    private func index(of viewController: UIViewController) -> Int {
        return viewControllers.index(of: viewController)
    }
    
}

public protocol WhatsNewViewControllerDelegate: NSObjectProtocol {
    func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController)
}

public extension WhatsNewViewControllerDelegate {
    func whatsNewViewControllerDidTapDoneButton(_ whatsNewViewController: WhatsNewViewController) { }
}
