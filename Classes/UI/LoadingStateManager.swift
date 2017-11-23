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

/// Protocol for a view controller containing a loading state manager
public protocol LoadableViewController {
    var loadingManager: LoadingStateManager { get }
}

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
    open var loadingLabel: UILabel {
        return loadingView.titleLabel
    }

    /// The no content view.
    ///
    /// This stack view is lazily loaded as needed. You can adjust the internal
    /// views for whatever effect you like, adding views etc where appropriate.
    open private(set) lazy var noContentView: NoContentView = { [unowned self] in
        self.noContentViewLoaded = true
        return NoContentView(frame: .zero)
    }()

    /// The loading view.
    ///
    /// This stack view is lazily loaded as needed. You can adjust the internal
    /// views for whatever effect you like, adding views etc where appropriate.
    open private(set) lazy var loadingView: LoadingView = { [unowned self] in
        self.loadingViewLoaded = true
        return LoadingView(frame: .zero)
    }()

    
    /// The color for the labels.
    @available(*, deprecated, message: "Single color is no longer used for all UI elements")
    @NSCopying open var noContentColor: UIColor! = .gray {
        didSet {
            if noContentColor == nil {
                noContentColor = .gray
            }
            if noContentViewLoaded {
                noContentView.titleLabel.textColor = noContentColor
                noContentView.subtitleLabel.textColor = noContentColor
            }
            if loadingViewLoaded {
                loadingView.titleLabel.textColor = noContentColor
                loadingView.subtitleLabel.textColor = noContentColor
                loadingView.loadingIndicatorView.color = noContentColor
            }
        }
    }

    // MARK: - Private properties
    
    private lazy var traitTrackerView: TraitCollectionTracker = { [unowned self] in
        let tracker = TraitCollectionTracker(frame: .zero)
        tracker.isHidden = true
        tracker.delegate = self
        return tracker
    }()
    
    private var containerScrollView: UIScrollView?
    
    private var containerInsetManager: ScrollViewInsetManager?
    
    private var containerWidthConstraint: NSLayoutConstraint?
    
    private var containerGuide: AnyObject? // on iOS 11+, this is the contentLayoutGuide. on iOS 10, it is a UIView.
    
    private var contentInsetGuide: UILayoutGuide?
    
    private var contentInsetLeftConstraint: NSLayoutConstraint?
    
    private var contentInsetRightConstraint: NSLayoutConstraint?
    
    private var contentInsetTopConstraint: NSLayoutConstraint?
    
    private var contentInsetBottomConstraint: NSLayoutConstraint?
    
    private var noContentViewLoaded: Bool = false
    
    private var loadingViewLoaded: Bool = false
    
    
    // MARK: - Private methods

    /// Return the container view for the given state
    private func containerViewForState(_ state: LoadingStateManager.State) -> UIStackView? {
        switch state {
        case .loading:
            return loadingView
        case .noContent:
            return noContentView
        default:
            return nil
        }
    }

    private func updateViewState() {
        // Update loading indicator
        if state == .loading {
            loadingView.loadingIndicatorView.play()
        } else if loadingViewLoaded {
            loadingView.loadingIndicatorView.stop()
        }

        if state == .loaded {
            // Cleanup views and return
            containerScrollView?.removeFromSuperview()
            containerScrollView = nil
            containerInsetManager = nil
            containerWidthConstraint = nil
            containerGuide = nil
            contentView?.isHidden = false
            return
        } else {
            // Hide content view and add container view for state
            contentView?.isHidden = true
        }

        guard let baseView = self.baseView, let contentInsetGuide = self.contentInsetGuide else { return }

        // Load the stack view for the current state
        let stackView: UIStackView! = containerViewForState(state)

        let scrollView: UIScrollView
        let contentGuide: AnyObject
        var constraints: [NSLayoutConstraint]

        if let currentScrollView = containerScrollView, let containerGuide = self.containerGuide {
            scrollView = currentScrollView
            contentGuide = containerGuide

            constraints = []
        } else {
            scrollView = UIScrollView(frame: baseView.bounds)
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            if #available(iOS 11, *) {
                scrollView.contentInsetAdjustmentBehavior = .always

                let contentLayoutGuide = scrollView.contentLayoutGuide
                constraints = [ contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor) ]
                contentGuide = contentLayoutGuide
            } else {
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
            }

            for view in scrollView.subviews {
                if view != contentGuide as? UIView {
                    view.removeFromSuperview()
                }
            }
            stackView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(stackView)

            constraints += [
                NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: contentGuide, attribute: .centerX),
                NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: contentGuide, attribute: .centerY),
                NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: scrollView.readableContentGuide, attribute: .leading),
                NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: contentGuide, attribute: .top, constant: 40.0),
            ]

            containerWidthConstraint = stackView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.readableContentGuide.widthAnchor, multiplier: 0.7).withPriority(UILayoutPriority.defaultHigh)

            if baseView.traitCollection.horizontalSizeClass != .compact {
                constraints.append(containerWidthConstraint!)
            }

            containerScrollView = scrollView
            containerInsetManager = ScrollViewInsetManager(scrollView: scrollView)
            updateContentInsets()
        }

        if let contentView = self.contentView, let indexOfContentView = baseView.subviews.index(of: contentView) {
            baseView.insertSubview(scrollView, at: indexOfContentView)
        } else {
            baseView.addSubview(scrollView)
        }

        containerGuide = contentGuide
        // when we constraint to make sure the content area stays at least full height for the screen,
        // leave a little off to keep the content appearing a little north of the center. Humans see
        // center as looking a little low on the screen - it's a psychological thing!
        constraints.append(NSLayoutConstraint(item: contentGuide, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: contentInsetGuide, attribute: .height, constant: (contentAdjustmentFromCenterY * 2.0)))

        NSLayoutConstraint.activate(constraints)
    }
    
    private func switchBaseViews(from fromView: UIView?, to newView: UIView?) {
        assert(fromView != newView, "`fromView` must not be the same view as `toView`.")
        
        if let contentInsetGuide = self.contentInsetGuide {
            fromView?.removeLayoutGuide(contentInsetGuide)
        }
        containerScrollView?.removeFromSuperview()
        traitTrackerView.removeFromSuperview()
        
        if let newView = newView {
            newView.insertSubview(traitTrackerView, at: 0)
            
            let contentInsetGuide = self.contentInsetGuide ?? UILayoutGuide()
            self.contentInsetGuide = contentInsetGuide
            newView.addLayoutGuide(contentInsetGuide)
            
            contentInsetLeftConstraint = contentInsetGuide.leftAnchor.constraint(equalTo: newView.safeAreaOrFallbackLeftAnchor, constant: contentInsets.left)
            contentInsetRightConstraint = contentInsetGuide.rightAnchor.constraint(equalTo: newView.safeAreaOrFallbackRightAnchor, constant: -contentInsets.right)
            contentInsetTopConstraint = contentInsetGuide.topAnchor.constraint(equalTo: newView.safeAreaOrFallbackTopAnchor, constant: contentInsets.bottom)
            contentInsetBottomConstraint = contentInsetGuide.bottomAnchor.constraint(equalTo: newView.safeAreaOrFallbackBottomAnchor, constant: -contentInsets.bottom).withPriority(UILayoutPriority.defaultHigh)

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
        
        containerInsetManager?.standardContentInset = insets
        containerInsetManager?.standardIndicatorInset = insets
    }
    
    fileprivate func traitCollectionTracker(_ tracker: TraitCollectionTracker, traitCollectionDidChange previousTraitCollection: UITraitCollection?) {
        containerWidthConstraint?.isActive = baseView?.traitCollection.horizontalSizeClass ?? .regular == .regular
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

