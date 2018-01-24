//
//  TemplateManagerViewController.swift
//  MPOLKitDemo
//
//  Created by Kara Valentine on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import PromiseKit

class TemplateManagerViewController: FormBuilderViewController {
       
    lazy var templateDropDown: DropDownFormItem<TextTemplate> = DropDownFormItem().title("Select a template")

    lazy var templateTextField = TextViewFormItem()
        .title("Template Text")
        .height(.fixed(120.0))

    var handler: TemplateHandler<UserDefaultsDataSource> = TemplateHandler<UserDefaultsDataSource>(source: UserDefaultsDataSource(sourceKey: "testKey"))

    override init() {
        super.init()

        title = "Templates"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
        ]

        updateDropDown()
    }

    override func construct(builder: FormBuilder) {
        builder.title = "Templates"
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: "TEMPLATE DEMO")
        builder += SubtitleFormItem(title: "Choose a template!", subtitle: "Tap the below drop-down to select a template.", image: nil)
        builder += templateDropDown.onValueChanged { _ in
            let selectedValue = self.templateDropDown.selectedValue
            let first = selectedValue?.first
            let value = first?.value ?? ""
            self.templateTextField.text = value
            self.templateTextField.reloadItem()
        }
        builder += templateTextField
        builder += SubtitleFormItem(title: "Add templates!", subtitle: "Tap the top-right plus button to add a template.", image: nil)
        builder += SubtitleFormItem(title: "Remove all templates!", subtitle: "Tap the top-right trash button to remove all templates.", image: nil)
    }

    func updateDropDown() {
        handler.source.retrieve().then { result in
            let templateArray = Array(result ?? [])
            self.templateDropDown.options = templateArray
            return AnyPromise(Promise<Void>())
        }.always {}
    }

    @objc func addTapped() {
        let templateAddViewController = TemplateAddViewController(handler: handler)
        templateAddViewController.completion = { self.updateDropDown() }
        let navigationController = UINavigationController(rootViewController: templateAddViewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }

    @objc func trashTapped() {
        handler.source.retrieve().then { result in
            if let templates = result {
                templates.forEach { self.handler.source.delete(template: $0) }
            }
            return AnyPromise(Promise<Void>())
        }.always {}
        updateDropDown()
        templateDropDown.selectedValue = nil
        templateDropDown.reloadItem()
    }
}
