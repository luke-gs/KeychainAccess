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

    var cancelToken: PromiseCancellationToken?
    private var objectDisplayMap: [Object: CustomSearchDisplayable] = [:]
    var searchText: String?
    private var sections: [OfficerSearchSectionViewModel] = []

    public func fetchRecentOfficers() -> Promise<Void> {

        sections = []

        // Add officers from myCallSign except yourself
        if let myCallSignOfficers = CADStateManager.shared.lastBookOn?.employees.compactMap({ $0 as? Object })
            .filter({ $0.id !=  CADStateManager.shared.officerDetails?.id}), !myCallSignOfficers.isEmpty {

            sections.append(OfficerSearchSectionViewModel(items: myCallSignOfficers,
                                                          title: NSLocalizedString("My Call Sign", comment: "Officer Search - My CallSign Section Title")))
        }

        // Add officers from UserPreferences recentlyUsed

        let userPreferenceManager = UserPreferenceManager.shared

        guard let officerIds: [String] = userPreferenceManager.preference(for: .recentOfficers)?.codables(),
            !officerIds.isEmpty else {
                return Promise<Void>()
        }

        return RecentlyUsedEntityManager.default.entities(forIds: officerIds, ofServerType: Officer.serverTypeRepresentation).done { [weak self] result in
            let recentOfficers = officerIds.compactMap { result[$0] as? Officer }

            if !recentOfficers.isEmpty {
                self?.sections.append(OfficerSearchSectionViewModel(items: recentOfficers,
                                                                    title: NSLocalizedString("Recently Used", comment: "Officer Search - Recently Used Section Title")))
            }
        }.map {}
    }

    public func cellSelectedAt(_ indexPath: IndexPath) {

        // add officer to recently used
        let officer = object(for: indexPath)
        try? UserPreferenceManager.shared.addRecentId(officer.id, forKey: .recentOfficers, trimToMaxElements: 5)
        RecentlyUsedEntityManager.default.add(officer)
    }

    // MARK: - SearchDisplayableViewModel

    var title: String = "Add Officer"
    var hasSections = true

    func numberOfSections() -> Int {
        return sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        return sections[section].items.count
    }

    func isSectionHidden(_ section: Int) -> Bool {
        return sections[section].items.isEmpty
    }

    func title(for section: Int) -> String {
        return sections[section].title
    }

    func title(for indexPath: IndexPath) -> StringSizable? {
        return searchable(for: object(for: indexPath)).title
    }

    func description(for indexPath: IndexPath) -> StringSizable? {
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
                                                  rank: object.rank,
                                                  employeeNumber: object.employeeNumber,
                                                  section: object.region)
        objectDisplayMap[object] = searchable
        return searchable
    }

    func object(for indexPath: IndexPath) -> Officer {
        return sections[indexPath.section].items[indexPath.row]
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
                context.sections = [OfficerSearchSectionViewModel(items: $0.results,
                                                                  title: NSLocalizedString("Results", comment: "Officer Search - Result Section Title"))]
            }
        }
    }

    func loadingStateText() -> String? {
        return NSLocalizedString("Retrieving Officers", comment: "Officer Search - Loading State Text")
    }

    func emptyStateTitle() -> String? {
        return NSLocalizedString("No Recently Used Officers", comment: "Officer Search - Empty State Title Text")
    }

    func emptyStateSubtitle() -> String? {
        return NSLocalizedString("You can search for an officer by either their Last name, First Name or ID Number", comment: "Officer Search - Empty State Subtitle Text")
    }
}

extension UserPreferenceKey {
    public static let recentOfficers = UserPreferenceKey("recentOfficers")
}
