//
//  ResourceOverviewFormViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 5/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class ResourceOverviewFormViewController: FormBuilderViewController {
    
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
            
            builder += CustomFormItem(cellType: TasksListItemCollectionViewCell.self, reuseIdentifier: "CurrentTaskCell")
                .onConfigured({ [unowned self] (cell) in
                    // Configure the cell
                    if let cell = cell as? TasksListItemCollectionViewCell {
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
    
    open override func collectionViewClass() -> UICollectionView.Type {
        return IntrinsicHeightCollectionView.self
    }
    
    open func decorate(cell: TasksListItemCollectionViewCell, with viewModel: TasksListItemViewModel) {
        cell.highlightStyle = .fade
        cell.separatorStyle = .fullWidth
        
        cell.titleLabel.text = viewModel.title
        cell.titleLabel.textColor = .primaryGray
        cell.subtitleLabel.text = viewModel.subtitle
        cell.subtitleLabel.textColor = .secondaryGray
        cell.captionLabel.text = viewModel.caption
        cell.captionLabel.textColor = .secondaryGray
        cell.updatesIndicator.isHidden = true
        
        cell.configurePriority(text: viewModel.badgeText,
                               textColor: viewModel.badgeTextColor,
                               fillColor: viewModel.badgeFillColor,
                               borderColor: viewModel.badgeBorderColor)
    }
}
