//
//  DefaultEventNotesAssetsViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class DefaultEventNotesAssetsViewController: FormBuilderViewController, EvaluationObserverable {
    
    weak var report: DefaultNotesAssetsReport?
    
    public init(report: Reportable?) {
        self.report = report as? DefaultNotesAssetsReport
        super.init()
        report?.evaluator.addObserver(self)
        
        sidebarItem.regularTitle = "Notes and Assets"
        sidebarItem.compactTitle = "Notes and Assets"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.attachment)!
        sidebarItem.color = (report?.evaluator.isComplete ?? false) ? .midGreen : .red
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        report?.viewed = true
    }
    
    override open func construct(builder: FormBuilder) {
        guard let report = report else { return }
        builder.title = sidebarItem.regularTitle
        builder.forceLinearLayout = true

        // Media Section
        let localStore = DataStoreCoordinator(dataStore: MediaStorageDatastore(items: report.media, container: report))
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
        builder += TextFieldFormItem(title: "Operation Name", text: report.operationName).onValueChanged { value in
            self.report?.operationName = value
        }

        // Summary Section
        builder += HeaderFormItem(text: "SUMMARY / NOTES").actionButton(title: "USE TEMPLATE", handler: { _ in })
        builder += TextFieldFormItem(title: "Free Text", text: report.freeText).onValueChanged { value in
            self.report?.freeText = value
        }
    }
    
    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = evaluator.isComplete == true ? .midGreen : .red
    }
}
