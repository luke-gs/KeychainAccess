//
//  MatchMakers.swift
//  ClientKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

public class VehicleMatchMaker: MatchMaker {
    override public var matches: [DataMatchable]? {
        return [
            MPOLToFNCVehicleMatch(),
            FNCToMPOLVehicleMatch()
        ]
    }
}

public class PersonMatchMaker: MatchMaker {
    override public var matches: [DataMatchable]? {
        return [
            MPOLToFNCPersonMatch(),
            FNCToMPOLPersonMatch()
        ]
    }
}

