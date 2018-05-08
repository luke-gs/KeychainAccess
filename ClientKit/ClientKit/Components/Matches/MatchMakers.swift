//
//  MatchMakers.swift
//  ClientKit
//
//  Copyright © 2017 Gridstone. All rights reserved.
//

import MPOLKit

public class VehicleMatchMaker: MatchMaker {
    override public var matches: [DataMatchable]? {
        return nil
    }
}

public class PersonMatchMaker: MatchMaker {
    override public var matches: [DataMatchable]? {
        return [
            PersonMatchStrategy(initialSource: MPOLSource.pscore, resultSource: MPOLSource.nat),
            PersonMatchStrategy(initialSource: MPOLSource.pscore, resultSource: MPOLSource.rda),
            PersonMatchStrategy(initialSource: MPOLSource.nat, resultSource: MPOLSource.pscore),
            PersonMatchStrategy(initialSource: MPOLSource.nat, resultSource: MPOLSource.rda),
            PersonMatchStrategy(initialSource: MPOLSource.rda, resultSource: MPOLSource.pscore),
            PersonMatchStrategy(initialSource: MPOLSource.rda, resultSource: MPOLSource.nat)
        ]
    }
}

