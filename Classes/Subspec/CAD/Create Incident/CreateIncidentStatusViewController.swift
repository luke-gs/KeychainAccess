//
//  CreateIncidentStatusViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CreateIncidentStatusViewController: CallsignStatusViewController {
    
    open var createIncidentStatusViewModel: CreateIncidentStatusViewModel {
        return self.viewModel as! CreateIncidentStatusViewModel
    }
    
    // MARK: - Initializers
    
    public init(viewModel: CreateIncidentStatusViewModel) {
        super.init(viewModel: viewModel)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
}
