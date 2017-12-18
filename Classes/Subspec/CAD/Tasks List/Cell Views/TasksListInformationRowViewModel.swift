//
//  TasksListInformationRowViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 23/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public struct TasksListInformationRowViewModel {
    public let image: UIImage?
    public let title: String?
    public let detail: String?
    public let tintColor: UIColor?
    public let useBoldDetailText: Bool
    
    public init(image: UIImage?, title: String, detail: String, tintColor: UIColor?, useBoldDetailText: Bool) {
        self.image = image
        self.title = title
        self.detail = detail
        self.tintColor = tintColor
        self.useBoldDetailText = useBoldDetailText
    }
    
    public init(with resource: SyncDetailsResource) {
        let inDuress = resource.status == .duress
        self.init(image: resource.type.icon,
                  title: [resource.callsign, resource.officerCountString].joined(),
                  detail: resource.status.title,
                  tintColor: inDuress ? .orangeRed : nil,
                  useBoldDetailText: inDuress)
    }
    
}
