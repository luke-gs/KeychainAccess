//
//  PromiseCancellationToken.swift
//  MPOLKit
//
//  Created by Herli Halim on 28/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

// Concrete implementation of PromiseCancelling. The cancellable operation
// will provide its custom cancellation code inside the `cancelAction` closure.
public class PromiseCancellationToken: PromiseCancelling {

    public var isCancelled: Bool = false
    public let cancelAction: () -> Void

    public init(action: @escaping () -> Void) {
        self.cancelAction = action
    }

    public func cancel() {
        isCancelled = true
        cancelAction()
    }

}
