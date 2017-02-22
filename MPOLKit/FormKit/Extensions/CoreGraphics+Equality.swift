//
//  CoreGraphics+Equality.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import CoreGraphics


infix operator ==~: DefaultPrecedence
func ==~ (left: CGFloat, right: CGFloat) -> Bool {
    return fabs(left.distance(to: right)) <= 1e-15
}

infix operator !=~: DefaultPrecedence
func !=~ (left: CGFloat, right: CGFloat) -> Bool {
    return !(left ==~ right)
}
