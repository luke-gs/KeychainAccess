//
//  TrafficInfringementServiceViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit
import DemoAppKit

open class TrafficInfringementServiceViewController: FormBuilderViewController, EvaluationObserverable {

    let viewModel: TrafficInfringementServiceViewModel

    public init(viewModel: TrafficInfringementServiceViewModel) {
        self.viewModel = viewModel

        super.init()
        viewModel.report.evaluator.addObserver(self)

        self.title = viewModel.title

        sidebarItem.regularTitle = title
        sidebarItem.compactTitle = title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.service)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor

        loadingManager.noContentView.titleLabel.text = "No Entities Added"
        loadingManager.noContentView.subtitleLabel.text = "Service requires a person or organisation"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingManager.state = viewModel.currentLoadingManagerState
        self.viewModel.updateValidation()
        reloadForm()
    }

    override open func construct(builder: FormBuilder) {
        builder.title = title
        builder.enforceLinearLayout = .always

        builder += LargeTextHeaderFormItem(text: "Service Type")
            .separatorColor(.clear)
        builder += OptionDisplayableFormItem(options: [ServiceType.email, ServiceType.mms, ServiceType.post])
            .selectedIndex(viewModel.report.selectedServiceType?.rawValue)
            .selectionHandler({ (index) in
                if let serviceType = ServiceType(rawValue: index) {
                    self.viewModel.selectedServiceType(type: serviceType)
                }
                self.viewModel.updateValidation()
                self.reloadForm()
            })

        if let selectedServiceType = viewModel.report.selectedServiceType {
            builder += LargeTextHeaderFormItem(text: "Details")
                .separatorColor(.clear)
            
            switch selectedServiceType {
            case .email:

                builder += DropDownFormItem(title: "Email Address")
                    .required()
                    .width(.column(1))
                    .options(viewModel.allEmails)
                    .selectedValue(viewModel.selectedValues(for: selectedServiceType))
                    .onValueChanged({ (value) in
                        guard let value = value else { return }
                        self.viewModel.setSelectedEmail(emails: value)
                        self.viewModel.updateValidation()
                    })

            case .mms:

                builder += DropDownFormItem(title: "Phone Number")
                    .required()
                    .options(viewModel.allMobiles)
                    .selectedValue(viewModel.selectedValues(for: selectedServiceType))
                    .onValueChanged({ (value) in
                        guard let value = value else { return }
                        self.viewModel.setSelectedMobile(mobiles: value)
                        self.viewModel.updateValidation()
                    })
                    .width(.column(1))
            default:
                break
            }

            builder += DropDownFormItem(title: "Residential Address")
                .required()
                .width(.column(1))
                .options(viewModel.allFullAddresses)
                .selectedValue(viewModel.selectedValues(for: ServiceType.post))
                .onValueChanged({ (value) in
                    guard let value = value else { return }
                    self.viewModel.setSelectedAddress(addresses: value)
                    self.viewModel.updateValidation()
                })
        }
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }
}
