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
    public let useBoldTitleText: Bool
    public let useBoldDetailText: Bool
    
    public init(image: UIImage?, title: String?, detail: String? = nil, tintColor: UIColor? = nil, useBoldTitleText: Bool = false, useBoldDetailText: Bool = false) {
        self.image = image
        self.title = title
        self.detail = detail
        self.tintColor = tintColor
        self.useBoldTitleText = useBoldTitleText
        self.useBoldDetailText = useBoldDetailText
    }
    
    public init(with resource: SyncDetailsResource) {
        let inDuress = resource.status == .duress
        self.init(image: resource.type.icon,
                  title: [resource.callsign, resource.officerCountString].joined(),
                  detail: resource.status.title,
                  tintColor: inDuress ? .orangeRed : nil,
                  useBoldTitleText: false,
                  useBoldDetailText: inDuress)
    }
    
}
