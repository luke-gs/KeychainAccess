//
//  Summarisable.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Used to mark that something has items for the Event Summary screen.
public protocol Summarisable {

    /// An array of Form Items that are produced by the Summarisable object itself, it decides what sort of Form Item they should be.
    var formItems: [FormItem] { get }
}
