//
//  PersonFetchRequest.swift
//  ClientKit
//
//  Created by RUI WANG on 21/8/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import MPOLKit

public class PersonFetchRequest: EntityDetailFetchRequest<Person> {

    public init(source: MPOLSource, request: EntityFetchRequest<Person>) {
        super.init(source: source, request: request)
    }

    public override func fetchPromise() -> Promise<Person> {
        return APIManager.shared.fetchEntityDetails(in: source as! MPOLSource, with: request)
    }

}
