//
//  UIStackView+RemoveArrangedSubviews.swift
//  MPOLKit
//
//  Created by Kyle May on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

extension UIStackView {
    
    /// Removes all arranged subviews
    public func removeArrangedSubviews() {
        self.arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
        }
    }
}
