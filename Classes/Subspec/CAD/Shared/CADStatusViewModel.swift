//
//  CADStatusViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 21/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class CADStatusViewModel: CADFormCollectionViewModel<ManageCallsignStatusItemViewModel> {
    /// The currently selected state, can be nil
    public var selectedIndexPath: IndexPath?
}
