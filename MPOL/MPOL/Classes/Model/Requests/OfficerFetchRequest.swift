//
//  OfficerFetchRequest.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import PublicSafetyKit

public class OfficerFetchRequest: EntityDetailFetchRequest<Officer> {

    public override func fetchPromise() -> Promise<Officer> {
        return APIManager.shared.fetchEntityDetails(in: source as! MPOLSource, with: request)
    }
}
