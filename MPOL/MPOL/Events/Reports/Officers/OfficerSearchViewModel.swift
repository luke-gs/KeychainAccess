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
        let searchable = OfficerListItemViewModel(firstName: object.givenName!,
                                                  lastName: object.surname!,
                                                  initials: object.initials!,
                                                  rank: object.rank!,
                                                  callsign: object.employeeNumber!,
                                                  section: object.region!)
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
