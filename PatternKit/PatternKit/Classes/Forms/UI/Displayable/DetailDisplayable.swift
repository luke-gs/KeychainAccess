//
//  DetailDisplayable.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol DetailDisplayable {
    var image: UIImage? { get }
    var title: StringSizing? { get }
    var subtitle: StringSizing? { get }
    var detail: StringSizing? { get }
}

extension DetailDisplayable {

    public var image: UIImage? {
        return nil
    }

    public var title: StringSizing? {
        return nil
    }

    public var subtitle: StringSizing? {
        return nil
    }

    public var detail: StringSizing? {
        return nil
    }

}

// All DetailDisplayable conformant will get this default implementation
// if they also declares conformance to FormItemable.
extension FormItemable where Self: DetailDisplayable {

    public func formItem() -> DetailFormItem {
        return DetailFormItem(title: title, subtitle: subtitle, detail: detail, image: image)
    }

}
