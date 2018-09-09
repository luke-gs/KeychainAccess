//
//  DrawerViewController.swift
//
//  Created on 25/7/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol DrawerViewControllerDelegate: class {

    /// Tells the delegate that the position of the drawer has been changed.
    ///
    /// - Parameters:
    ///   - drawerViewController: The view controller informing the delegate.
    ///   - height: The height at which the drawer is set to.
    @objc optional func drawerViewControllerPositionDidChange(_ drawerViewController: DrawerViewController, height: CGFloat)

    /// Tells the delegate that the height of the drawer has been changed.
    ///
    /// - Parameters:
    ///   - drawerViewController: The view controller informing the delegate.
    ///   - height: The height at which the drawer is set to.
    @objc optional func drawerViewControllerDrawerHeightDidChange(_ drawerViewController: DrawerViewController, height: CGFloat)

}

@objc public protocol DrawerDraggableViewControllerDelegate: DrawerViewControllerDelegate {

    /// Asks the delegate for the drawer's height when the position is `collapsed`.
    ///
    /// - Parameter drawerViewController: The view controller requesting this information.
    /// - Returns: The nonnegative floating-point value that specifies the height (in points) when the drawer is set to `collapsed`.
    @objc optional func drawerViewControllerCollapsedHeight(_ drawerViewController: DrawerViewController) -> CGFloat

    /// Asks the delegate for the drawer's height when the position is `partiallyOpen`.
    ///
    /// - Parameter drawerViewController: The view controller requesting this information.
    /// - Returns: The nonnegative floating-point value that specifies the height (in points) when the drawer is set to `partiallyOpen`.
    @objc optional func drawerViewControllerPartiallyOpenHeight(_ drawerViewController: DrawerViewController) -> CGFloat

    /// Asks the delegate for the drawer's height when the position is `open`.
    ///
    /// - Parameter drawerViewController: The view controller requesting this information.
    /// - Returns: The nonnegative floating-point value that specifies the height (in points) when the drawer is set to `open`.
    @objc optional func drawerViewControllerOpenHeight(_ drawerViewController: DrawerViewController) -> CGFloat

    /// Asks the delegate for the supported positions.
    ///
    /// - Parameter drawerViewController: The view controller requesting this information.
    /// - Returns: A list of drawer positions. If empty list is returned, the drawer view controller defaults to its supported positions.
    @objc optional func drawerViewControllerSupportedPositions(_ drawerViewController: DrawerViewController) -> [DrawerPosition]

    /// Asks the delegate if the drawer view controller should manage the root scroll view.
    ///
    /// - Note: If the delegate doesn't implement this method, `true` is assumed.
    ///
    /// - Returns: `true` to allow drawer view controller to manage the scroll view, false to disallow it.
    @objc optional func drawerViewControllerShouldManageChildScrollView() -> Bool

}

public typealias DrawerSupportedViewController = UIViewController & DrawerViewControllerDelegate
public typealias DrawerDraggableViewController = UIViewController & DrawerDraggableViewControllerDelegate
public typealias DrawerAnimationCompletionHandler = (Bool) -> ()


/// The position object for drawer. Currently only supports `collapsed`, `partiallyOpen` and `open`.
/// Subclass of `NSObject` to be used with an optional protocol method.
public class DrawerPosition: NSObject {

    /// Indicates the position at which the drawer is smallest in height.
    public static let collapsed = DrawerPosition(rawValue: 0)

    /// Indicates the position at which the drawer is between its smallest and tallest in height.
    public static let partiallyOpen = DrawerPosition(rawValue: 1)

    /// Indicates the position at which the drawer is tallest in height.
    public static let open = DrawerPosition(rawValue: 2)

    public let rawValue: Int

    private init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? DrawerPosition else { return false }
        return rawValue == object.rawValue
    }

}


/// An object that manages two other instances of view controllers.
public class DrawerViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    /// The current position of the drawer.
    public private(set) var position: DrawerPosition = .collapsed

    /// The supported positions that this drawer supports.
    /// Implements `DrawerDraggableViewControllerDelegate.drawerViewControllerSupportedPositions(_:)` to return the preferred positions.
    /// If the list changes after the initial presentation, you must call `DrawerViewController.setNeedsUpdateSupportedPositions()`.
    public private(set) var supportedPositions: [DrawerPosition] = []

    // MARK: - Appearance

    public var drawerCornerRadius: CGFloat = 16.0 {
        didSet {
            guard isViewLoaded else { return }
            updateCornerRadius()
        }
    }

    public var drawerShadowRadius: CGFloat = 2.0 {
        didSet {
            guard isViewLoaded else { return }
            drawerShadowView.layer.shadowRadius = drawerShadowRadius
        }
    }

    public var drawerShadowOpacity: Float = 0.1 {
        didSet {
            guard isViewLoaded else { return }
            drawerShadowView.layer.shadowOpacity = drawerShadowOpacity
        }
    }

    // MARK: - Default values

    private let defaultCollapsedHeight: CGFloat = 80.0
    private let defaultPartiallyOpenHeight: CGFloat = 350.0
    private let defaultOpenHeight: CGFloat = 550.0
    private let defaultSupportedPositions: [DrawerPosition] = [.collapsed, .partiallyOpen, .open]
    private let defaultAnimationDuration: TimeInterval = 0.25

    // MARK: - Controllers

    public private(set) var primaryViewController: DrawerSupportedViewController {
        willSet {
            primaryViewController.willMove(toParentViewController: nil)
            primaryViewController.view.removeFromSuperview()
            primaryViewController.removeFromParentViewController()
        }

        didSet {
            addChildViewController(primaryViewController)

            if let childView = primaryViewController.view {
                childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                primaryContentView.addSubview(childView)
            }

            primaryViewController.didMove(toParentViewController: self)

            setNeedsStatusBarAppearanceUpdate()
        }
    }

    public private(set) var secondaryViewController: DrawerDraggableViewController {
        willSet {
            secondaryViewController.willMove(toParentViewController: nil)
            secondaryViewController.view.removeFromSuperview()
            secondaryViewController.removeFromParentViewController()

            childScrollView = nil
        }

        didSet {
            addChildViewController(secondaryViewController)

            if let childView = secondaryViewController.view {
                childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                childView.frame = drawerContentView.bounds
                drawerContentView.insertSubview(childView, at: 0)

                setNeedsUpdateSupportedPositions()
                setNeedsUpdateShouldManageChildScrollView()
            }

            secondaryViewController.didMove(toParentViewController: self)
        }
    }

    // MARK: - Drawer Views

    private let primaryContentView = UIView(frame: .zero)
    private let drawerScrollView = DrawerScrollView(frame: .zero)
    private let drawerContentView = UIView(frame: .zero)
    private let drawerShadowView = UIView(frame: .zero)

    public var currentDrawerHeight: CGFloat {
        return (drawerScrollView.bounds.height - drawerContentView.frame.minY) + drawerScrollView.contentOffset.y
    }

    public var drawerSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return UIEdgeInsets(top: topLayoutGuide.length, left: 0.0, bottom: bottomLayoutGuide.length, right: 0.0)
        }
    }

    // MARK: - Pass through child view controller's preferences

    public override var childViewControllerForStatusBarStyle: UIViewController? {
        return primaryViewController
    }

    public override var childViewControllerForStatusBarHidden: UIViewController? {
        return primaryViewController
    }

    public override func childViewControllerForHomeIndicatorAutoHidden() -> UIViewController? {
        return primaryViewController
    }

    public override func childViewControllerForScreenEdgesDeferringSystemGestures() -> UIViewController? {
        return primaryViewController
    }

    /// Initialise the drawer view controller.
    ///
    /// - Parameters:
    ///   - primaryViewController: The view controller to be displayed behind the secondary view controller.
    ///   - secondaryViewController: The view controller that is draggable.
    public init(primaryViewController: DrawerSupportedViewController, secondaryViewController: DrawerDraggableViewController) {
        self.primaryViewController = primaryViewController
        self.secondaryViewController = secondaryViewController
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true

        primaryContentView.frame = view.bounds
        primaryContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(primaryContentView)

        let height = heightForPosition(.open) * view.bounds.height
        let size = CGSize(width: view.bounds.width, height: height)

        drawerShadowView.frame = CGRect(origin: .zero, size: size)
        drawerShadowView.backgroundColor = .clear
        drawerShadowView.layer.shadowColor = UIColor.black.cgColor
        drawerShadowView.layer.shadowRadius = drawerShadowRadius
        drawerShadowView.layer.shadowOpacity = drawerShadowOpacity
        drawerScrollView.addSubview(drawerShadowView)

        drawerContentView.frame = CGRect(origin: .zero, size: size)
        drawerContentView.backgroundColor = .clear

        let roundedBorderPath = UIBezierPath(roundedRect: drawerContentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: drawerCornerRadius, height: drawerCornerRadius)).cgPath
        drawerShadowView.layer.shadowPath = roundedBorderPath

        if #available(iOS 11.0, *) {
            drawerScrollView.contentInsetAdjustmentBehavior = .never
            drawerContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            drawerContentView.layer.cornerRadius = drawerCornerRadius
            drawerContentView.clipsToBounds = true
        } else {
            let roundedMaskLayer = CAShapeLayer()
            roundedMaskLayer.path = roundedBorderPath
            roundedMaskLayer.frame = drawerContentView.bounds
            roundedMaskLayer.fillColor = UIColor.white.cgColor
            roundedMaskLayer.backgroundColor = UIColor.clear.cgColor
            drawerContentView.layer.mask = roundedMaskLayer
        }

        drawerScrollView.addSubview(drawerContentView)
        drawerScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        drawerScrollView.frame = view.bounds
        drawerScrollView.contentSize = view.bounds.size
        drawerScrollView.backgroundColor = .clear

        drawerScrollView.alwaysBounceVertical = true
        drawerScrollView.bounces = false
        drawerScrollView.showsVerticalScrollIndicator = false
        drawerScrollView.showsHorizontalScrollIndicator = false
        drawerScrollView.decelerationRate = UIScrollViewDecelerationRateFast
        drawerScrollView.delaysContentTouches = true
        drawerScrollView.canCancelContentTouches = true
        drawerScrollView.drawerDelegate = self
        drawerScrollView.delegate = self
        drawerScrollView.clipsToBounds = false

        view.backgroundColor = .white
        view.addSubview(drawerScrollView)

        if let childView = primaryViewController.view {
            addChildViewController(primaryViewController)
            childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            childView.frame = view.bounds
            primaryContentView.addSubview(childView)
            primaryViewController.didMove(toParentViewController: self)
        }

        if let childView = secondaryViewController.view {
            addChildViewController(secondaryViewController)
            childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            childView.frame = drawerContentView.bounds
            drawerContentView.insertSubview(childView, at: 0)
            secondaryViewController.didMove(toParentViewController: self)

            setNeedsUpdateSupportedPositions()
            setNeedsUpdateShouldManageChildScrollView()
        }

        setPosition(position, animated: false)
        notifyDrawerHeightDidChange()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safeAreaInset: UIEdgeInsets = drawerSafeAreaInsets
        let viewSize = view.bounds.size

        let supportedHeightList = heightForSupportedPositions()

        let maximumDrawerHeight = supportedHeightList.max() ?? 0.0
        let minimumDrawerHeight = supportedHeightList.min() ?? 0.0

        drawerScrollView.scrollIndicatorInsets = safeAreaInset
        drawerScrollView.frame = CGRect(x: 0.0, y: viewSize.height - (maximumDrawerHeight + safeAreaInset.bottom), width: viewSize.width, height: maximumDrawerHeight + safeAreaInset.bottom)

        let scrollViewSize = drawerScrollView.frame.size
        drawerContentView.frame = CGRect(x: 0.0, y: scrollViewSize.height - (minimumDrawerHeight + safeAreaInset.bottom), width: scrollViewSize.width, height: (maximumDrawerHeight + safeAreaInset.bottom))
        drawerScrollView.contentSize = CGSize(width: scrollViewSize.width, height: drawerContentView.frame.maxY)
        drawerShadowView.frame = drawerContentView.frame

        let roundedBorderPath = UIBezierPath(roundedRect: drawerContentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: drawerCornerRadius, height: drawerCornerRadius)).cgPath
        drawerShadowView.layer.shadowPath = roundedBorderPath

        if let roundedMaskLayer = drawerContentView.layer.mask as? CAShapeLayer {
            roundedMaskLayer.path = roundedBorderPath
            roundedMaskLayer.frame = drawerContentView.bounds
        }

        setPosition(position, animated: false)
    }

    // MARK: - Public

    /// Changes the drawer position to the specified position.
    /// 
    /// - Precondition: The supported positions must contain this position; otherwise it does nothing.
    /// - Attention: This will notify both primary and secondary view controllers's `drawerViewControllerPositionDidChange(_:height:)`.
    /// - Parameters:
    ///   - position: The new position to apply to the secondary view controller.
    ///   - animated: Pass `true` to animate the changes; otherwise, pass false.
    ///   - completion: The block to execute after the animation finishes. Default to `nil`.
    public func setPosition(_ position: DrawerPosition, animated: Bool, completion: DrawerAnimationCompletionHandler? = nil) {
        guard supportedPositions.contains(position) else { return }

        self.position = position

        if let childScrollView = childScrollView, shouldManageChildScrollView() {
            childScrollView.isScrollEnabled = (position == .open)
        }

        let miniumDrawerHeight = heightForSupportedPositions().min() ?? 0.0
        let targetDrawerHeight = heightForPosition(position)
        let targetContentOffset = CGPoint(x: 0.0, y: targetDrawerHeight - miniumDrawerHeight)

        UIView.animate(withDuration: animated ? defaultAnimationDuration : 0.0, delay: 0.0, options: [.curveEaseOut], animations: {
            self.drawerScrollView.contentOffset = targetContentOffset
            self.notifyDrawerPositionDidChange()

            if animated {
                self.view.layoutIfNeeded()
            }
        }) { (completed) in
            completion?(completed)
        }
    }

    /// Sets the primary view controller. This controller is displayed behind the secondary view controller.
    ///
    /// - Parameters:
    ///   - primaryViewController: The view controller to be displayed.
    ///   - animated: Pass `true` to animate the presentation; otherwise, pass false.
    ///   - completion: The block to execute after the presentation finishes. Default to `nil`.
    public func setPrimaryViewController(_ primaryViewController: DrawerSupportedViewController, animated: Bool, completion: DrawerAnimationCompletionHandler? = nil) {

        self.primaryViewController = primaryViewController
        primaryViewController.view.layoutIfNeeded()

        UIView.transition(with: primaryContentView, duration: animated ? defaultAnimationDuration : 0.0, options: [.transitionCrossDissolve], animations: {
        }) { (completed) in
            completion?(completed)
        }
    }

    /// Sets the secondary view controller. This controller is the draggable view controller.
    ///
    /// - Parameters:
    ///   - secondaryViewController: The view controller to be displayed.
    ///   - animated: Pass `true` to animate the presentation; otherwise, pass false.
    ///   - completion: The block to execute after the presentation finishes. Default to `nil`.
    public func setSecondaryViewController(_ secondaryViewController: DrawerDraggableViewController, animated: Bool, completion: DrawerAnimationCompletionHandler? = nil) {

        self.secondaryViewController = secondaryViewController
        secondaryViewController.view.layoutIfNeeded()

        UIView.transition(with: drawerContentView, duration: animated ? defaultAnimationDuration : 0.0, options: [.transitionCrossDissolve], animations: {
            self.setPosition(self.position, animated: false)
        }) { (completed) in
            completion?(completed)
        }
    }

    /// Invalidate the supported positions and marks it as needing an update.
    ///
    /// - Postcondition: The `position` may change if the supported positions do not contain the current position.
    public func setNeedsUpdateSupportedPositions() {
        if let positions = secondaryViewController.drawerViewControllerSupportedPositions?(self), positions.count > 0 {
            supportedPositions = positions
        } else {
            supportedPositions = [.collapsed, .partiallyOpen, .open]
        }

        if !supportedPositions.contains(position) && supportedPositions.count > 0 {
            position = supportedPositions.first!
        }
    }

    /// Invalidates the child scroll view and marks it as needing an update.
    ///
    /// - Note: This method should only be called if the secondary view controller's
    /// `drawerViewControllerShouldManageChildScrollView` changes after the
    /// initial presentation.
    public func setNeedsUpdateShouldManageChildScrollView() {
        childScrollView = findScrollViewInSecondaryViewController()
    }

    // MARK: - Private

    private func updateCornerRadius() {
        let roundedBorderPath = UIBezierPath(roundedRect: drawerContentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: drawerCornerRadius, height: drawerCornerRadius)).cgPath

        if #available(iOS 11.0, *) {
            drawerContentView.layer.cornerRadius = drawerCornerRadius
        } else {
            if let roundedMaskLayer = drawerContentView.layer.mask as? CAShapeLayer {
                roundedMaskLayer.path = roundedBorderPath
                roundedMaskLayer.frame = drawerContentView.bounds
            }
        }

        drawerShadowView.layer.shadowPath = roundedBorderPath
    }

    private func heightForSupportedPositions() -> [CGFloat] {
        return supportedPositions.compactMap { (position) -> CGFloat in
            self.heightForPosition(position)
        }
    }

    private func positionForHeight(_ height: CGFloat) -> DrawerPosition {
        let openHeight = heightForPosition(.open)
        let partiallyOpenHeight = heightForPosition(.partiallyOpen)
        let collapsedHeight = heightForPosition(.collapsed)

        if supportedPositions.contains(.open) && (openHeight - height) <= CGFloat.ulpOfOne {
            return .open
        } else if supportedPositions.contains(.partiallyOpen) && (partiallyOpenHeight - height) <= CGFloat.ulpOfOne {
            return .partiallyOpen
        } else if supportedPositions.contains(.collapsed) && (collapsedHeight - height) <= CGFloat.ulpOfOne {
            return .collapsed
        }

        return .collapsed
    }

    private func heightForPosition(_ drawerPosition: DrawerPosition) -> CGFloat {
        switch drawerPosition {
        case .collapsed:
            return secondaryViewController.drawerViewControllerCollapsedHeight?(self) ?? defaultCollapsedHeight
        case .partiallyOpen:
            return secondaryViewController.drawerViewControllerPartiallyOpenHeight?(self) ?? defaultPartiallyOpenHeight
        case .open:
            return secondaryViewController.drawerViewControllerOpenHeight?(self) ?? defaultOpenHeight
        default:
            return 0.0
        }
    }

    private func notifyDrawerPositionDidChange() {
        let height = heightForPosition(position) + drawerSafeAreaInsets.bottom

        primaryViewController.drawerViewControllerPositionDidChange?(self, height: height)
        secondaryViewController.drawerViewControllerPositionDidChange?(self, height: height)
    }

    private func notifyDrawerHeightDidChange() {
        let contentOffsetY = drawerScrollView.contentOffset.y
        let adjustedOffsetY = contentOffsetY + (heightForSupportedPositions().min() ?? 0.0)

        primaryViewController.drawerViewControllerDrawerHeightDidChange?(self, height: adjustedOffsetY)
        secondaryViewController.drawerViewControllerDrawerHeightDidChange?(self, height: adjustedOffsetY)
    }

    private func shouldManageChildScrollView() -> Bool {
        return secondaryViewController.drawerViewControllerShouldManageChildScrollView?() ?? true
    }

    private func findScrollViewInSecondaryViewController() -> UIScrollView? {
        if shouldManageChildScrollView() {
            return findScrollViewIn(secondaryViewController.view)
        }

        return nil
    }

    private func findScrollViewIn(_ view: UIView) -> UIScrollView? {
        // Return if it's a scroll view.
        if let view = view as? UIScrollView {
            return view
        }

        // Criteria for determining the root scroll view is that the bounds must match its superview's bounds.
        let frame = view.bounds
        for subview in view.subviews {
            if subview.frame == frame {
                if let scrollView = findScrollViewIn(subview) {
                    return scrollView
                }
            }
        }

        return nil
    }

    // MARK: - ScrollViewDelegate

    private var lastTargetContentOffset: CGPoint = .zero

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == drawerScrollView else { return }

        let targetHeightList = heightForSupportedPositions()
        let minimumDrawerHeight = targetHeightList.min() ?? 0.0
        let adjustedOffsetY = lastTargetContentOffset.y + minimumDrawerHeight

        // Find closest height
        var previousDifference: CGFloat = targetHeightList.max() ?? 0.0
        var targetHeight: CGFloat = 0.0

        for possibleHeight in targetHeightList {
            let difference = abs(possibleHeight - adjustedOffsetY)
            if difference < previousDifference {
                previousDifference = difference
                targetHeight = possibleHeight
            }
        }

        let position = positionForHeight(targetHeight)
        setPosition(position, animated: true)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView == drawerScrollView else { return }

        lastTargetContentOffset = targetContentOffset.pointee
        targetContentOffset.pointee = scrollView.contentOffset
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == drawerScrollView else { return }

        notifyDrawerHeightDidChange()
    }

    // MARK: - Manage ScrollView in SecondaryViewController

    private var manuallyScrollDrawerScrollView: Bool = false
    private var manuallyScrollChildScrollView: Bool = false
    private var previousChildScrollViewTranslation: CGPoint = .zero

    private var childScrollView: UIScrollView? {
        willSet {
            childScrollView?.panGestureRecognizer.removeTarget(self, action: #selector(childScrollViewPanGesture(_:)))
        }
        didSet {
            childScrollView?.panGestureRecognizer.addTarget(self, action: #selector(childScrollViewPanGesture(_:)))
            childScrollView?.isScrollEnabled = (position == .open)
        }
    }

    @objc private func childScrollViewPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let state = gestureRecognizer.state

        if state == .began {
            previousChildScrollViewTranslation = gestureRecognizer.translation(in: drawerScrollView)

            let maximumContentOffsetY = drawerScrollView.contentSize.height - drawerScrollView.bounds.height
            let currentContentOffset = drawerScrollView.contentOffset
            if (maximumContentOffsetY - currentContentOffset.y) <= CGFloat.ulpOfOne {
                manuallyScrollChildScrollView = true
                manuallyScrollDrawerScrollView = false
            } else {
                manuallyScrollChildScrollView = false
                manuallyScrollDrawerScrollView = true
            }
        } else if state == .changed {
            let currentTranslation = gestureRecognizer.translation(in: drawerScrollView)
            let translationY = currentTranslation.y - previousChildScrollViewTranslation.y

            previousChildScrollViewTranslation = currentTranslation

            if manuallyScrollDrawerScrollView {
                // Moves the scroll view instead of child scroll view.
                let maximumContentOffsetY = drawerScrollView.contentSize.height - drawerScrollView.bounds.height

                var currentContentOffset = drawerScrollView.contentOffset
                currentContentOffset.y = max(min(currentContentOffset.y - translationY, maximumContentOffsetY), 0.0)

                if (maximumContentOffsetY - currentContentOffset.y) <= CGFloat.ulpOfOne {
                    manuallyScrollChildScrollView = true
                    manuallyScrollDrawerScrollView = false
                } else {
                    if let childScrollView = childScrollView {
                        let topInset = childScrollView.contentInset.top

                        var contentOffset = childScrollView.contentOffset
                        contentOffset.y = -topInset

                        childScrollView.contentOffset = contentOffset
                    }
                }

                lastTargetContentOffset = currentContentOffset
                drawerScrollView.contentOffset = currentContentOffset
            } else if manuallyScrollChildScrollView {
                if let childScrollView = childScrollView {
                    let topInset = childScrollView.contentInset.top

                    var currentContentOffset = childScrollView.contentOffset
                    currentContentOffset.y = max(currentContentOffset.y - translationY, -topInset)

                    if currentContentOffset.y <= -topInset {
                        manuallyScrollChildScrollView = false
                        manuallyScrollDrawerScrollView = true
                    }
                }
            }
        } else if state == .ended || state == .cancelled {
            scrollViewDidEndDragging(drawerScrollView, willDecelerate: false)
        }
    }

}

extension DrawerViewController: DrawerScrollViewDelegate {

    fileprivate func drawerScrollView(_ scrollView: DrawerScrollView, shouldPassTouchThroughAtPoint point: CGPoint) -> Bool {
        let point = drawerContentView.convert(point, from: scrollView)
        return !drawerContentView.bounds.contains(point)
    }

    fileprivate func drawerScrollView(_ scrollView: DrawerScrollView, viewToReceiveTouchAtPoint point: CGPoint) -> UIView {
        return primaryViewController.view
    }
}

extension UIViewController {

    /// The nearest ancestor in the view controller hierarchy that is a drawer view controller.
    ///
    /// - Note: This property is `nil` if the view controller is not embedded inside a drawer view controller.
    public var drawerViewController: DrawerViewController? {
        var controller = parent

        while controller != nil {
            if let controller = controller as? DrawerViewController {
                return controller
            }
            controller = controller?.parent
        }

        return nil
    }

}

private protocol DrawerScrollViewDelegate: class {
    func drawerScrollView(_ scrollView: DrawerScrollView, shouldPassTouchThroughAtPoint point: CGPoint) -> Bool
    func drawerScrollView(_ scrollView: DrawerScrollView, viewToReceiveTouchAtPoint point: CGPoint) -> UIView
}

private class DrawerScrollView: UIScrollView {

    public weak var drawerDelegate: DrawerScrollViewDelegate?

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let drawerDelegate = drawerDelegate, drawerDelegate.drawerScrollView(self, shouldPassTouchThroughAtPoint: point) {
            let view = drawerDelegate.drawerScrollView(self, viewToReceiveTouchAtPoint: point)
            let point = convert(point, to: view)
            return view.hitTest(point, with: event)
        }

        return super.hitTest(point, with: event)
    }

}
