//
//  Matches.swift
//  ClientKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

// VEHICLE

/* Commented this out for now, not matching data, or until some data changes have been completed.
 
struct MPOLToFNCVehicleMatch: DataMatchable {
    var initialSource: EntitySource = MPOLSource.loc
    var resultSource: EntitySource = MPOLSource.fnc

    func match(_ entity: MPOLKitEntity) -> Fetchable {
        let entity = entity as! Vehicle

        let request = VehicleFetchRequest(source: resultSource, request: EntityFetchRequest<Vehicle>(id: entity.id))
        return EntityDetailFetch<Vehicle>(request: request)
    }
}

struct FNCToMPOLVehicleMatch: DataMatchable {
    var initialSource: EntitySource = MPOLSource.fnc
    var resultSource: EntitySource = MPOLSource.loc

    func match(_ entity: MPOLKitEntity) -> Fetchable {
        let entity = entity as! Vehicle

        let request = VehicleFetchRequest(source: resultSource, request: EntityFetchRequest<Vehicle>(id: entity.id))
        return EntityDetailFetch<Vehicle>(request: request)
    }

}

// PERSON

struct MPOLToFNCPersonMatch: DataMatchable {
    var initialSource: EntitySource = MPOLSource.loc
    var resultSource: EntitySource = MPOLSource.fnc

    func match(_ entity: MPOLKitEntity) -> Fetchable {
        let request = PersonFetchRequest(source: resultSource, request: EntityFetchRequest<Person>(id: "745687"))
        return EntityDetailFetch<Person>(request: request)
    }
}

struct FNCToMPOLPersonMatch: DataMatchable {
    var initialSource: EntitySource = MPOLSource.fnc
    var resultSource: EntitySource = MPOLSource.loc

    func match(_ entity: MPOLKitEntity) -> Fetchable {
        let request = PersonFetchRequest(source: resultSource, request: EntityFetchRequest<Person>(id: "554ca38e-ab00-4c5c-8e58-1c87ef09b958"))
        return EntityDetailFetch<Person>(request: request)
    }
}
*/
