//
//  TasksListItemResourceViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct TasksListItemResourceViewModel {
    public let image: UIImage?
    public let resourceTitle: String
    public let statusText: String
    public let tintColor: UIColor?
    public let useBoldStatusText: Bool
    
    init(image: UIImage?, resourceTitle: String, statusText: String, tintColor: UIColor?, useBoldStatusText: Bool) {
        self.image = image
        self.resourceTitle = resourceTitle
        self.statusText = statusText
        self.tintColor = tintColor
        self.useBoldStatusText = useBoldStatusText
    }
    
    init(with resource: SyncDetailsResource) {
        let inDuress = resource.status == .duress
        self.init(image: resource.type.icon,
                  resourceTitle: [resource.callsign, resource.officerCountString].joined(),
                  statusText: resource.status.title,
                  tintColor: inDuress ? .orangeRed : nil,
                  useBoldStatusText: inDuress)
    }
    
}
