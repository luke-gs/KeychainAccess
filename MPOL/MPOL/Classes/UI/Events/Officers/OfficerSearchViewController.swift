//
//  OfficerSearchViewController.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import PublicSafetyKit

class OfficerSearchViewController<T: SearchDisplayableDelegate>: SearchDisplayableViewController<T, OfficerSearchViewModel> where T.Object == Officer {

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayRecentlyViewedOfficers()
    }

    override func cellSelectedAt(_ indexPath: IndexPath) {
        super.cellSelectedAt(indexPath)
        viewModel.cellSelectedAt(indexPath)
    }

    private func displayRecentlyViewedOfficers () {

        self.loadingManager.state = .loading
        viewModel.fetchRecentOfficers().done {
            self.loadingManager.state = self.viewModel.numberOfSections() == 0 ? .noContent : .loaded
            self.reloadForm()
        }.catch { error in
            self.loadingManager.state = .error
            self.loadingManager.errorView.titleLabel.text = error.localizedDescription
        }
    }

    // MARK: - UISearchBarDelegate

    override public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        super.searchBar(searchBar, textDidChange: searchText)

        // if we are currently showing search results and clear the search then display recently used
        guard viewModel.showSearchResults && searchText == "" else { return }
        displayRecentlyViewedOfficers()
    }

    override public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        super.searchBarCancelButtonClicked(searchBar)

        guard viewModel.showSearchResults else { return }
        displayRecentlyViewedOfficers()
    }
}
