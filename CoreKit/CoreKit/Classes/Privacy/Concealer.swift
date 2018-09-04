//
//  Concealer.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public class Concealer {

    /// A struct wrapping the concept of an Security Event.
    ///
    /// You can define your own SecurityEvent to register by using static constants and
    /// initializing with custom raw values.
    public class SecurityEvent: ExtensibleKey<Int> {

        var lookupTag: Int {
            return rawValue
        }

        // Default event captured by the Security Event
        public static let springboard = SecurityEvent(123)
    }

    private static let sizingMismatch: String =
        """
            Concealer encountered an instance where the view's frame
            was not fully covered by the obfuscating view. Setting the
            concealer's frame to the view's frame. Please ensure that
            the frame of the concealer contains the view it is trying
            to hide.
        """

    private var concealers: [SecurityEvent: UIView] = [:]

    public init() {
        concealers[.springboard] = defaultConcealer(covering: UIScreen.main.bounds)
    }

    // Convenience static property for a default concealer
    public static let `default` = Concealer()

    /// Ability to register a custom view for the springboard hiding
    ///
    /// - Parameters:
    ///   - view: The view that will be displayed when the application moves to inactive
    ///   - event: The event which the view will be registered for
    public func register(view: UIView, for event: SecurityEvent = .springboard) {
        concealers[event] = view
    }

    /// Reveal the view based on a specific event
    ///
    /// - Parameters:
    ///   - view: The view that is to be revealed
    ///   - event: The event to which you are going to be revealing the view for
    public func reveal(_ view: UIView, from event: SecurityEvent) {
        reveal(view, matching: event.lookupTag)
    }

    /// Reveal a view that matches a tag
    ///
    /// - Parameters:
    ///   - view: The view that has been blocked by the ScreenProtector
    ///   - tag: The tag which relates to the blocking view
    private func reveal(_ view: UIView, matching tag: Int) {
        guard let concealer = view.viewWithTag(tag) else { return }
        UIView.animate(withDuration: 0.3, animations: { [concealer] in
            concealer.alpha = 0.0
        }, completion: { [concealer] success in
            concealer.removeFromSuperview()
            concealer.alpha = 1.0
        })
    }

    /// Based on an event, hide the contents of the provided view behind another view
    ///
    /// - Parameters:
    ///   - view: The view which will be obfuscated by the Screen protector
    ///   - event: The event which to register the blocking view against
    /// - Returns: The tag of the view for future reference to reveal
    ///            the view when required, used primarily for custom options, as
    ///            the value is needed to reveal the view when required
    @discardableResult
    public func conceal(_ view: UIView, from event: SecurityEvent) -> Int {
        let concealer = concealers[event] ?? defaultConcealer(covering: view.frame)
        return conceal(view, using: concealer, lookupTag: event.lookupTag)
    }

    /// Blocks the display of a view given another view
    ///
    /// - Parameters:
    ///   - view: The view to be obfuscated
    ///   - concealer: The view that will obfuscate the required view
    ///              Defaults to a simple blurred overlay view
    /// - Returns: The tag of the view for future reference to reveal
    ///            the view when required
    private func conceal(_ view: UIView, using concealer: UIView, lookupTag: Int? = nil) -> Int {
        let tag = lookupTag ?? uniqueTag(for: view)

        // Ensure that the view provided will cover the entire view
        // that it is required to hide.
        if !concealer.frame.contains(view.frame) {
            print(Concealer.sizingMismatch)
            concealer.frame = view.frame
        }
        concealer.tag = tag
        view.addSubview(concealer)
        return tag
    }

    /// Ensure that the tag is unique for the provided view
    private func uniqueTag(for view: UIView) -> Int {
        guard view.tag == 0 else { return view.tag }
        var tag = Int(arc4random())
        while view.viewWithTag(tag) != nil {
            tag = Int(arc4random())
        }
        return tag
    }

    /// Provide a default blur effect view that will sit on top
    /// of the view provided
    private func defaultConcealer(covering frame: CGRect) -> UIView {
        let blurEffect: UIBlurEffect = UIBlurEffect(style: .regular)
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = frame
        return blurView
    }
}
