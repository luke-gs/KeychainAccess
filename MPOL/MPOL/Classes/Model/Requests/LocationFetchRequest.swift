//
//  LocationFetchRequest.swift
//  MPOL
//
//  Created by QHMW64 on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import PublicSafetyKit

public class LocationFetchRequest: EntityDetailFetchRequest<Address> {

    public override func fetchPromise() -> Promise<Address> {
        return APIManager.shared.fetchEntityDetails(in: source as! MPOLSource, with: request)
    }

}
