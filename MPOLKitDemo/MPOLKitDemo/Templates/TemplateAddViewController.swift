//
//  TemplateAddViewController.swift
//  MPOLKitDemo
//
//  Created by Kara Valentine on 17/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class TemplateAddViewController: FormBuilderViewController {

    lazy var nameField = TextFieldFormItem(title: "Name").required()
    lazy var descriptionField = TextFieldFormItem(title: "Description").required()
    lazy var valueField = TextFieldFormItem(title: "Value").required()

    lazy var doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

    public var completion: () -> Void = {}

    var handler: TemplateHandler<UserDefaultsDataSource>?

    init(handler: TemplateHandler<UserDefaultsDataSource>) {
        self.handler = handler

        super.init()

        doneButton.isEnabled = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backTapped))
        navigationItem.rightBarButtonItem = doneButton
    }

    required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    override func construct(builder: FormBuilder) {
        builder.title = "Add Template"
        builder.forceLinearLayout = true

        builder.add(
            [nameField, descriptionField, valueField].map { $0.onValueChanged { _ in self.updateDoneButton() } }
        )
    }

    func updateDoneButton() {
        doneButton.isEnabled = nameField.text != nil &&
                               descriptionField.text != nil &&
                               valueField.text != nil
    }

    @objc func doneTapped() {
        handler?.source.store(template: TextTemplate(name: nameField.text as! String,
                                                      description: descriptionField.text as! String,
                                                      value: valueField.text as! String))
        completion()
        dismissAnimated()
    }

    @objc func backTapped() {
        dismissAnimated()
    }


}
