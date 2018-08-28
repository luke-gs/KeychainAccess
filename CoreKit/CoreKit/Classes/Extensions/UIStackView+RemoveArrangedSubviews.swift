//
//  UIStackView+RemoveArrangedSubviews.swift
//  MPOLKit
//
//  Created by Kyle May on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension UIStackView {
    
    /// Removes all arranged subviews from the stack view and the view hierarchy
    public func removeArrangedSubviewsFromViewHierarchy() {
        self.arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}
