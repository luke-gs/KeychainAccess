//
//  MatchMakers.swift
//  ClientKit
//
//  Created by Pavel Boryseiko on 25/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

public class VehicleMatchMaker: MatchMaker {
    override public var matches: [FetchMatch]? {
        return [
            MPOLToFNCVehicleMatch(),
            FNCToMPOLVehicleMatch()
        ]
    }
}

public class PersonMatchMaker: MatchMaker {
    override public var matches: [FetchMatch]? {
        return [
            MPOLToFNCPersonMatch(),
            FNCToMPOLPersonMatch()
        ]
    }
}

