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
            
            builder += CustomFormItem(cellType: TasksListIncidentCollectionViewCell.self, reuseIdentifier: "CurrentTaskCell")
                .onConfigured({ [unowned self] (cell) in
                    // Configure the cell
                    if let cell = cell as? TasksListIncidentCollectionViewCell {
                        self.decorate(cell: cell, with: currentIncident)
                    }
                })
                .accessory(ItemAccessory.disclosure)
                .height(.fixed(64))
                .onSelection({ [unowned self] cell in
                    guard let resource = CADStateManager.shared.resourcesById[self.viewModel.callsign],
                        let incident = CADStateManager.shared.incidentsById[currentIncident.identifier]
                    else {
                        return
                    }
                    
                    // Present the resource split view controller
                    let viewModel = IncidentTaskItemViewModel(incident: incident, resource: resource)
                    let vc = TasksItemSidebarViewController(viewModel: viewModel)
                    self.pushableSplitViewController?.navigationController?.pushViewController(vc, animated: true)
                })
        }
        for section in viewModel.sections {
            builder += HeaderFormItem(text: section.title.uppercased(),
                                      style: .collapsible)
            
            for item in section.items {
                if item.title == "Current Incident" {
                    
                } else {
                    builder += ValueFormItem(title: item.title, value: item.value, image: item.image).width(item.width)
                }
            }
        }
    }
    
    open func decorate(cell: TasksListIncidentCollectionViewCell, with viewModel: TasksListIncidentViewModel) {
        cell.highlightStyle = FadeStyle.highlight()
        cell.separatorStyle = .fullWidth
        
        cell.decorate(with: viewModel)

        cell.summaryView.titleLabel.textColor = .primaryGray
        cell.summaryView.subtitleLabel.textColor = .secondaryGray
        cell.summaryView.captionLabel.textColor = .secondaryGray
    }
}
