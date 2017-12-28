//
//  PatrolAreaListViewController.swift
//  MPOLKit
//
//  Created by Megan Efron on 28/12/17.
//

import UIKit

open class PatrolAreaListViewController: GenericSearchViewController {
    
    open var patrolAreaListViewModel: PatrolAreaListViewModel? {
        return viewModel as? PatrolAreaListViewModel
    }
    
    /// Support being transparent when in popover/form sheet
    open override var wantsTransparentBackground: Bool {
        didSet {
            let theme = ThemeManager.shared.theme(for: .current)
            view.backgroundColor = wantsTransparentBackground ? .clear : theme.color(forKey: .background)!
        }
    }
    
    // MARK: - Setup

    required public init(viewModel: GenericSearchViewModel) {
        super.init(viewModel: viewModel)
        delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .done, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(doneTapped))
    }
    
    // MARK: - Actions
    
    @objc public func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc public func doneTapped() {
        // TODO: Change patrol area
        navigationController?.popViewController(animated: true)
    }

}

extension PatrolAreaListViewController: GenericSearchDelegate {
    public func genericSearchViewController(_ viewController: GenericSearchViewController, didSelectRowAt indexPath: IndexPath, withSearchable searchable: GenericSearchable) {
        if let patrolArea = searchable as? PatrolAreaListItemViewModel {
            patrolAreaListViewModel?.selectedPatrolArea = patrolArea.patrolArea
            reloadForm()
        }
    }
}
