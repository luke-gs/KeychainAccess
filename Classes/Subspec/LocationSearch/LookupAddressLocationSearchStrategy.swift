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
open class LookupAddressLocationSearchStrategy: LocationSearchStrategy {

    public typealias Location = LookupAddress

    public let source: EntitySource

    public let configuration: LocationSearchConfiguration

    public let helpPresentable: Presentable

    public var onResultModelForMap: (() -> MapResultViewModelable)? = {
        return MapSummarySearchResultViewModel()
    }

    public var onResultModelForResult: ((LookupResult) -> SearchResultModelable)? = {
        let preferredViewModel = MapSummarySearchResultViewModel()
        preferredViewModel.fetchResults(withCoordinate: $0.location.coordinate)
        return preferredViewModel
    }

    public var onResultModelForParameters: ((Parameterisable) -> SearchResultModelable)? = {
        let preferredViewModel = MapSummarySearchResultViewModel()
        preferredViewModel.fetchResults(withParameters: $0)
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

    open func resultModelForSearchOnLocation(withResult result: LookupResult) -> SearchResultModelable? {
        return onResultModelForResult?(result)
    }

    open func resultModelForSearchOnLocation(withParameters parameters: Parameterisable) -> SearchResultModelable? {
        return onResultModelForParameters?(parameters)
    }


    
}
