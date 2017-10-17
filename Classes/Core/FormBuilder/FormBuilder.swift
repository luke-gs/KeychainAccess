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


/// A set of methods that defines a basic form item.
public protocol FormItem: class {

    var elementIdentifier: String? { get }

    func accept(_ visitor: FormVisitor)

}


/// Form builder manages items
public class FormBuilder {

    /// The title for the form.
    public var title: String?

    /// Force linear layout ignores items' width and forces each item to occupy the full row.
    public var forceLinearLayout: Bool = false

    public private(set) var formItems: [FormItem] = []

    public init() {}


    /// Adds an item to the builder.
    ///
    /// - Parameter item: The form item.
    public func add(_ item: FormItem) {
        formItems.append(item)
    }


    /// Adds a collection of items to the builder.
    ///
    /// - Parameter items: The collection of items.
    public func add(_ items: [FormItem]) {
        formItems.append(contentsOf: items)
    }

    /// Removes a form item from the builder.
    ///
    /// - Parameter item: The form item to remove.
    public func remove(_ item: FormItem) {
        if let index = formItems.index(where: { $0 === item }) {
            formItems.remove(at: index)
        }
    }


    /// Removes a collection of items from the builder.
    ///
    /// - Parameter items: The collection of items.
    public func remove(_ items: [FormItem]) {
        items.forEach({ self.remove($0) })
    }


    /// Removes all items from the builder
    public func removeAll() {
        formItems.removeAll()
    }


    /// Generates a collection of sections containing header, footer and items.
    ///
    /// - Returns: A collection of sections.
    public func generateSections() -> [FormSection] {
        var sections = [FormSection]()

        var header: FormItem?
        var footer: FormItem?
        var items: [FormItem] = []

        for item in formItems {
            if item is BaseFormItem {
                if (footer != nil) {
                    sections.append(FormSection(formHeader: header, formItems: items, formFooter: footer))
                    header = nil
                    footer = nil
                    items = []
                }

                if let item = item as? FormItemContainer {
                    items = items + item.items
                } else {
                    items.append(item)
                }
            } else if let item = item as? BaseSupplementaryFormItem {
                if item.kind == UICollectionElementKindSectionHeader {
                    if (header != nil || footer != nil || items.count > 0) {
                        sections.append(FormSection(formHeader: header, formItems: items, formFooter: footer))
                        header = nil
                        footer = nil
                        items = []
                    }

                    header = item
                } else if item.kind == UICollectionElementKindSectionFooter {
                    if (footer != nil) {
                        sections.append(FormSection(formHeader: header, formItems: items, formFooter: footer))
                        header = nil
                        footer = nil
                        items = []
                    }
                    
                    footer = item
                }
            }
        }

        if header != nil || footer != nil || items.count > 0 {
            sections.append(FormSection(formHeader: header, formItems: items, formFooter: footer))
        }

        return sections
    }

    // MARK: - Convenience methods

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


// MARK: - Form validation

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
