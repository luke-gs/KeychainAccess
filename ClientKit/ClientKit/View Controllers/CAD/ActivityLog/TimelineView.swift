//
//  TimelineView.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

/// Custom collection decorator view that just has a background color
public class TimelineView: UICollectionReusableView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.8862745098, green: 0.8901960784, blue: 0.8941176471, alpha: 1)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
