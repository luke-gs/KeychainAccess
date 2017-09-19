//
//  Presenter.swift
//  MPOLKit
//
//  Created by KGWH78 on 6/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// A presentable protocol
public protocol Presentable {

}


/// Implement this protocol to become a presenter. The presenter will be responsible for
/// creating the view controllers based on the given presentables.
public protocol Presenter {

    /// Create a view controller for the specific presentation.
    ///
    /// - Parameter presentable: The presentable
    /// - Returns: A view controller for this presentable
    func viewController(forPresentable presentable: Presentable) -> UIViewController

    /// Presents a view controller from view controller for the given presentable.
    ///
    /// - Parameters:
    ///   - presentable: The presentable
    ///   - from: The presenting view controller
    ///   - to: The view controller to present
    func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController)

    /// Return true if this presentable is supported. False otherwise.
    func supportPresentable(_ presentableType: Presentable.Type) -> Bool

}

/// A collection of presenters
public final class PresenterGroup: Presenter {

    public let presenters: [Presenter]

    public init(presenters: [Presenter]) {
        self.presenters = presenters
    }

    public func viewController(forPresentable presentable: Presentable) -> UIViewController {
        let supportedPresenter = presenters.first(where: { $0.supportPresentable(type(of: presentable)) })!
        return supportedPresenter.viewController(forPresentable: presentable)
    }

    public func present(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController) {
        let supportedPresenter = presenters.first(where: { $0.supportPresentable(type(of: presentable)) })!
        supportedPresenter.present(presentable, fromViewController: from, toViewController: to)
    }

    public func supportPresentable(_ presentableType: Presentable.Type) -> Bool {
        return presenters.first(where: { $0.supportPresentable(presentableType) }) != nil
    }
    
}

/// Implement this protocol to become the observer.
public protocol PresenterObserving: class {

    func willPresent(_ presentable: Presentable, fromViewController from: UIViewController, toViewController to: UIViewController)

    func didPresent(_ presentable: Presentable, fromViewController: UIViewController, toViewController to: UIViewController)

}


/// A director is the person or thing that says whom or what should put on a good show for the observers to see.
public final class Director {

    /// The current presenter
    public let presenter: Presenter

    private var observers: [PresenterObserving] = []

    /// The shared presenter to be set up by the app.
    public static var shared: Director!

    /// Initialize with a presenter
    ///
    /// - Parameter presenter: The presenter
    public init(presenter: Presenter) {
        self.presenter = presenter
    }

    /// Navigate to the presentable
    ///
    /// - Parameters:
    ///   - presentable: The presentable
    ///   - viewController: The view controller to present this from.
    public func present(_ presentable: Presentable, fromViewController viewController: UIViewController) {
        guard presenter.supportPresentable(type(of: presentable)) == true else {
            fatalError("This presented is not supported.")
        }

        let targetViewController = presenter.viewController(forPresentable: presentable)

        observers.forEach {
            $0.willPresent(presentable, fromViewController: viewController, toViewController: targetViewController)
        }

        presenter.present(presentable, fromViewController: viewController, toViewController: targetViewController)

        observers.forEach {
            $0.didPresent(presentable, fromViewController: viewController, toViewController: targetViewController)
        }
    }

    /// Add a presenter observer
    ///
    /// - Parameter observer: The observer to add
    public func addPresenterObserver(_ observer: PresenterObserving) {
        observers.append(observer)
    }

    /// Remove a presenter observer
    ///
    /// - Parameter observer: The observer to remove
    public func removePresenterObserver(_ observer: PresenterObserving) {
        if let index = observers.index(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }

}

/// Why not?
public extension UIViewController {

    public func present(_ presentable: Presentable) {
        Director.shared.present(presentable, fromViewController: self)
    }

}
