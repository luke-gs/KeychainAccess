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

        self.loadingManager.state = .loading
        viewModel.fetchRecentOfficers().done {
            self.loadingManager.state = self.viewModel.numberOfSections() == 0 ? .noContent : .loaded 
            self.reloadForm()
        }.cauterize()
    }

    override func cellSelectedAt(_ indexPath: IndexPath) {
        super.cellSelectedAt(indexPath)
        viewModel.cellSelectedAt(indexPath)
    }

}
