//
//  Matches.swift
//  ClientKit
//
//  Created by Pavel Boryseiko on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

// VEHICLE

struct MPOLToFNCVehicleMatch: FetchMatch {
    var initialSource: EntitySource = MPOLSource.mpol
    var resultSource: EntitySource = MPOLSource.fnc

    func match(_ entity: MPOLKitEntity) -> Fetchable {
        let entity = entity as! Vehicle

        let request = VehicleFetchRequest(source: resultSource, request: EntityFetchRequest<Vehicle>(id: entity.engineNumber!))
        return EntityDetailFetch<Vehicle>(request: request)
    }
}

struct FNCToMPOLVehicleMatch: FetchMatch {
    var initialSource: EntitySource = MPOLSource.fnc
    var resultSource: EntitySource = MPOLSource.mpol

    func match(_ entity: MPOLKitEntity) -> Fetchable  {
        let entity = entity as! Vehicle

        let request = VehicleFetchRequest(source: resultSource, request: EntityFetchRequest<Vehicle>(id: entity.id))
        return EntityDetailFetch<Vehicle>(request: request)
    }

}


// PERSON

struct MPOLToFNCPersonMatch: FetchMatch {
    var initialSource: EntitySource = MPOLSource.mpol
    var resultSource: EntitySource = MPOLSource.fnc

    func match(_ entity: MPOLKitEntity) -> Fetchable {
        let entity = entity as! Person

        let request = PersonFetchRequest(source: resultSource, request: EntityFetchRequest<Person>(id: entity.givenName!))
        return EntityDetailFetch<Person>(request: request)
    }
}

struct FNCToMPOLPersonMatch: FetchMatch {
    var initialSource: EntitySource = MPOLSource.fnc
    var resultSource: EntitySource = MPOLSource.mpol

    func match(_ entity: MPOLKitEntity) -> Fetchable  {
        let entity = entity as! Person

        let request = PersonFetchRequest(source: resultSource, request: EntityFetchRequest<Person>(id: entity.id))
        return EntityDetailFetch<Person>(request: request)
    }

}
