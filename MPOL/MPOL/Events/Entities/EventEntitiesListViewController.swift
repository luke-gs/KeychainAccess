//
//  EventEntitiesListViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

public class EventEntitiesListViewController : FormBuilderViewController {
    
    let viewModel: EventEntitiesListViewModel
    
    public init(viewModel: EventEntitiesListViewModel) {
        self.viewModel = viewModel
        super.init()
        
        self.title = "Entities"
        
        sidebarItem.regularTitle = self.title
        sidebarItem.compactTitle = self.title
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.list)!
        sidebarItem.color = viewModel.tabColour()
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingManager.state = viewModel.loadingManagerState()
    }
    
    public override func construct(builder: FormBuilder) {
        builder.title = self.title
        builder.forceLinearLayout = true

        builder += HeaderFormItem(text: viewModel.headerText)

        let entities = viewModel.report.entities

        builder += entities.map { entity in
            return viewModel.displayable(for: entity)
                .summaryListFormItem()
                .onSelection { cell in
                    guard let indexPath = self.collectionView?.indexPath(for: cell) else { return }
                    self.showDetailsFor(self.viewModel.entityFor(indexPath))
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        //text and image for "noContent" state
        loadingManager.noContentView.titleLabel.text = "No Entities Added"
        loadingManager.noContentView.subtitleLabel.text = "Entities added to an incident will appear here"
        loadingManager.noContentView.imageView.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.dialogAlert)
        
    }

    private func showDetailsFor(_ entity: MPOLKitEntity) {
        let viewModel = EventEntityDetailViewModel(entity: entity, event: self.viewModel.report.event!)
        let viewController = EventEntityDetailsSplitViewController(viewModel: viewModel)
        self.parent?.navigationController?.pushViewController(viewController, animated: true)
    }
}
