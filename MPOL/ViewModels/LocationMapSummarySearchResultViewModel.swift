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

    open override func entity(for coordinate: CLLocationCoordinate2D) -> MPOLKitEntity? {
        guard let result = results.first else { return nil }
        for rawEntity in result.entities {
            let entity = AddressSummaryDisplayable(rawEntity)
            if entity.coordinate == coordinate {
                return rawEntity
            }
        }
        return nil
    }

    open override func entityDisplayable(for coordinate: CLLocationCoordinate2D) -> EntityMapSummaryDisplayable? {
        guard let entity = entity(for: coordinate) else { return nil }
        return AddressSummaryDisplayable(entity)
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

    open override func annotations() -> [MKAnnotation]? {
        guard  let locationResult = results.first, !locationResult.entities.isEmpty else {
            return nil
        }
        return locationResult.entities.flatMap({ mapAnnotation(for: $0) })
    }


    open override func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
        var pinView: MKPinAnnotationView
        let identifier = "locationPinAnnotationView"

        if annotation is MKPointAnnotation {
            if let dequeueView =  mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeueView.annotation = annotation
                pinView = dequeueView
            } else {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView.animatesDrop = false
                pinView.canShowCallout = true

                if let entity = entityDisplayable(for: annotation.coordinate), let image = entity.mapAnnotationThumbnail() {
                    pinView.leftCalloutAccessoryView = UIImageView(image: image)
                }
            }

            return pinView
        }

        return nil
    }

    open override func coordinate(for entity: MPOLKitEntity) -> CLLocationCoordinate2D {
        return AddressSummaryDisplayable(entity).coordinate!
    }

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
