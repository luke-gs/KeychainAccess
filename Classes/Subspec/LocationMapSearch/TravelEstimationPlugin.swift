//
//  TravelEstimationPlugin.swift
//  Pods
//
//  Created by RUI WANG on 15/9/17.
//
//

import MapKit
import PromiseKit

public protocol TravelEstimationPlugable: class {
    
    /// Calculate the lateral distance between two locations
    ///
    /// - Parameters:
    ///   - location: current user location
    ///   - destination: destination location
    /// - Returns: Returns the lateral distance between two locations.
    @discardableResult
    func calculateDistance(from location: CLLocation, to destination: CLLocation) -> Promise<String>

    /// Calculate the estimated time arrival between two locations
    ///
    /// - Parameters:
    ///   - location: current user location
    ///   - destination: destination location
    ///   - transportType: transport type
    ///   - completion: Returns the lateral ETA between two locations
    @discardableResult
    func calculateETA(from location: CLLocation, to destination: CLLocation, transportType: MKDirectionsTransportType) -> Promise<String?>
}

extension MKDirections {

    // Wraps the call to calculate the ETA between two points to return a promise
    public func calculateETA() -> Promise<MKETAResponse> {
        return Promise<MKETAResponse> { fufill, reject in
            calculateETA(completionHandler: { (response, error) in
                if let error = error {
                    reject(error)
                } else if let response = response {
                    fufill(response)
                }
            })
        }
    }
}

/// Default ETA Plugin implementation
open class TravelEstimationPlugin: TravelEstimationPlugable {

    open func calculateDistance(from location: CLLocation, to destination: CLLocation) -> Promise<String> {
        let distanceInMeters = location.distance(from: destination)
        let formattedDistance = String(format: "%.f m", distanceInMeters)
        return Promise(value: formattedDistance)
    }

    open func calculateETA(from location: CLLocation, to destination: CLLocation, transportType: MKDirectionsTransportType) -> Promise<String?> {
        let sourcePlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

        let request = MKDirectionsRequest()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = transportType
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)

        return directions.calculateETA().then {
            return Promise(value: String(format: "%.f mins", $0.expectedTravelTime / 60))
        }
    }
}
