//
//  DetailFormItemDisplayable.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

public protocol DetailFormItemDisplayable {
    var image: UIImage? { get }
    var title: StringSizing? { get }
    var subtitle: StringSizing? { get }
    var detail: StringSizing? { get }
}

extension DetailFormItemDisplayable {

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

extension DetailFormItem {

    @discardableResult
    public func displayable(_ displayItem: DetailFormItemDisplayable?) -> Self {
        self.title = displayItem?.title
        self.subtitle = displayItem?.subtitle
        self.detail = displayItem?.detail
        self.image = displayItem?.image
        return self
    }

}
