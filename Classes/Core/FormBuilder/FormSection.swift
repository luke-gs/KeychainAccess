//
//  FormSection.swift
//  MPOLKit
//
//  Created by KGWH78 on 19/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


/// Representing a section in the collection view system.
public struct FormSection {

    /// The header item
    public let formHeader: FormItem?

    /// The footer item
    public let formFooter: FormItem?

    /// The items in this section.
    public let formItems: [FormItem]

    public init(formHeader: FormItem?, formItems: [FormItem], formFooter: FormItem?) {
        self.formHeader = formHeader
        self.formItems = formItems
        self.formFooter = formFooter
    }

    public subscript(index: Int) -> FormItem {
        get { return formItems[index] }
    }

}

extension FormSection: Equatable {
    public static func ==(lhs: FormSection, rhs: FormSection) -> Bool {
        return lhs.formHeader === rhs.formHeader &&
            lhs.formFooter === rhs.formFooter &&
            lhs.formItems.elementsEqual(rhs.formItems, by: { $0 === $1 })
    }
}

public extension Array where Element == FormSection {

    public subscript(indexPath: IndexPath) -> FormItem {
        get { return self[indexPath.section][indexPath.item] }
    }

}
