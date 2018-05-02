//
//  EventSubmissionRequest.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import MPOLKit

public class EventSubmissionRequest: EntityFetchRequestable {
    public typealias ResultClass = EventSubmissionResponse
    public var parameters: [String: Any] = [:]
    public init() {}
}
