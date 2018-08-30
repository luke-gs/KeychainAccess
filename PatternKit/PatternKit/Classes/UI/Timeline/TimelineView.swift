//
//  TimelineView.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 28/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Custom collection decorator view that just has a background color
public class TimelineView: UICollectionReusableView {
    public override init(frame: CGRect) {
        super.init(frame: frame)

        let theme = ThemeManager.shared.theme(for: .current)
        backgroundColor = theme.color(forKey: .separator)
    }

    required public init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
}
