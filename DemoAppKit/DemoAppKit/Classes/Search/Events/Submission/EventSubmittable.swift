//
//  EventSubmittable.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

/// Defines what to show in the alert when an event is submitted successfully
public protocol EventSubmittable {

    /// The title of the alert
    var title: String { get }

    /// The detail of the alert
    var detail: String { get }
}
