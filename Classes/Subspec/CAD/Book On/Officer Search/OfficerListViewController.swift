//
//  OfficerListViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 23/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class OfficerListViewController: GenericSearchViewController {
    
    open var officerListViewModel: OfficerListViewModel? {
        return viewModel as? OfficerListViewModel
    }
        
    public required init(viewModel: GenericSearchViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelTapped))
    }
    
    /// Support being transparent when in popover/form sheet
    open override var wantsTransparentBackground: Bool {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? UIColor.clear : theme.color(forKey: .background)!
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let cell = cell as? CollectionViewFormCell {
            cell.separatorColor = iOSStandardSeparatorColor
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
        if let header = view as? CollectionViewFormHeaderView {
            header.separatorColor = iOSStandardSeparatorColor
        }
    }
    
    @objc public func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension OfficerListViewController: GenericSearchDelegate {
    public func genericSearchViewController(_ viewController: GenericSearchViewController, didSelectRowAt indexPath: IndexPath, withSearchable: GenericSearchable) {
        if let officer = withSearchable as? OfficerListItemViewModel {

            if let officerDetailsViewController = officerListViewModel?.officerDetailsViewController(for: officer) {
                self.navigationController?.pushViewController(officerDetailsViewController, animated: true)
            }
        }
    }
}

extension OfficerListViewController: OfficerListViewModelDelegate {
    public func itemSelectedAndFinishedEditing() {
        self.navigationController?.popViewController(animated: true)
    }
}
