//
//  OfficerSearchViewModel.swift
//  MPOL
//
//  Created by QHMW64 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit
import PromiseKit

public class OfficerFetchRequest: EntityDetailFetchRequest<Officer> {

    public override func fetchPromise() -> Promise<Officer> {
        return APIManager.shared.fetchEntityDetails(in: source, with: request)
    }

}

public protocol OfficerSearchViewModelDelegate {
    func itemsDidUpdate()
}


class OfficerSearchViewModel: SearchDisplayableViewModel {
    typealias Object = Officer

    var title: String = "Add Officer"
    var cancelToken: PromiseCancellationToken?
    var hasSections: Bool = true

    private var objectDisplayMap: [Object: CustomSearchDisplayable] = [:]
    public private(set) var items: [Object] {
        didSet {
            delegate?.itemsDidUpdate()
        }
    }
    var searchText: String?
    var delegate: OfficerSearchViewModelDelegate?

    public init(items: [Object]? = nil) {

        if let items = items {
            self.items = items
        } else {
            self.items = []

            fetchRecentOfficers()
        }
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return items.count
    }

    func isSectionHidden(_ section: Int) -> Bool {
        return false
    }

    func title(for section: Int) -> String {
        return "Recently Used"
    }

    func title(for indexPath: IndexPath) -> String? {
        return searchable(for: items[indexPath.item]).title
    }

    func description(for indexPath: IndexPath) -> String? {
        return searchable(for: items[indexPath.item]).subtitle
    }

    func image(for indexPath: IndexPath) -> UIImage? {
        return searchable(for: items[indexPath.item]).image
    }

    func accessory(for searchable: CustomSearchDisplayable) -> ItemAccessorisable? {
        return ItemAccessory.disclosure
    }

    func searchable(for object: Object) -> CustomSearchDisplayable {
        if let existingSearchable = objectDisplayMap[object] {
            return existingSearchable
        }
        let searchable = OfficerListItemViewModel(firstName: object.givenName!,
                                                  lastName: object.familyName!,
                                                  initials: object.initials!,
                                                  rank: object.rank ?? "",
                                                  callsign: object.employeeNumber!,
                                                  section: object.region ?? "")
        objectDisplayMap[object] = searchable
        return searchable
    }

    func object(for indexPath: IndexPath) -> Officer {
        return items[indexPath.item]
    }

    func searchTextChanged(to searchString: String) {
        cancelToken?.cancel()
        searchText = searchString
    }

    func searchAction() -> Promise<Void>? {
        guard let searchText = searchText, !searchText.isEmpty else { return nil }

        let definition = OfficerParserDefinition()
        let personParserResults = try? QueryParser(parserDefinition: definition).parseString(query: searchText)
        let parameters = OfficerSearchParameters(familyName: personParserResults?[OfficerParserDefinition.SurnameKey] ?? searchText,
                                                 givenName: personParserResults?[OfficerParserDefinition.GivenNameKey])
        let request = OfficerSearchRequest(source: .pscore, request: parameters)

        cancelToken?.cancel()
        cancelToken = PromiseCancellationToken()

        return request.searchPromise(withCancellationToken: cancelToken).done { [weak self] in

            if let context = self {
                context.items = $0.results

                // Once we complete a search, remove the sections (i.e. the Recently Used text)
                if context.hasSections {
                    context.hasSections = false
                }
            }
        }
    }

    func loadingStateText() -> String? {
        return "Searching"
    }

    func emptyStateText() -> String? {
        return "No Recently Used Officers"
    }

    func fetchRecentOfficers() {

        let userPreferenceManager = UserPreferenceManager.shared
        if let officerIds: [String] = userPreferenceManager.preference(for: .recentOfficers)?.codables() {
            if !officerIds.isEmpty {

                self.items = []

                let x = officerIds.map {
                    OfficerFetchRequest(source: MPOLSource.pscore, request: EntityFetchRequest<Officer>(id: $0)).fetchPromise()
                }

                when(resolved: x).done { results in

                    results.forEach { result in
                        switch result {
                            case .fulfilled(let officer):
                                self.items.append(officer)
                            case .rejected(let error):
                                print(error)
                        }
                    }
                }
            }
        }
    }
}

extension SearchDisplayableViewController: OfficerSearchViewModelDelegate where T.Object == Officer {
    public func itemsDidUpdate() {
        reloadForm()
    }
}

extension UserPreferenceKey {
    public static let recentOfficers = UserPreferenceKey("recentOfficers")
}
