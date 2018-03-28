//
//  ManageCallsignIncidentFormViewController.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Form view controller for displaying current incident of callsign
open class ManageCallsignIncidentFormViewController: FormBuilderViewController {

    open var listViewModel: TasksListIncidentViewModel?

    // MARK: - Initializers

    public init(listViewModel: TasksListIncidentViewModel?) {
        self.listViewModel = listViewModel
        super.init()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent bounce scroll for fixed item
        collectionView?.alwaysBounceVertical = false
    }

    // MARK: - Form

    override open func construct(builder: FormBuilder) {
        // Show current incident with header if set
        if let listViewModel = self.listViewModel {
            builder += HeaderFormItem(text: NSLocalizedString("Current Incident", comment: "").uppercased(), style: .plain)
            builder += IncidentSummaryFormItem(viewModel: listViewModel)
                .separatorStyle(.none)
                .selectionStyle(.none)
                .accessory(ItemAccessory.disclosure)
                .onSelection({ [unowned self] cell in
                    // Present the incident split view controller
                    if let viewModel = listViewModel.createItemViewModel() {
                        self.present(TaskItemScreen.landing(viewModel: viewModel))
                    }
                })
        }
    }
}

