//
//  OfficerSearchViewModel.swift
//  MPOL
//
//  Created by QHMW64 on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit
import PromiseKit

class OfficerSearchViewModel: SearchDisplayableViewModel {

    typealias Object = Officer

    var title: String = "Add officer"

    lazy var cancelToken: PromiseCancellationToken = PromiseCancellationToken()

    private var objectDisplayMap: [Object: CustomSearchDisplayable] = [:]
    public private(set) var items: [Object] = []

    public init(items: [Object] = []) {
        self.items = items
    }

    var hasSections: Bool = false

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
        return ""
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

        let searchable = OfficerSearchDisplayable(officer: object)
        objectDisplayMap[object] = searchable
        return searchable
    }

    func object(for indexPath: IndexPath) -> Officer {
        return items[indexPath.item]
    }

    func searchTextChanged(to searchString: String) {
        cancelToken.cancel()
    }

    func searchAction() -> Promise<Void>? {
        let parameters = OfficerSearchParameters(familyName: "Black")
        let request = OfficerSearchRequest(source: .pscore, request: parameters)
        return request.searchPromise(withCancellationToken: cancelToken).then {
            self.items = $0.results
            return Promise()
        }
    }
}

public struct OfficerSearchDisplayable: CustomSearchDisplayable {

    public let officer: Officer

    public init(officer: Officer) {
        self.officer = officer
    }

    // MARK: - Searchable

    public var title: String? {
        return [officer.givenName, officer.surname].joined()
    }

    public var subtitle: String? {
        return [officer.rank, "#\(String(describing: officer.employeeNumber))"].joined(separator: ThemeConstants.dividerSeparator)
    }

    public var section: String?
    public var image: UIImage? {
        if let initials = officer.initials {
            return UIImage.thumbnail(withInitials: initials).withCircleBackground(tintColor: nil,
                                                                                  circleColor: .disabledGray,
                                                                                  style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                                padding: CGSize(width: 14, height: 14)))
        }
        return nil
    }

    public func contains(_ searchText: String) -> Bool {
        let searchStringLowercase = searchText.lowercased()

        let matchesFirstName = officer.givenName?.lowercased().hasPrefix(searchStringLowercase) ?? false
        let matchesLastName = officer.surname?.lowercased().hasPrefix(searchStringLowercase) ?? false
        let matchesCallsign = officer.employeeNumber?.lowercased().hasPrefix(searchStringLowercase) ?? false

        return matchesFirstName || matchesLastName || matchesCallsign
    }

}
