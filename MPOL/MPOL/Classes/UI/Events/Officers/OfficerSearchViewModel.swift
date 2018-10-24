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
        return items.isEmpty ? 0 : 2
    }

    func numberOfRows(in section: Int) -> Int {

        switch section {
        case 0:
            return officersByType.CADOfficers.count
        case 1:
            return officersByType.searchOfficers.count
        default:
            return 0
        }
    }

    func isSectionHidden(_ section: Int) -> Bool {

        switch section {
        case 0:
            return officersByType.CADOfficers.isEmpty
        case 1:
            return officersByType.searchOfficers.isEmpty
        default:
            return false
        }
    }

    func title(for section: Int) -> String {

        switch section {
        case 0:
            return "My Call Sign"
        case 1:
            return "Recently Used"
        default:
            return "Items"
        }
    }

    func title(for indexPath: IndexPath) -> String? {
        return searchable(for: object(for: indexPath)).title
    }

    func description(for indexPath: IndexPath) -> String? {
        return searchable(for: object(for: indexPath)).subtitle
    }

    func image(for indexPath: IndexPath) -> UIImage? {
        return searchable(for: object(for: indexPath)).image
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
                                                  employeeNumber: object.employeeNumber ?? "",
                                                  section: object.region ?? "")
        objectDisplayMap[object] = searchable
        return searchable
    }

    func object(for indexPath: IndexPath) -> Officer {
        switch indexPath.section {
        case 0:
            return officersByType.CADOfficers[indexPath.row]
        default:
            return officersByType.searchOfficers[indexPath.row]
        }
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

        items.removeAll()

        // Add officers from myCallSign
        if let myCallSignOfficers = CADStateManager.shared.lastBookOn?.employees as? [CADOfficerCore] {
            items = myCallSignOfficers
        }

        //Add officers from UserPreferences recentlyUsed

        let userPreferenceManager = UserPreferenceManager.shared

        guard let officerIds: [String] = userPreferenceManager.preference(for: .recentOfficers)?.codables(),
        !officerIds.isEmpty else {
            return Promise<Void>()
        }

        return RecentlyUsedEntityManager.default.entities(forIds: officerIds, ofServerType: Officer.serverTypeRepresentation).done { [weak self] result in
            self?.items += officerIds.compactMap { result[$0] as? Officer }
            print("mate")
        }.map {}
    }

    public func cellSelectedAt(_ indexPath: IndexPath) {

        // add officer to recently used
        let officer = object(for: indexPath)
        try? UserPreferenceManager.shared.addRecentId(officer.id, forKey: .recentOfficers, trimToMaxElements: 5)
        RecentlyUsedEntityManager.default.add(officer)
    }

    private var officersByType: (CADOfficers: [Object], searchOfficers: [Object]) {

        var CADOfficers: [Object] = []
        var searchOfficers: [Object] = []

        items.forEach { officer in
            if officer is CADOfficerCore {
                CADOfficers.append(officer)
            } else {
                searchOfficers.append(officer)
            }
        }
        return (CADOfficers: CADOfficers, searchOfficers: searchOfficers)
    }
}

extension UserPreferenceKey {
    public static let recentOfficers = UserPreferenceKey("recentOfficers")
}
