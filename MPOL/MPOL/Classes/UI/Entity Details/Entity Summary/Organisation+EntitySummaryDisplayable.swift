//
//  Organisation+EntitySummaryDisplayable.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

public struct OrganisationSummaryDisplayable: EntityMapSummaryDisplayable, AssociatedEntitySummaryDisplayable {

    private var organisation: Organisation

    public init(_ entity: MPOLKitEntity) {
        organisation = entity as! Organisation
    }

    public var category: String? {
        return organisation.source?.localizedBarTitle
    }

    public var title: StringSizable? {
        return organisation.summary.sizing(withNumberOfLines: 0)
    }

    public var detail1: StringSizable? {
        return organisation.type?.sizing(withNumberOfLines: 0)
    }

    public var detail2: StringSizable? {
        return organisation.addresses?.first?.fullAddress?.sizing(withNumberOfLines: 0)
    }

    public var association: String? {
        return organisation.formattedAssociationReasonsString()
    }

    public var borderColor: UIColor? {
        return organisation.associatedAlertLevel?.color
    }

    public var iconColor: UIColor? {
        return organisation.alertLevel?.color
    }

    public var badge: UInt {
        return organisation.actionCount
    }

    public var priority: Int {
        return organisation.alertLevel?.rawValue ?? -1
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        let imageSize: CGSize
        switch size {
        case .small:
            imageSize = CGSize(width: 24, height: 24)
        case .medium:
            imageSize = CGSize(width: 48, height: 48)
        case .large:
            imageSize = CGSize(width: 72, height: 72)
        }

        if let image = AssetManager.shared.image(forKey: .entityOrganisation, ofSize: imageSize) {
            return ImageSizing(image: image, size: imageSize, contentMode: .center)
        }

        return nil
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let location = organisation.addresses?.first,
            let lat = location.latitude,
            let lon = location.longitude else { return nil }

        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

public struct OrganisationDetailsDisplayable: EntitySummaryDisplayable {

    private var organisation: Organisation
    private var summaryDisplayable: OrganisationSummaryDisplayable

    public init(_ entity: MPOLKitEntity) {
        organisation = entity as! Organisation
        summaryDisplayable = OrganisationSummaryDisplayable(organisation)
    }

    public var category: String? {
        return organisation.source?.localizedBadgeTitle
    }

    public var title: StringSizable? {
        return summaryDisplayable.title
    }

    public var detail1: StringSizable? {
        return summaryDisplayable.detail1
    }

    public var detail2: StringSizable? {
        return summaryDisplayable.detail2
    }

    public var borderColor: UIColor? {
        return summaryDisplayable.borderColor
    }

    public var iconColor: UIColor? {
        return summaryDisplayable.iconColor
    }

    public var badge: UInt {
        return summaryDisplayable.badge
    }

    public var priority: Int {
        return summaryDisplayable.priority
    }

    public func thumbnail(ofSize size: EntityThumbnailView.ThumbnailSize) -> ImageLoadable? {
        return summaryDisplayable.thumbnail(ofSize: size)
    }
}
