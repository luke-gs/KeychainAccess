//
//  FormBuilder.swift
//  MPOLKit
//
//  Created by KGWH78 on 13/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation



public protocol FormVisitor {

    func visit(_ object: FormItem)

}

public protocol FormItem: class {

    var elementIdentifier: String? { get }

    func accept(_ visitor: FormVisitor)

}

public class FormBuilder {

    public var title: String?

    public var forceLinearLayout: Bool = false

    public private(set) var formItems: [FormItem] = []

    public init() {}

    public func add(_ item: FormItem) {
        formItems.append(item)
    }

    public func add(_ items: [FormItem]) {
        formItems.append(contentsOf: items)
    }

    public func remove(_ item: FormItem) {
        if let index = formItems.index(where: { $0 === item }) {
            formItems.remove(at: index)
        }
    }

    public func remove(_ items: [FormItem]) {
        items.forEach({ self.remove($0) })
    }

    public func removeAll() {
        formItems.removeAll()
    }

    public func generateSections() -> [FormSection] {
        var sections = [FormSection]()

        var header: FormItem?
        var footer: FormItem?
        var items: [FormItem] = []

        for item in formItems {
            if item is CollectionViewFormItem {
                if let item = item as? FormItemContainer {
                    items = items + item.items
                } else {
                    items.append(item)
                }
            } else if let item = item as? CollectionViewFormSupplementary {
                if item.kind == UICollectionElementKindSectionHeader {
                    if (header != nil || footer != nil || items.count > 0) {
                        sections.append(FormSection(formHeader: header, formItems: items, formFooter: footer))
                        header = nil
                        footer = nil
                        items = []
                    }

                    header = item
                } else if item.kind == UICollectionElementKindSectionFooter {
                    footer = item
                }
            }
        }

        if header != nil || footer != nil || items.count > 0 {
            sections.append(FormSection(formHeader: header, formItems: items, formFooter: footer))
        }

        return sections
    }

    /// MARK: - Convenience methods

    public static func +=(builder: FormBuilder, formItem: FormItem) {
        builder.add(formItem)
    }

    public static func +=(builder: FormBuilder, formItems: [FormItem]) {
        builder.add(formItems)
    }

    public static func -=(builder: FormBuilder, formItem: FormItem) {
        builder.remove(formItem)
    }

    public static func -=(builder: FormBuilder, formItems: [FormItem]) {
        builder.remove(formItems)
    }

}


/// MARK: - Form validation

extension FormBuilder {

    /// Form validation result
    ///
    /// - valid: This case indicates that the form is valid.
    /// - invalid: The invalid state containing the item and validation text.
    public enum FormValidationResult {
        case valid
        case invalid(item: FormItem, message: String)
    }


    /// Validates form and updates the UI with the validation text if any
    public func validateAndUpdateUI() {
        for item in formItems {
            let visitor = ReloadValidationStateVisitor()
            item.accept(visitor)
        }
    }


    /// Validates form. Returns the first invalid item with the validation text.
    ///
    /// - Returns: The validation result.
    public func validate() -> FormValidationResult {
        for item in formItems {
            let visitor = SubmissionValidationVisitor()
            item.accept(visitor)

            switch visitor.result {
            case .softInvalid(let message):
                return .invalid(item: item, message: message)
            case .strictInvalid(let message):
                return .invalid(item: item, message: message)
            default: break
            }
        }

        return .valid
    }

}


public struct FormSection {

    public let formHeader: FormItem?

    public let formFooter: FormItem?

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

public extension Array where Element == FormSection {

    public subscript(indexPath: IndexPath) -> FormItem {
        get { return self[indexPath.section][indexPath.item] }
    }

}
