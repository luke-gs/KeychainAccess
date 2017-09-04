//
//  ScrollAwarePageViewController.swift
//  Alamofire
//
//  Created by Trent Fitzgibbon on 4/9/17.
//

import UIKit

/// Subclass of UIPageViewController that observes changes to the content offset of the scroll view and notifies delegate
open class ScrollAwarePageViewController: UIPageViewController {

    /// The scroll delegate
    open weak var scrollDelegate: UIScrollViewDelegate?

    /// Context for KVO observing
    private var kvoContext = 0

    /// The page view controller's scrollview
    private var scrollView: UIScrollView?

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Find the child scrollview
        for subView in view.subviews {
            if let scrollView = subView as? UIScrollView {
                self.scrollView = scrollView
                scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &kvoContext)
            }
        }
    }

    deinit {
        scrollView?.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), context: &kvoContext)
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &kvoContext {
            if let scrollView = scrollView, let scrollDelegate = scrollDelegate, keyPath == #keyPath(UIScrollView.contentOffset), isViewLoaded {
                scrollDelegate.scrollViewDidScroll!(scrollView)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
