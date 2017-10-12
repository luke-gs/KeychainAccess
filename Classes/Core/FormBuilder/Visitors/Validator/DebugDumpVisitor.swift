//
//  DebugDumpVisitor.swift
//  MPOLKit
//
//  Created by KGWH78 on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation


public class DebugDumpVisitor: FormVisitor {

    public var payload = [String: Any]()

    public init() { }

    public func visit(_ object: FormItem) {
        switch object {
        case let item as TextFieldFormItem:
            extract(item)
        case let item as TextViewFormItem:
            extract(item)
        case let item as PickerFormItem<Array<String>>:
            extract(item)
        case let item as PickerFormItem<String>:
            extract(item)
        case let item as PickerFormItem<Int>:
            extract(item)
        case let item as PickerFormItem<Date>:
            extract(item)
        case let item as PickerFormItem<CountableClosedRange<Int>>:
            extract(item)
        case let item as HeaderFormItem:
            extract(item)
        case let item as FooterFormItem:
            extract(item)
        case let item as OptionFormItem:
            extract(item)
        case let item as OptionGroupFormItem:
            extract(item)
        case let item as SubtitleFormItem:
            extract(item)
        case let item as ValueFormItem:
            extract(item)
        case let item as SummaryThumbnailFormItem:
            extract(item)
        case let item as SummaryListFormItem:
            extract(item)
        default:
            break
        }

    }

    /// MARK: - Private

    private func extract(_ object: TextFieldFormItem) {
        payload["class"] = "TextFieldFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.title
        payload["placeholder"] = object.placeholder
        payload["value"] = object.text
    }

    private func extract(_ object: TextViewFormItem) {
        payload["class"] = "TextViewFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.title
        payload["placeholder"] = object.placeholder
        payload["value"] = object.text
    }

    private func extract<T>(_ object: PickerFormItem<T>) {
        payload["class"] = "PickerFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.title
        payload["placeholder"] = object.placeholder
        payload["value"] = object.pickerAction?.displayText()
    }

    private func extract(_ object: HeaderFormItem) {
        payload["class"] = "HeaderFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.text
        payload["style"] = object.style == .plain ? "Plain" : "Collapsible"
    }

    private func extract(_ object: FooterFormItem) {
        payload["class"] = "HeaderFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.text
    }

    private func extract(_ object: OptionFormItem) {
        payload["class"] = "RadioButton"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.title
        payload["subtitle"] = object.subtitle
        payload["selected"] = object.isChecked
        payload["type"] = object.optionStyle == .checkbox ? "Checkbox" : "Radio"
    }

    private func extract(_ object: OptionGroupFormItem) {
        payload["class"] = "OptionGroupFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["options"] = object.options
        payload["selected"] = object.options[object.selectedIndexes]
        payload["type"] = object.optionStyle == .checkbox ? "Checkbox" : "Radio"
    }

    private func extract(_ object: SubtitleFormItem) {
        payload["class"] = "SubtitleFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.title
        payload["subtitle"] = object.subtitle
    }

    private func extract(_ object: ValueFormItem) {
        payload["class"] = "SubtitleFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["title"] = object.title
        payload["subtitle"] = object.value
    }

    private func extract(_ object: SummaryListFormItem) {
        payload["class"] = "SubtitleFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["category"] = object.category
        payload["title"] = object.title
        payload["subtitle"] = object.subtitle
        payload["badge"] = object.badge
        payload["badgeColor"] = object.badgeColor?.description
        payload["borderColor"] = object.borderColor?.description
    }

    private func extract(_ object: SummaryThumbnailFormItem) {
        payload["class"] = "SubtitleFormItem"
        payload["elementIdentifier"] = object.elementIdentifier
        payload["category"] = object.category
        payload["title"] = object.title
        payload["subtitle"] = object.subtitle
        payload["detail"] = object.detail
        payload["badge"] = object.badge
        payload["badgeColor"] = object.badgeColor?.description
        payload["borderColor"] = object.borderColor?.description
    }

}

extension DebugDumpVisitor {

    // MARK: - Class methods

    public class func dump(items: [FormItem]) -> Data {
        var results = [[String: Any]]()

        for item in items {
            let dumpVisitor = DebugDumpVisitor()
            item.accept(dumpVisitor)

            var payload = dumpVisitor.payload
            if !payload.isEmpty {
                let validator = SubmissionValidationVisitor()
                item.accept(validator)

                switch validator.result {
                case .softInvalid(let message):
                    payload["validation_status"] = "invalid"
                    payload["validation_message"] = message
                case .strictInvalid(let message):
                    payload["validation_status"] = "invalid"
                    payload["validation_message"] = message
                case .valid:
                    payload["validation_status"] = "valid"
                }

                results.append(payload)
            }
        }

        let options: JSONSerialization.WritingOptions = .prettyPrinted
        return try! JSONSerialization.data(withJSONObject: results, options: options)
    }

}
