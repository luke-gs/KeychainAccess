//
//  ResourceOfficerViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit

open class ResourceOfficerViewModel {

    public var title: String
    public var subtitle: String
    public var initials: String?
    public var badgeText: String?
    public var commsEnabled: (text: Bool, call: Bool)
    public var contactNumber: String

    public init(title: String, subtitle: String, initials: String?, badgeText: String?, commsEnabled: (text: Bool, call: Bool), contactNumber: String) {
        self.title = title
        self.subtitle = subtitle
        self.initials = initials
        self.badgeText = badgeText
        self.commsEnabled = commsEnabled
        self.contactNumber = contactNumber
    }

    convenience public init(officer: CADOfficerType, resource: CADResourceType? = nil) {
        let commsEnabled = officer.contactNumber != nil

        var licenceType: String?
        if let licenceId = officer.licenceTypeId {
            licenceType = Manifest.shared.entry(withID: licenceId)?.rawValue
        }

        self.init(title: officer.displayName,
                  subtitle: [officer.rank, officer.payrollIdDisplayString, licenceType]
                    .joined(separator: ThemeConstants.dividerSeparator),
                  initials: officer.initials,
                  badgeText: resource?.driver == officer.id ? "D": nil,
                  commsEnabled: (text: false, call: commsEnabled), // TODO: Set text enabled later on
                  contactNumber: officer.contactNumber ?? ""
        )
    }

    open func thumbnail() -> ImageLoadable? {
        guard let initials = initials, let image = UIImage.thumbnail(withInitials: initials).withCircleBackground(tintColor: nil,
                                                                                   circleColor: .disabledGray,
                                                                                   style: .fixed(size: CGSize(width: 48, height: 48),
                                                                                                 padding: CGSize(width: 14, height: 14))
        ) else { return nil }
        return ImageSizing(image: image, size: image.size, contentMode: .center)
    }
}
