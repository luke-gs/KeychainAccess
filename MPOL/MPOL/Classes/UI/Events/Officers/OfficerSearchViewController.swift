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

    override open func construct(builder: FormBuilder) {
        builder.enforceLinearLayout = .always
        builder.title = viewModel.title

        for section in 0..<viewModel.numberOfSections() {
            if viewModel.hasSections == true && viewModel.isSectionHidden(section) == false {
                builder += LargeTextHeaderFormItem(text: viewModel.title(for: section))
                    .separatorColor(.clear)
            }
            for row in 0..<viewModel.numberOfRows(in: section) {
                let indexPath = IndexPath(row: row, section: section)
                builder += SubtitleFormItem(title: viewModel.title(for: indexPath),
                                            subtitle: viewModel.description(for: indexPath),
                                            image: viewModel.image(for: indexPath),
                                            style: .default)
                    .accessory(viewModel.accessory(for: viewModel.searchable(for: viewModel.object(for: indexPath))))
                    .onSelection { [unowned self] cell in

                        // add officer to recently used
                        try? UserPreferenceManager.shared.addRecentId(self.viewModel.object(for: indexPath).id, forKey: .recentOfficers, trimToMaxElements: 5)
                        
                        self.delegate?.genericSearchViewController(self, didSelectRowAt: indexPath, withObject: self.viewModel.object(for: indexPath))
                }
            }
        }
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
