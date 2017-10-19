//
//  SelectionAction.swift
//  MPOLKit
//
//  Created by KGWH78 on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol SelectionActionable {

    var selectionAction: SelectionAction? { get }

}


public protocol SelectionAction: class {

    /// The view controller to be displayed
    ///
    /// - Returns: A view controller
    func viewController() -> UIViewController

    /// This must be called when the view controller is dismissed.
    var dismissHandler: (() -> ())? { get set }

}


open class ValueSelectionAction<T>: SelectionAction {

    public var title: String?

    public var selectedValue: T?

    public var updateHandler: (() -> ())?

    public var dismissHandler: (() -> ())?

    public init() { }

    open func viewController() -> UIViewController {
        MPLRequiresConcreteImplementation()
    }

    open func displayText() -> String? {
        MPLRequiresConcreteImplementation()
    }

}
