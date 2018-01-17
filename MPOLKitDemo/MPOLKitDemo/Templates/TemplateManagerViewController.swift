//
//  TemplateManagerViewController.swift
//  MPOLKitDemo
//
//  Created by Kara Valentine on 15/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class TemplateManagerViewController: FormBuilderViewController {

    // todo
    // - plus button to add template
    // - add template dialog
    // - sort templates alphabetically when selecting
    // - add sections on left like form examples
    // - add text field for further editing
    // - second formview for listing and editing templates

    lazy var templateDropDown: DropDownFormItem<Template> = DropDownFormItem().title("Select a template").options(Array(TemplateManager.shared.allTemplates()))

    lazy var templateTextField = TextViewFormItem()
        .title("Template Text")
        .height(.fixed(120.0))

    override init() {
        super.init()

        title = "Templates"

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashTapped))
        ]
    }

    override func construct(builder: FormBuilder) {
        TemplateManager.shared.delegate = TemplateDemoDelegate()

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

        TemplateManager.shared.saveExternalTemplates()
    }

    func updateDropDown() {
        templateDropDown.options = Array(TemplateManager.shared.allTemplates())
    }

    @objc func addTapped() {
        let templateAddViewController = TemplateAddViewController()
        templateAddViewController.completion = { self.updateDropDown() }
        let navigationController = UINavigationController(rootViewController: templateAddViewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true, completion: nil)
    }

    @objc func trashTapped() {
        TemplateManager.shared.removeAll()
        TemplateManager.shared.saveExternalTemplates()
        updateDropDown()
        templateDropDown.selectedValue = nil
        templateDropDown.reloadItem()
    }
}
