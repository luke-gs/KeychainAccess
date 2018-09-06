//
//  EventSubmissionRequest.swift
//  ClientKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PromiseKit
import PublicSafetyKit

public class EventSubmissionRequest: Requestable {
    public typealias ResultClass = EventSubmissionResponse
    public var parameters: [String: Any] = [:]
    public init() {}
}
