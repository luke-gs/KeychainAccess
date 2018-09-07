//
//  OrderSummaryViewController.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public class OrderSummaryViewController: FormBuilderViewController {

    private var viewModel: OrderSummaryViewModel

    init(viewModel: OrderSummaryViewModel) {
        self.viewModel = viewModel
        super.init()
        title = "Orders"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(UIViewController.dismissAnimated))
        loadingManager.state = .loaded
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.enforceLinearLayout = .always

        builder += LargeTextHeaderFormItem(text: viewModel.type)
            .separatorColor(.clear)
            .textAlignment(.center)
            .layoutMargins(UIEdgeInsets(top: 4, left: 48, bottom: 16, right: 48))

        builder += RowDetailFormItem(title: viewModel.statusLabel, detail: viewModel.statusValue)
            .separatorColor(.clear)

        builder += RowDetailFormItem(title: viewModel.issuingAuthorityLabel, detail: viewModel.issuingAuthorityValue)
            .separatorColor(.clear)

        builder += RowDetailFormItem(title: viewModel.dateIssuedLabel, detail: viewModel.dateIssuedValue)
            .separatorColor(.clear)

        builder += RowDetailFormItem(title: viewModel.dateOfExpiryLabel, detail: viewModel.dateOfExpiryValue)

        builder += LabelFormItem(text: viewModel.orderDescription)
    }
}
