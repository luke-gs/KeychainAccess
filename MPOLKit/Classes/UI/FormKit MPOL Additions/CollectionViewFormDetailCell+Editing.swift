//
//  CollectionViewFormDetailCell+Editing.swift
//  MPOLKit
//
//  Created by Rod Brown on 18/3/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

extension CollectionViewFormSubtitleCell {
    
    /// A boolean value indicating whether the cell represents an editable field.
    /// The default is `true`.
    ///
    /// This value can be used to inform MPOL apps that the cell should be
    /// displayed with the standard MPOL editable colors and/or adornments.
    ///
    /// This should be ignored by MPOL apps when the emphasis is on the title.
    open var isEditableField: Bool {
        get { return mpol_isEditableField }
        set { mpol_isEditableField = newValue }
    }
    
}
