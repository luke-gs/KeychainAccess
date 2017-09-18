//
//  LocationMapSummarySearchResultViewModel.swift
//  ClientKit
//
//  Created by RUI WANG on 7/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import ClientKit

public class LocationMapSummarySearchResultViewModel: MapSummarySearchResultViewModel<Address> {
    
    public override func fetchResults(with searchType: LocationMapSearchType) {
        self.searchType = searchType
        var parameters: EntitySearchRequest<Address>
        
        switch searchType {
        case .radiusSearch(let coordinate, let radius):
            parameters = LocationMapRadiusSearchParameters(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: radius)
        }
        
        let request = LocationMapSearchRequest(source: .gnaf, request: parameters)
        aggregatedSearch = AggregatedSearch(requests: [request])
    }
    
}
