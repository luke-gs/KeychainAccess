//
//  TravelEstimationPlugin.swift
//  Pods
//
//  Created by RUI WANG on 15/9/17.
//
//

import MapKit

public protocol TravelEstimationPlugable: class {
    
    /// Calculate the lateral distance between two locations
    ///
    /// - Parameters:
    ///   - location: current user location
    ///   - destination: destination location
    /// - Returns: Returns the lateral distance between two locations.
    func calculateDistance(from location: CLLocation, to destination: CLLocation, completionHandler: @escaping ((_ text: String?) -> Void))
    
    
    /// Calculate the estimated time arrival between two locations
    ///
    /// - Parameters:
    ///   - location: current user location
    ///   - destination: destination location
    ///   - transportType: transport type
    ///   - completion: Returns the lateral ETA between two locations
    func calculateETA(from location: CLLocation, to destination: CLLocation, transportType: MKDirectionsTransportType, completionHandler: @escaping ((_ text: String?) -> Void))
}


/// Default ETA Plugin implementation
open class TravelEstimationPlugin: TravelEstimationPlugable {
    
    open func calculateDistance(from location: CLLocation, to destination: CLLocation, completionHandler: @escaping ((_ text: String?) -> Void)) {
        let distanceInMeters = location.distance(from: destination)
        let formattedDistance = String(format: "%.f m", distanceInMeters)
        completionHandler(formattedDistance)
    }
    
    open func calculateETA(from location: CLLocation, to destination: CLLocation, transportType: MKDirectionsTransportType, completionHandler: @escaping ((_ text: String?) -> Void)) {
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
        
        directions.calculateETA { response, error in
            if error == nil {
                if let estimate = response {
                    let formattedEstimateTime = String(format: "%.f mins", estimate.expectedTravelTime / 60)
                    completionHandler(formattedEstimateTime)
                }
            } else {
                completionHandler("Not Available")
            }
        }
    }

}
