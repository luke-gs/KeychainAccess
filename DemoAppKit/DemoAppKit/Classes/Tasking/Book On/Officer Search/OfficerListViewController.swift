//
//  OfficerListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class OfficerListViewController: SearchDisplayableViewController<OfficerListViewControllerSelectionHandler, OfficerListViewModel> {

    // Strong reference to selection handler
    private var selectionHandler: OfficerListViewControllerSelectionHandler?

    public required init(viewModel: OfficerListViewModel) {
        super.init(viewModel: viewModel)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelTapped))
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate to internal selection handler
        selectionHandler = OfficerListViewControllerSelectionHandler(self)
        delegate = selectionHandler

        loadingManager.noContentView.titleLabel.text = viewModel.noContentTitle()
    }

    open override func construct(builder: FormBuilder) {
        builder.enforceLinearLayout = .always
        builder.title = viewModel.title

        for section in 0..<viewModel.numberOfSections() {
            if viewModel.hasSections == true && viewModel.isSectionHidden(section) == false {
                builder += HeaderFormItem(text: viewModel.title(for: section))
            }
            for row in 0..<viewModel.numberOfRows(in: section) {
                let indexPath = IndexPath(row: row, section: section)
                builder += SubtitleFormItem(title: viewModel.title(for: indexPath),
                                            subtitle: viewModel.description(for: indexPath),
                                            image: viewModel.image(for: indexPath),
                                            style: .default)
                    .accessory(viewModel.accessory(for: viewModel.searchable(for: viewModel.object(for: indexPath))))
                    .onSelection { [unowned self] _ in
                        self.delegate?.genericSearchViewController(self, didSelectRowAt: indexPath, withObject: self.viewModel.object(for: indexPath))
                }
            }
        }
        // Update loading state based on whether there is any content
        loadingManager.state = builder.formItems.isEmpty ? .noContent : .loaded
    }

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)

        if let cell = cell as? CollectionViewFormCell {
            cell.separatorColor = ThemeManager.shared.theme(for: .current).color(forKey: .legacySeparator)
        }
    }

    override open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        if let header = view as? CollectionViewFormHeaderView {
            header.separatorColor = ThemeManager.shared.theme(for: .current).color(forKey: .legacySeparator)
        }
    }

    @objc public func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension OfficerListViewController: OfficerListViewModelDelegate {
    public func itemSelectedAndFinishedEditing() {
        self.navigationController?.popViewController(animated: true)
    }
}

// Separate class for SearchDisplayableDelegate implementation, due to cyclic reference in generic type inference
open class OfficerListViewControllerSelectionHandler: SearchDisplayableDelegate {
    public typealias Object = CustomSearchDisplayable
    private weak var listViewController: OfficerListViewController?

    init(_ listViewController: OfficerListViewController) {
        self.listViewController = listViewController
    }

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: CustomSearchDisplayable) {
        guard let listViewController = listViewController else { return }
        if let officer = object as? OfficerListItemViewModel {
            listViewController.present(listViewController.viewModel.officerDetailsScreen(for: officer))
        }
    }
}
