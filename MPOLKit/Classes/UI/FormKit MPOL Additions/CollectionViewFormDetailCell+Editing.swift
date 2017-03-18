//
//  CollectionViewFormDetailCell+Editing.swift
//  Pods
//
//  Created by Rod Brown on 18/3/17.
//
//

import UIKit

extension CollectionViewFormDetailCell {
    
    /// A boolean value indicating whether the cell represents an editable detail field.
    /// The default is `true`.
    ///
    /// This value can be used to inform MPOL apps that detail field should be
    /// displayed with the standard MPOL editable colors and/or adornments.
    ///
    /// This should be ignored by MPOL apps when the emphasis is on the title.
    open var isDetailEditable: Bool {
        get { return mpol_isDetailEditable }
        set { mpol_isDetailEditable = newValue }
    }
    
}
