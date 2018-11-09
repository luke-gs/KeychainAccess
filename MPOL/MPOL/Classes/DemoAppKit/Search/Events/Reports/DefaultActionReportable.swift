//
//  DefaultActionReportable.swift
//  DemoAppKit
//
//  Created by Trent Fitzgibbon on 8/11/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

/// Default base class for an ActionReportable
open class DefaultActionReportable: DefaultReportable, ActionReportable {

    /// Reference back to the parent action
    public var weakAdditionalAction: Weak<AdditionalAction> {
        didSet {
            if let additionalAction = additionalAction, oldValue.object == nil {
                configure(with: additionalAction)
            }
        }
    }

    // Default init taking incident and action
    public init(incident: Incident?, additionalAction: AdditionalAction) {
        self.weakAdditionalAction = Weak(additionalAction)
        super.init()

        self.weakIncident = Weak(incident)
        configure(with: additionalAction)
    }

    /// Perform any configuration now that we have an additional action
    public func configure(with additionalAction: AdditionalAction) {
        evaluator.addObserver(additionalAction)
    }

    // MARK: - Codable

    public required init(from decoder: Decoder) throws {
        /// Set to nil initially, until parent passes it to us during it's decode
        self.weakAdditionalAction = Weak(nil)

        try super.init(from: decoder)
    }

    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}
