//
//  DefaultEventNotesMediaViewController.swift
//  MPOLKit
//
//  Created by Kara Valentine on 9/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class DefaultEventNotesMediaViewController: FormBuilderViewController, EvaluationObserverable {

    var viewModel: DefaultEventNotesMediaViewModel
    weak var delegate: EventSubmitter?

    public init(viewModel: DefaultEventNotesMediaViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.report?.evaluator.addObserver(self)

        sidebarItem.regularTitle = "Notes and Media"
        sidebarItem.compactTitle = "Notes and Media"
        sidebarItem.image = AssetManager.shared.image(forKey: AssetManager.ImageKey.attachment)!
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.horizontalSizeClass != .regular {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitEvent))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        MPLUnimplemented()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.report?.viewed = true
        /// Need to put this here because the right bar button items get set back to nil elsewhere (in the MPOLSplitViewController)
        if traitCollection.horizontalSizeClass != .regular {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitEvent))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    override open func construct(builder: FormBuilder) {
        builder.title = sidebarItem.regularTitle
        builder.enforceLinearLayout = .always

        // General Section
        builder += LargeTextHeaderFormItem(text: "General")
            .separatorColor(.clear)
        builder += TextFieldFormItem(title: "Operation Name", text: viewModel.report.operationName)
            .onValueChanged(viewModel.operationNameChanged)

        // Summary Section
        builder += LargeTextHeaderFormItem(text: "Summary / Notes")
            .separatorColor(.clear)
            .actionButton(title: "Use Template", handler: { _ in })
        builder += TextFieldFormItem(title: "Free Text", text: viewModel.report.freeText)
            .onValueChanged(viewModel.freeTextChanged)

        // Media Section
        let localStore = DataStoreCoordinator(dataStore: MediaStorageDatastore(items: viewModel.report.media, container: viewModel.report))
        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: localStore)
        let mediaItem = MediaFormItem()
            .dataSource(gallery)
            .emptyStateContents(EmptyStateContents(
                title: "No Media",
                subtitle: "Edit media by tapping on 'Edit' button."))

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }
        builder += LargeTextHeaderFormItem(text: "Media")
            .separatorColor(.clear)
            .actionButton(title: "Manage", handler: { _ in
                if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                    self.present(viewController, animated: true, completion: nil)
                }
            })
        builder += mediaItem
    }

    public func evaluationChanged(in evaluator: Evaluator, for key: EvaluatorKey, evaluationState: Bool) {
        sidebarItem.color = viewModel.tabColors.defaultColor
        sidebarItem.selectedColor = viewModel.tabColors.selectedColor
    }

    @objc func submitEvent() {
        delegate?.presentEventSummary()
    }
}

/// Can submit the event
// TODO: Fix this cause wow this is bad and I'm sorry I even wrote this.
public protocol EventSubmitter: class {
    func presentEventSummary()
}
