//
//  DefaultNSCopying.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol DefaultNSCopying: NSCopying {
    func copy() -> Self
}

extension DefaultNSCopying {

    public func copy() -> Self {
        return self.copy(with: nil) as! Self
    }

}

extension Array where Iterator.Element: DefaultNSCopying {

    public func clone() -> [Iterator.Element] {
        return self.map { return $0.copy() }
    }

}
