//
//  ScrollViewInsetManager.swift
//  MPOLKit
//
//  Created by Rod Brown on 12/02/2017.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// The `ScrollViewInsetManager` manages insets on a scroll view, adding extra scrolling room
/// when a keyboard is present. Users update the standard insets when required, and the manager
/// handles adjusting the content to handle the keyboard where approrpriate.
///
/// `UIScrollView` does not adjust itself to compensate for the location of a keyboard on the 
/// screen.  When a keyboard appears, best practice on iOS is to adjust the insets of the scroll
/// view to allow scrolling beyond the content area. This allows the scroll view to appear blurred
/// behind the keyboard in it's standard position, but gives it the ability to behave as if there
/// is extra content and avoid "rubber banding" effects until it is beyond that portion of the
/// screen.
///
/// `ScrollViewInsetManager` is designed to handle keyboard actions that require updating in
/// unusual ways. This includes navigation actions, where the scroll view updates should be
/// performed after the keyboard action finishes, and rotation events, where updates should
/// wait until all rotations have completed.
public final class ScrollViewInsetManager: NSObject {
    
    // MARK: - Public properties
    
    /// The scroll view the manager is updating.
    public let scrollView: UIScrollView
    
    
    /// The standard content insets for the scroll view.
    ///
    /// This is the minimum inset that the scroll view. When the keyboard appears above the scroll
    /// view, the insets are adjusted to allow the scroll view to scroll up, and allow access to
    /// the content.
    ///
    /// Adjusting this property automatically adjusts the scroll view insets appropriately.
    public var standardContentInset: UIEdgeInsets {
        didSet {
            if delayResetUntilComplete == false {
                updateContentInset(oldInset: oldValue)
            }
        }
    }
    
    
    /// The standard scroll indicator insets for the scroll view.
    ///
    /// This is the minimum inset that the scroll view. When the keyboard appears above the scroll
    /// view, the insets are adjusted to allow the scroll view to scroll up, and allow access to
    /// the content.
    ///
    /// Adjusting this property automatically adjusts the scroll indicator insets appropriately.
    public var standardIndicatorInset: UIEdgeInsets {
        didSet {
            if delayResetUntilComplete == false {
                updateIndicatorInset()
            }
        }
    }
    
    
    // MARK: - Private properties
    
    /// The keyboard frame in the screen bounds. We hold this value as a point of reference
    /// as to allow adjusting the insets at any time.
    private var keyboardFrameInScreen: CGRect? = nil
    
    
    /// A boolean value indicating that we updating the scroll view is being delayed until
    /// the keyboard dismisses.
    private var delayResetUntilComplete = false
    
    
    // MARK: - Initializer
    
    /// Initializes the manager with it's scroll view.
    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        
        standardContentInset   = scrollView.contentInset
        standardIndicatorInset = scrollView.scrollIndicatorInsets
        
        super.init()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidShow(_:)),  name: .UIKeyboardDidShow,  object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)),  name: .UIKeyboardDidHide,  object: nil)
    }
    
    
    // MARK: - Public methods
    
    /// Updates the insets for the keyboard manually.
    /// 
    /// You should not need to call this method directly, except when the view has been
    /// moved while the keyboard is onscreen. This updates the insets to account for the
    /// keyboard's position in relation to the scroll view's current position.
    public func updateInsets() {
        updateContentInset(oldInset: nil)
        updateIndicatorInset()
    }
    
    private func updateContentInset(oldInset: UIEdgeInsets?) {
        /// adjust insets if required to account for keyboard location.
        var contentInset = standardContentInset
        
        if let keyboardFrameInScreen = keyboardFrameInScreen {
            // Keyboard exists.
            let keyboardFrame = scrollView.convert(keyboardFrameInScreen, from: nil)
            
            // Work out how far inset the is (if there is one), and try to inset. Don't inset less than the initial insets.
            let bottomInset       = max((scrollView.bounds.maxY - keyboardFrame.minY), 0.0)
            contentInset.bottom   = max(bottomInset, contentInset.bottom)
        }
        
        if scrollView.refreshControl?.isRefreshing ?? false {
            // when a refresh control is refreshing, it has adjusted the top content inset and
            // it is unsafe to alter this, unless we have a reference for what changed between
            // the last and the current standard insets
            
            contentInset.top = scrollView.contentInset.top
            if let oldInset = oldInset {
                contentInset.top += standardContentInset.top - oldInset.top
            }
        }
        
        let insetChange = scrollView.contentInset.top - contentInset.top
        if insetChange !=~ 0.0 {
            scrollView.contentOffset.y += insetChange
        }
        
        scrollView.contentInset = contentInset
    }
    
    private func updateIndicatorInset() {
        var indicatorInset = standardIndicatorInset
        
        if let keyboardFrameInScreen = keyboardFrameInScreen {
            let keyboardFrame = scrollView.convert(keyboardFrameInScreen, from: UIScreen.main.coordinateSpace)
            let bottomInset       = max((scrollView.bounds.maxY - keyboardFrame.minY), 0.0)
            indicatorInset.bottom = max(bottomInset, indicatorInset.bottom)
        }
        
        scrollView.scrollIndicatorInsets = indicatorInset
    }
    
    
    
    // MARK: - Notifications
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        // Cancel any delayed content inset updates
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(resetContentInsets), object: nil)
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        keyboardFrameInScreen = notification.keyboardAnimationDetails()?.endFrame
        updateInsets()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let keyboardAnimationDetails = notification.keyboardAnimationDetails() else { return }
        
        // If the keyboard is not going to the bottom of the screen in it's hide, it will probably be part of a navigation slide. Delay inset reset.
        if keyboardAnimationDetails.endFrame.minY < UIScreen.main.bounds.maxY {
            delayResetUntilComplete = true
            return
        }
        
        delayResetUntilComplete = false
        
        // If the keyboard animation has zero duration, it's probably due to a rotation animation and it's not going to dismiss!
        // Delay inset reset, and let appearance cancel it.
        if keyboardAnimationDetails.duration ==~ 0.0 {
            let resetSelector = #selector(resetContentInsets)
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: resetSelector, object: nil)
            perform(resetSelector, with: nil, afterDelay: 1.5, inModes: [.commonModes])
            return
        }
        
        resetContentInsets()
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        if delayResetUntilComplete {
            delayResetUntilComplete = false
            resetContentInsets()
        }
    }
    
    
    // MARK: - Additional private methods
    
    @objc private func resetContentInsets() {
        keyboardFrameInScreen = nil
        updateInsets()
    }
    
}
