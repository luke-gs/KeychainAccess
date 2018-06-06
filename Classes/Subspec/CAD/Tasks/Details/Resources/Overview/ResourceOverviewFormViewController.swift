//
//  ResourceOverviewFormViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 5/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOverviewFormViewController: IntrinsicHeightFormBuilderViewController {
    
    public let viewModel: ResourceOverviewViewModel
    
    public init(viewModel: ResourceOverviewViewModel) {
        self.viewModel = viewModel
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    open override func construct(builder: FormBuilder) {
        if let currentIncident = viewModel.currentIncidentViewModel {
            builder += HeaderFormItem(text: viewModel.respondingToHeaderTitle(), style: .collapsible)
            
            builder += IncidentSummaryFormItem(viewModel: currentIncident)
                .accessory(ItemAccessory.disclosure)
                .separatorStyle(.fullWidth)
                .onSelection({ [unowned self] cell in
                    guard let incident = CADStateManager.shared.incidentsById[currentIncident.identifier] else { return }
                    
                    // Present the resource split view controller
                    let viewModel = IncidentTaskItemViewModel(incident: incident)
                    self.present(TaskItemScreen.landing(viewModel: viewModel))
                })
        }
        
        for section in viewModel.sections {
            builder += HeaderFormItem(text: section.title?.uppercased(),
                                      style: .collapsible)
            
            for item in section.items {
                if item.title == "Current Incident" {
                    
                } else {
                    builder += ValueFormItem(title: item.title, value: item.value, image: item.image).width(item.width)
                }
            }
        }
    }
}
