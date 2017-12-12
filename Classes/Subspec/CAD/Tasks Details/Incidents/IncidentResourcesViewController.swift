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
                builder += SubtitleFormItem(title: item.title, subtitle: item.subtitle, image: item.icon).width(.column(1))
                for officer in item.officers {
                    builder += CustomFormItem(cellType: OfficerCell.self, reuseIdentifier: "OfficerCell")
                        .onConfigured { cell in
                            guard let cell = cell as? OfficerCell else { return }

                            let commsView = OfficerCommunicationsView(frame: CGRect(x: 0, y: 0, width: 72, height: 32),
                                                                      commsEnabled: officer.commsEnabled,
                                                                      contactNumber: officer.contactNumber)
                                .onTappedCall { _ in
                                    CommsButtonHandler.didSelectCall(for: officer.contactNumber)
                                }.onTappedMessage { _ in
                                    CommsButtonHandler.didSelectMessage(for: officer.contactNumber)
                                }
                            
                            if self.traitCollection.horizontalSizeClass == .compact {
                                cell.accessoryView = FormAccessoryView(style: .overflow)
                                    .onTapped { _ in
                                        CommsButtonHandler.didSelectCompactCommsButton(for: officer.contactNumber, enabled: officer.commsEnabled)
                                    }
                           } else {
                                cell.accessoryView = commsView
                            }
                            if let thumbnail = officer.thumbnail() {
                                cell.imageView.setImage(with: thumbnail)
                            }
                            cell.titleLabel.text = officer.title
                            cell.subtitleLabel.text = officer.subtitle
                            cell.badgeLabel.text = officer.badgeText
                            cell.leftLayoutMargin = 88
                        }
                }
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadForm()
    }
}

// MARK: - CADFormCollectionViewModelDelegate
extension IncidentResourcesViewController: CADFormCollectionViewModelDelegate {

    open func sectionsUpdated() {
        reloadForm()
    }
}
