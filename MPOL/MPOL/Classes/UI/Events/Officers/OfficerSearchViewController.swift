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

        fetchRecentOfficers()
    }

    override func cellSelectedAt(_ indexPath: IndexPath) {
        super.cellSelectedAt(indexPath)

        // add officer to recently used
        try? UserPreferenceManager.shared.addRecentId(self.viewModel.object(for: indexPath).id, forKey: .recentOfficers, trimToMaxElements: 5)
    }

    private func fetchRecentOfficers() {

        let userPreferenceManager = UserPreferenceManager.shared
        if let officerIds: [String] = userPreferenceManager.preference(for: .recentOfficers)?.codables() {
            if !officerIds.isEmpty {

                viewModel.removeAllItems()

                self.loadingManager.state = .loading
                let officerRequests = officerIds.map {
                    OfficerFetchRequest(source: MPOLSource.pscore, request: EntityFetchRequest<Officer>(id: $0)).fetchPromise()
                }

                when(resolved: officerRequests).done { results in

                    results.forEach { result in
                        switch result {
                        case .fulfilled(let officer):
                            self.viewModel.appendItem(officer)
                        case .rejected(let error):
                            print(error)
                        }
                    }
                    self.loadingManager.state = .loaded
                    self.reloadForm()
                }
            }
        }
    }
}

public class OfficerFetchRequest: EntityDetailFetchRequest<Officer> {

    public override func fetchPromise() -> Promise<Officer> {
        return APIManager.shared.fetchEntityDetails(in: source, with: request)
    }
}

extension UserPreferenceKey {
    public static let recentOfficers = UserPreferenceKey("recentOfficers")
}
