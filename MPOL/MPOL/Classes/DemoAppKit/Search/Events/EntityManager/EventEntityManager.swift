//
//  EventEntityManager.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//
import PublicSafetyKit

final public class EventEntityManager {
    private weak var event: Event!

    public weak var delegate: EntityBucketDelegate? {
        didSet {
            event.entityBucket.delegate = delegate
        }
    }

    public init(event: Event) {
        self.event = event
    }

}
