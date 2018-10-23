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

class OfficerSearchViewModel: SearchDisplayableViewModel {
    typealias Object = Officer

    var title: String = "Add Officer"
    var cancelToken: PromiseCancellationToken?
    var hasSections: Bool = true

    private var objectDisplayMap: [Object: CustomSearchDisplayable] = [:]
    public private(set) var items: [Object]
    var searchText: String?

    public init(items: [Object]? = nil) {

        self.items = items ?? []
    }

    func numberOfSections() -> Int {
        return items.isEmpty ? 0 : 1
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
        let searchable = OfficerListItemViewModel(id: object.id,
                                                  firstName: object.givenName!,
                                                  lastName: object.familyName!,
                                                  initials: object.initials!,
                                                  rank: object.rank ?? "",
                                                  callsign: object.employeeNumber ?? "",
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
        return "Retrieving Officers"
    }

    func emptyStateText() -> String? {
        return "No Recently Used Officers"
    }

    public func fetchRecentOfficers() -> Promise<Void> {

        let userPreferenceManager = UserPreferenceManager.shared

        guard let officerIds: [String] = userPreferenceManager.preference(for: .recentOfficers)?.codables(),
        !officerIds.isEmpty else {
            return Promise<Void>()
        }

        items.removeAll()

        return RecentlyUsedEntityManager.default.entities(forIds: officerIds, ofServerType: Officer.serverTypeRepresentation).done { [weak self] result in
            self?.items = officerIds.compactMap { result[$0] as? Officer }
        }.map {}
    }

    public func cellSelectedAt(_ indexPath: IndexPath) {

        // add officer to recently used
        let officer = object(for: indexPath)
        try? UserPreferenceManager.shared.addRecentId(officer.id, forKey: .recentOfficers, trimToMaxElements: 5)
        RecentlyUsedEntityManager.default.add(officer)
    }
}

extension UserPreferenceKey {
    public static let recentOfficers = UserPreferenceKey("recentOfficers")
}
