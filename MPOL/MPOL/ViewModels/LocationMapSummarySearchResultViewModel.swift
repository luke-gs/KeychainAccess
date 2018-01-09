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

class EntityMapAnnotation: MKPointAnnotation {
    var entity: MPOLKitEntity

    init(entity: MPOLKitEntity) {
        self.entity = entity
    }
}

public class LocationMapSummarySearchResultViewModel: MapSummarySearchResultViewModel<Address> {

    public override func mapAnnotation(for entity: MPOLKitEntity) -> MKAnnotation? {
        let displayable = AddressSummaryDisplayable(entity)

        guard let coordinate = displayable.coordinate else {
            return nil
        }

        let annotation = EntityMapAnnotation(entity: entity)
        annotation.coordinate = coordinate
        annotation.title = displayable.title
        return annotation
    }

    public override func annotationView(for annotation: MKAnnotation, in mapView: MKMapView) -> MKAnnotationView? {
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

                if let entity = entityDisplayable(for: annotation), let image = entity.mapAnnotationThumbnail() {
                    pinView.leftCalloutAccessoryView = UIImageView(image: image)
                }
            }

            return pinView
        }

        return nil
    }

    public override func fetchResults(with searchType: LocationMapSearchType) {
        self.searchType = searchType
        let coordinate = searchType.coordinate
        let parameters = LocationMapRadiusSearchParameters(latitude: coordinate.latitude, longitude: coordinate.longitude, radius: searchType.radius)
        let request = LocationMapSearchRequest(source: .gnaf, request: parameters)
        aggregatedSearch = AggregatedSearch(requests: [request])
    }

}
