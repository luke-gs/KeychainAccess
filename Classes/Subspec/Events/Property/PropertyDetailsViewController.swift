//
//  PropertyDetailsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public protocol AddPropertyDelegate {
    func didTapOnPropertyType()
}

public class PropertyDetailsViewController: FormBuilderViewController {

    let viewModel: PropertyDetailsViewModel

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        title = "Add Property"
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadForm()
    }

    public override func construct(builder: FormBuilder) {
        builder.title = title
        viewModel.plugins?.forEach{builder += $0.decorator.formItems()}
    }
}
