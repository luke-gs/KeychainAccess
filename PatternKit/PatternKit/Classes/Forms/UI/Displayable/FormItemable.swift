//
//  DetailDisplayable+FormItem.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// Protocol to have FormItem factory.
public protocol FormItemable {
    
    associatedtype FormItem

    func formItem() -> FormItem
}
