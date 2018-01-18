//
//  LookUpAddressSearchStrategy.swift
//  MPOLKit
//
//  Created by KGWH78 on 31/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit

extension LookupAddress: Locatable {
    
    public var textRepresentation: String {
        return fullAddress.isEmpty == false ? fullAddress : NSLocalizedString("Unknown address", comment: "")
    }
    
}

/// A default implementation of the search strategy that uses APIManager's type ahead search address.
open class LookupAddressLocationSearchStrategy<T: MPOLKitEntity>: LocationSearchStrategy {

    public typealias Location = LookupAddress

    public let source: EntitySource

    public let configuration: LocationSearchConfiguration

    public let helpPresentable: Presentable

    public lazy var onResultModelForMap: (() -> MapResultViewModelable)? = {
        return MapSummarySearchResultViewModel<T>(searchStrategy: self)
    }

    public lazy var onResultModelForResult: ((LookupResult, Searchable) -> SearchResultModelable)? = { (result, searchable) in
        let preferredViewModel = MapSummarySearchResultViewModel<T>(searchStrategy: self, title: searchable.text ?? "")
        return preferredViewModel
    }

    public lazy var onResultModelForParameters: ((Parameterisable, Searchable) -> SearchResultModelable)? = { (parameterisable, searchable) in
        let preferredViewModel = MapSummarySearchResultViewModel<T>(searchStrategy: self, title: searchable.text ?? "")
        return preferredViewModel
    }

    public lazy var onResultModelForSearchType: ((LocationMapSearchType) -> MapResultViewModelable)? = { searchType in
        let preferredViewModel = MapSummarySearchResultViewModel<T>(searchStrategy: self, title: "Dropped Pin")
        return preferredViewModel
    }

    public init(source: EntitySource, helpPresentable: Presentable, configuration: LocationSearchConfiguration = LocationSearchConfiguration.default) {
        self.source = source
        self.helpPresentable = helpPresentable
        self.configuration = configuration
    }
    
    open func locationTypeaheadPromise(text: String) -> Promise<[LookupAddress]>? {
        return APIManager.shared.typeAheadSearchAddress(in: source, with: LookupAddressSearchRequest(searchText: text))
    }

    open func resultModelForMap() -> MapResultViewModelable? {
        return onResultModelForMap?()
    }

    open func resultModelForSearchOnLocation(withResult result: LookupResult, andSearchable searchable: Searchable) -> SearchResultModelable? {
        return onResultModelForResult?(result, searchable)
    }

    open func resultModelForSearchOnLocation(withParameters parameters: Parameterisable, andSearchable searchable: Searchable) -> SearchResultModelable? {
        return onResultModelForParameters?(parameters, searchable)
    }

    open func resultModelForSearchOnLocation(withSearchType searchType: LocationMapSearchType) -> MapResultViewModelable? {
        return onResultModelForSearchType?(searchType)
    }

}
