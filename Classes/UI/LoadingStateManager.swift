//
//  LoadingStateManager.swift
//  MPOLKit
//
//  Created by Rod Brown on 23/7/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

// The preferred adjustment content is from the center Y when not displaying content.
fileprivate let contentAdjustmentFromCenterY: CGFloat = -16.0

/// A manager for a loading view on a base view.
open class LoadingStateManager: TraitCollectionTrackerDelegate {
    
    /// The load state within a `LoadingStateManager`.
    public enum State {
        
        /// The content is loaded. The loading and no content views are hidden.
        case loaded
        
        /// The content is loading. A loading spinner and the loading label are shown.
        case loading
        
        /// The content failed to load, or there was no content for some reason. The
        /// no content stack view is shown.
        case noContent
    }
    
    
    // MARK: - Public properties
    
    /// The current state of the manager. The default is ".loaded".
    open var state: State = .loaded {
        didSet {
            if state != oldValue && baseView != nil {
                updateViewState()
            }
        }
    }
    
    
    /// The base view.
    ///
    /// This is the view the content, loading, and no content views will be
    /// shown on.
    open var baseView: UIView? {
        didSet {
            if baseView != oldValue {
                switchBaseViews(from: oldValue, to: baseView)
            }
        }
    }
    
    
    /// The normal content view.
    ///
    /// This view is managed externally, and will be hidden/shown when required.
    /// It is expected that the content view is a subview of the base view.
    open var contentView: UIView? {
        didSet {
            if contentView != oldValue {
                oldValue?.isHidden = false
                contentView?.isHidden = state != .loaded
            }
        }
    }
    
    
    /// The content insets to apply to the loading and no content views.
    ///
    /// Prior to iOS 11, this should include any topLayoutGuides and
    /// bottomLayoutGuides. On iOS 11 and later, these are handled by the safe
    /// area insets, and the content insets are treated as insets *from* the
    /// safe area.
    ///
    /// - Note: These insets only apply to the loading and no content views.
    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            if baseView != nil {
                updateContentInsets()
            }
        }
    }
    
    
    /// The loading label.
    open private(set) lazy var loadingLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = NSLocalizedString("Loading", bundle: .mpolKit, comment: "Default Loading Title")
        label.textColor = self.noContentColor
        
        var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        if let adjusted = fontDescriptor.withSymbolicTraits(.traitBold) {
            fontDescriptor = adjusted
        }
        label.font = UIFont(descriptor: fontDescriptor, size: 0.0)
        
        return label
    }()
    
    
    /// The no content view.
    ///
    /// This stack view is lazily loaded as needed. You can adjust the internal
    /// views for whatever effect you like, adding views etc where appropriate.
    open private(set) lazy var noContentView: NoContentView = { [unowned self] in
        self.noContentViewLoaded = true
        return NoContentView(frame: .zero)
    }()
    
    
    /// The color for the labels.
    @NSCopying open var noContentColor: UIColor! = .gray {
        didSet {
            if noContentColor == nil {
                noContentColor = .gray
            }
            if noContentViewLoaded {
                noContentView.titleLabel.textColor = noContentColor
                noContentView.subtitleLabel.textColor = noContentColor
            }
            if loadingLabelLoaded {
                loadingLabel.textColor = noContentColor
            }
            loadingIndicatorView?.color = noContentColor
        }
    }
    
    
    // MARK: - Private properties
    
    private lazy var traitTrackerView: TraitCollectionTracker = { [unowned self] in
        let tracker = TraitCollectionTracker(frame: .zero)
        tracker.isHidden = true
        tracker.delegate = self
        return tracker
    }()
    
    private var noContentScrollView: UIScrollView?
    
    private var noContentInsetManager: ScrollViewInsetManager?
    
    private var noContentRegularConstraint: NSLayoutConstraint?
    
    private var noContentGuide: Any? // on iOS 11+, this is the contentLayoutGuide. on iOS 10, it is a UIView.
    
    private var loadingIndicatorView: UIActivityIndicatorView?
    
    private var loadingStackView: UIStackView?
    
    private var contentInsetGuide: UILayoutGuide?
    
    private var contentInsetLeftConstraint: NSLayoutConstraint?
    
    private var contentInsetRightConstraint: NSLayoutConstraint?
    
    private var contentInsetTopConstraint: NSLayoutConstraint?
    
    private var contentInsetBottomConstraint: NSLayoutConstraint?
    
    private var noContentViewLoaded: Bool = false
    
    private var loadingLabelLoaded: Bool = false
    
    
    // MARK: - Private methods
    
    private func updateViewState() {
        if state != .loading {
            loadingIndicatorView?.stopAnimating()
            loadingStackView?.removeFromSuperview()
            loadingIndicatorView = nil
            loadingStackView = nil
        }
        if state != .noContent {
            noContentScrollView?.removeFromSuperview()
            noContentScrollView = nil
            noContentInsetManager = nil
            noContentRegularConstraint = nil
            noContentGuide = nil
        }
        contentView?.isHidden = state != .loaded
        
        guard let baseView = self.baseView, let contentInsetGuide = self.contentInsetGuide else { return }
        
        switch state {
        case .loaded:
            // Views have been shown and removed as necessary.
            break
        case .loading:
            let loadingStackView: UIStackView
            
            if let currentStackView = self.loadingStackView {
                loadingStackView = currentStackView
            } else {
                let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                loadingIndicatorView.color = noContentColor
                loadingIndicatorView.startAnimating()
                
                loadingStackView = UIStackView(arrangedSubviews: [loadingIndicatorView, loadingLabel])
                loadingStackView.translatesAutoresizingMaskIntoConstraints = false
                loadingStackView.axis = .vertical
                loadingStackView.alignment = .center
                loadingStackView.spacing = 12.0
                
                self.loadingStackView = loadingStackView
                self.loadingIndicatorView = loadingIndicatorView
            }
            
            
            if let contentView = self.contentView, let indexOfContentView = baseView.subviews.index(of: contentView) {
                baseView.insertSubview(loadingStackView, at: indexOfContentView)
            } else {
                baseView.addSubview(loadingStackView)
            }
            
            NSLayoutConstraint.activate([
                loadingStackView.centerYAnchor.constraint(equalTo: contentInsetGuide.centerYAnchor, constant: contentAdjustmentFromCenterY),
                loadingStackView.leadingAnchor.constraint(greaterThanOrEqualTo: baseView.readableContentGuide.leadingAnchor),
                loadingStackView.widthAnchor.constraint(lessThanOrEqualTo: baseView.readableContentGuide.widthAnchor),
                loadingStackView.centerXAnchor.constraint(equalTo: baseView.centerXAnchor)
            ])
        case .noContent:
            
            let scrollView: UIScrollView
            let contentGuide: Any
            
            var constraints: [NSLayoutConstraint]
            
            if let currentScrollView = noContentScrollView, let noContentGuide = self.noContentGuide {
                scrollView = currentScrollView
                contentGuide = noContentGuide
                
                constraints = []
            } else {
                scrollView = UIScrollView(frame: baseView.bounds)
                scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                // TODO: Uncomment for iOS 11
//                if #available(iOS 11, *) {
//                    scrollView.contentInsetAdjustmentBehavior = .always
//
//                    let contentLayoutGuide = scrollView.contentLayoutGuide
//                    constraints = [ contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor) ]
//                    contentGuide = contentLayoutGuide
//                } else {
                    let contentSizingView = UIView(frame: .zero)
                    contentSizingView.translatesAutoresizingMaskIntoConstraints = false
                    contentSizingView.isHidden = true
                    scrollView.addSubview(contentSizingView)
                    
                    constraints = [
                        contentSizingView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                        contentSizingView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                        contentSizingView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                        contentSizingView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                        contentSizingView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                    ]
                    contentGuide = contentSizingView
//                }
                
                let noContentView = self.noContentView
                noContentView.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(noContentView)
                
                constraints += [
                    NSLayoutConstraint(item: noContentView, attribute: .centerX, relatedBy: .equal, toItem: contentGuide, attribute: .centerX),
                    NSLayoutConstraint(item: noContentView, attribute: .centerY, relatedBy: .equal, toItem: contentGuide, attribute: .centerY),
                    NSLayoutConstraint(item: noContentView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: scrollView.readableContentGuide, attribute: .leading),
                    NSLayoutConstraint(item: noContentView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: contentGuide, attribute: .top, constant: 40.0),
                ]
                
                noContentRegularConstraint = noContentView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.readableContentGuide.widthAnchor, multiplier: 0.7).withPriority(UILayoutPriorityDefaultHigh)
                
                if baseView.traitCollection.horizontalSizeClass != .compact {
                    constraints.append(noContentRegularConstraint!)
                }
                
                noContentScrollView = scrollView
                noContentInsetManager = ScrollViewInsetManager(scrollView: scrollView)
                updateContentInsets()
            }
            
            if let contentView = self.contentView, let indexOfContentView = baseView.subviews.index(of: contentView) {
                baseView.insertSubview(scrollView, at: indexOfContentView)
            } else {
                baseView.addSubview(scrollView)
            }
            
            noContentGuide = contentGuide
            // when we constraint to make sure the content area stays at least full height for the screen,
            // leave a little off to keep the content appearing a little north of the center. Humans see
            // center as looking a little low on the screen - it's a psychological thing!
            constraints.append(NSLayoutConstraint(item: contentGuide, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: contentInsetGuide, attribute: .height, constant: (contentAdjustmentFromCenterY * 2.0)))
            
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    private func switchBaseViews(from fromView: UIView?, to newView: UIView?) {
        assert(fromView != newView, "`fromView` must not be the same view as `toView`.")
        
        if let contentInsetGuide = self.contentInsetGuide {
            fromView?.removeLayoutGuide(contentInsetGuide)
        }
        noContentScrollView?.removeFromSuperview()
        loadingStackView?.removeFromSuperview()
        traitTrackerView.removeFromSuperview()
        
        if let newView = newView {
            newView.insertSubview(traitTrackerView, at: 0)
            
            let contentInsetGuide = self.contentInsetGuide ?? UILayoutGuide()
            self.contentInsetGuide = contentInsetGuide
            newView.addLayoutGuide(contentInsetGuide)
            // TODO: Uncomment for iOS 11
//            if #available(iOS 11, *) {
//                let newSafeAreaGuide = newView.safeAreaLayoutGuide
//                contentInsetLeftConstraint = contentInsetGuide.leftAnchor.constraint(equalTo: newSafeAreaGuide.leftAnchor, constant: contentInsets.left)
//                contentInsetRightConstraint = contentInsetGuide.rightAnchor.constraint(equalTo: newSafeAreaGuide.rightAnchor, constant: -contentInsets.right)
//                contentInsetTopConstraint = contentInsetGuide.topAnchor.constraint(equalTo: newSafeAreaGuide.topAnchor, constant: contentInsets.bottom)
//                contentInsetBottomConstraint = contentInsetGuide.bottomAnchor.constraint(equalTo: newSafeAreaGuide.bottomAnchor, constant: -contentInsets.bottom)
//            } else {
                contentInsetLeftConstraint = contentInsetGuide.leftAnchor.constraint(equalTo: newView.leftAnchor, constant: contentInsets.left)
                contentInsetRightConstraint = contentInsetGuide.rightAnchor.constraint(equalTo: newView.rightAnchor, constant: -contentInsets.right)
                contentInsetTopConstraint = contentInsetGuide.topAnchor.constraint(equalTo: newView.topAnchor, constant: contentInsets.bottom)
                contentInsetBottomConstraint = contentInsetGuide.bottomAnchor.constraint(equalTo: newView.bottomAnchor, constant: -contentInsets.bottom)
                contentInsetBottomConstraint!.priority = UILayoutPriorityDefaultHigh
//            }
            
            NSLayoutConstraint.activate([
                contentInsetLeftConstraint!,
                contentInsetRightConstraint!,
                contentInsetTopConstraint!,
                contentInsetBottomConstraint!
            ])
        } else {
            contentInsetGuide = nil
            contentInsetLeftConstraint = nil
            contentInsetRightConstraint = nil
            contentInsetTopConstraint = nil
            contentInsetBottomConstraint = nil
        }
        
        updateViewState()
    }
    
    private func updateContentInsets() {
        let insets = contentInsets
        
        contentInsetLeftConstraint?.constant = insets.left
        contentInsetRightConstraint?.constant = -insets.right
        contentInsetTopConstraint?.constant = insets.top
        contentInsetBottomConstraint?.constant = -insets.bottom
        
        noContentInsetManager?.standardContentInset = insets
        noContentInsetManager?.standardIndicatorInset = insets
    }
    
    fileprivate func traitCollectionTracker(_ tracker: TraitCollectionTracker, traitCollectionDidChange previousTraitCollection: UITraitCollection?) {
        noContentRegularConstraint?.isActive = baseView?.traitCollection.horizontalSizeClass ?? .regular == .regular
    }
    
}

/// A private class so we can detect when the trait collection changes on the view.
fileprivate class TraitCollectionTracker: UIView {
    
    weak var delegate: TraitCollectionTrackerDelegate?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        delegate?.traitCollectionTracker(self, traitCollectionDidChange: previousTraitCollection)
    }
    
}

fileprivate protocol TraitCollectionTrackerDelegate: class {
    
    func traitCollectionTracker(_ tracker: TraitCollectionTracker, traitCollectionDidChange previousTraitCollection: UITraitCollection?)
    
}

