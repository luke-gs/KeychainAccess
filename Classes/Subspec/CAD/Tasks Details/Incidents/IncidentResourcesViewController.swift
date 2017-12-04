//
//  IncidentResourcesViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 4/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class IncidentResourcesViewController: FormBuilderViewController {
    open let viewModel: CADFormCollectionViewModel<IncidentResourceItemViewModel>
    
    public init(viewModel: CADFormCollectionViewModel<IncidentResourceItemViewModel>) {
        self.viewModel = viewModel
        super.init()
        
        title = viewModel.navTitle()
        sidebarItem.image = AssetManager.shared.image(forKey: .resourceGeneral)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }
    
    
    open override func construct(builder: FormBuilder) {
        for section in viewModel.sections {
            builder += HeaderFormItem(text: section.title, style: viewModel.shouldShowExpandArrow() ? .collapsible : .plain)
            for item in section.items {
                builder += SubtitleFormItem(title: item.title, subtitle: item.subtitle).width(.column(1))
                for officer in item.officers {
                    builder += CustomFormItem(cellType: OfficerCell.self, reuseIdentifier: "OfficerCell").onConfigured { cell in
                        guard let cell = cell as? OfficerCell else { return }
                        let commsView = OfficerCommunicationsView(frame: CGRect(x: 0, y: 0, width: 88, height: 32))
                        if self.traitCollection.horizontalSizeClass == .compact {
                            cell.accessoryView = FormAccessoryView(style: .overflow)
                        } else {
                            cell.accessoryView = commsView
                        }
                        
                        let (messageEnabled, callEnabled) = officer.commsEnabled
                        
                        commsView.messageButton.isEnabled = messageEnabled
                        commsView.callButton.isEnabled = callEnabled
                        
                        cell.titleLabel.text = officer.title
                        cell.subtitleLabel.text = officer.subtitle
                        cell.badgeLabel.text = officer.badgeText
                    }
                }
            }
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is OfficerCell {
            cell.layoutMargins.left = 80
            cell.contentView.layoutMargins.left = 80
        }
    }
}
