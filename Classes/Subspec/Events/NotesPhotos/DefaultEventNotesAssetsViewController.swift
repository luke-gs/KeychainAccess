//
//  DefaultEventNotesAssetsViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class DefaultEventNotesAssetsViewController: FormBuilderViewController, EvaluationObserverable {
    
    var viewModel: DefaultEventNotesAssetsViewModel
    
    public init(viewModel: DefaultEventNotesAssetsViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.report?.evaluator.addObserver(self)
        
        sidebarItem.regularTitle = "Notes and Assets"
        sidebarItem.compactTitle = "Notes and Assets"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.attachment)!
        sidebarItem.color = viewModel.tabColour()
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report?.viewed = true
    }
    
    override open func construct(builder: FormBuilder) {
        builder.title = sidebarItem.regularTitle
        builder.forceLinearLayout = true

        // Media Section
        let localStore = DataStoreCoordinator(dataStore: MediaStorageDatastore(items: viewModel.report.media, container: viewModel.report))
        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: localStore)
        let mediaItem = MediaFormItem()
            .dataSource(gallery)
            .emptyStateContents(EmptyStateContents(
                title: "No Assets", 
                subtitle: "Edit assets by tapping on 'Edit' button."))

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }
        builder += HeaderFormItem(text: "ASSETS").actionButton(title: "EDIT", handler: { button in
            if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                self.present(viewController, animated: true, completion: nil)
            }
        })
        builder += mediaItem

        // General Section
        builder += HeaderFormItem(text: "GENERAL")
        builder += TextFieldFormItem(title: "Operation Name", text: viewModel.report.operationName)
            .onValueChanged(viewModel.operationNameChanged)

        // Summary Section
        builder += HeaderFormItem(text: "SUMMARY / NOTES").actionButton(title: "USE TEMPLATE", handler: { _ in })
        builder += TextFieldFormItem(title: "Free Text", text: viewModel.report.freeText)
            .onValueChanged(viewModel.freeTextChanged)
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }
}
