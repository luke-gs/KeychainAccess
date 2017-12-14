//
//  ColumnView.swift
//  MPOLKit
//
//  Created by Kyle May on 13/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ColumnView: UIView {
    
    open var columnInfo: ColumnInfo
    
    public init(frame: CGRect = .zero, columnInfo: ColumnInfo = .zero) {
        self.columnInfo = columnInfo
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
