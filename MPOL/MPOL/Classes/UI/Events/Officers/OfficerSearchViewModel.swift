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
    public private(set) var items: [Object] {
        didSet {
            updateSectionItems()
        }
    }
    var searchText: String?

    private var sections: [OfficerSearchSectionViewModel] = []

    public init(items: [Object]? = nil) {

        sections.append(OfficerSearchSectionViewModel(items: [], title: "My Call Sign"))
        sections.append(OfficerSearchSectionViewModel(items: [], title: "Recently Used"))
        self.items = items ?? []
    }

    func numberOfSections() -> Int {
        return items.isEmpty ? 0 : sections.count
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
                                                  rank: object.rank ?? NSLocalizedString("Unknown Rank", comment: "Unknown Officer Rank Text"),
                                                  employeeNumber: object.employeeNumber ?? NSLocalizedString("Unknown Employee Number", comment: "Unknown Officer Employee Number Text"),
                                                  section: object.region ?? NSLocalizedString("Unknown Region", comment: "Unknown Officer Region Text"))
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

        // Add officers from myCallSign except yourself
        if let myCallSignOfficers = CADStateManager.shared.lastBookOn?.employees.compactMap({ $0 as? Object })
            .filter({ $0.id !=  CADStateManager.shared.officerDetails?.id}) {
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
        }.map {}
    }

    public func cellSelectedAt(_ indexPath: IndexPath) {

        // add officer to recently used
        let officer = object(for: indexPath)
        try? UserPreferenceManager.shared.addRecentId(officer.id, forKey: .recentOfficers, trimToMaxElements: 5)
        RecentlyUsedEntityManager.default.add(officer)
    }

    private func updateSectionItems() {

        // clear out section items
        sections.forEach { section in
            section.items = []
        }

        // set section items
        items.forEach { officer in
            if officer is CADOfficerCore {
                sections[0].items.append(officer)
            } else {
                sections[1].items.append(officer)
            }
        }
    }
}

extension UserPreferenceKey {
    public static let recentOfficers = UserPreferenceKey("recentOfficers")
}
