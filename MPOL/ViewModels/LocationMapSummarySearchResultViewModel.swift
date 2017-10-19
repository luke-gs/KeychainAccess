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
import CoreLocation
import MapKit

public class LocationMapSummarySearchResultViewModel: MapSummarySearchResultViewModel<Address, AddressSummaryDisplayable> {
    
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
    
    open override func entity(for coordinate: CLLocationCoordinate2D) -> EntityMapSummaryDisplayable? {
        guard let result = results.first else { return nil }
        
        for rawEntity in result.entities {
            let entity = AddressSummaryDisplayable(rawEntity)
            if entity.coordinate == coordinate {
                return entity
            }
        }
        
        return nil
    }

    open override func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation? {

        let displayable = AddressSummaryDisplayable(entity)

        guard let coordinate = displayable.coordinate else {
            return nil
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = displayable.title
        return annotation

    }
    
    open override func coordinate(for entity: MPOLKitEntity) -> CLLocationCoordinate2D {
        return AddressSummaryDisplayable(entity).coordinate!
    }
    
}
