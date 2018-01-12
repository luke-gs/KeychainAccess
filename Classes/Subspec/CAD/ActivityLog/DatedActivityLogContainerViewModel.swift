//
//  DatedActivityLogContainerViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class DatedActivityLogContainerViewModel {

    open var activityLogViewModels: [DatedActivityLogItemViewModel]
    
    public init(activityLogViewModels: [DatedActivityLogItemViewModel]) {
        self.activityLogViewModels = activityLogViewModels
    }
    
    open func createViewController() -> UIViewController? {
        let viewControllers = activityLogViewModels.map { $0.activityLogViewModel.createViewController() }
        
        if let viewControllers = viewControllers as? [DatedActivityLogViewController] {
            return DatedActivityLogContainerViewController(viewControllers: viewControllers, viewModel: self)
        }
        
        return nil
    }
    
    open func title() -> String {
        return NSLocalizedString("Activity Log", comment: "")
    }
}
