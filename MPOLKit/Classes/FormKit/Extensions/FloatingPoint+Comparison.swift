//
//  CoreGraphics+Comparison.swift
//  MPOLKit
//
//  Created by Rod Brown on 22/2/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import CoreGraphics


/// Compares two floating point values are equatable with an epsilon value.
infix operator ==~: ComparisonPrecedence

func ==~ (left: Float, right: Float) -> Bool {
    return abs(left.distance(to: right)) <= 1e-10
}

func ==~ (left: Double, right: Double) -> Bool {
    return abs(left.distance(to: right)) <= 1e-10
}

func ==~ (left: CGFloat, right: CGFloat) -> Bool {
    return left.native ==~ right.native
}



/// Compares two floating point values are not equatable, with an epsilon value.
infix operator !=~: ComparisonPrecedence

func !=~ (left: Float, right: Float) -> Bool {
    return !(left ==~ right)
}

func !=~ (left: Double, right: Double) -> Bool {
    return !(left ==~ right)
}

func !=~ (left: CGFloat, right: CGFloat) -> Bool {
    return !(left ==~ right)
}



infix operator <=~: ComparisonPrecedence

func <=~ (left: Float, right: Float) -> Bool {
    return left < right || left ==~ right
}

func <=~ (left: Double, right: Double) -> Bool {
    return left < right || left ==~ right
}

func <=~ (left: CGFloat, right: CGFloat) -> Bool {
    return left < right || left ==~ right
}


infix operator >=~: ComparisonPrecedence

func >=~ (left: Float, right: Float) -> Bool {
    return left > right || left ==~ right
}

func >=~ (left: Double, right: Double) -> Bool {
    return left > right || left ==~ right
}

func >=~ (left: CGFloat, right: CGFloat) -> Bool {
    return left > right || left ==~ right
}



infix operator <~: ComparisonPrecedence

func <~ (left: Float, right: Float) -> Bool {
    return !(left >=~ right)
}

func <~ (left: Double, right: Double) -> Bool {
    return !(left >=~ right)
}

func <~ (left: CGFloat, right: CGFloat) -> Bool {
    return !(left >=~ right)
}



infix operator >~: ComparisonPrecedence

func >~ (left: Float, right: Float) -> Bool {
    return !(left <=~ right)
}

func >~ (left: Double, right: Double) -> Bool {
    return !(left <=~ right)
}

func >~ (left: CGFloat, right: CGFloat) -> Bool {
    return !(left <=~ right)
}

