//
//  OrganisationInfoViewModel.swift
//  MPOL
//
//  Created by Megan Efron on 11/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import PublicSafetyKit
import PromiseKit

open class OrganisationInfoViewModel: EntityDetailFormViewModel, EntityLocationMapDisplayable {

    public var travelEstimationPlugin: TravelEstimationPlugable = TravelEstimationPlugin()

    private var travelTimeETAs: [String: String] = [:]
    private var travelTimeDistances: [String: String] = [:]

    private var organisation: Organisation? {
        return entity as? Organisation
    }

    // MARK: - EntityDetailFormViewModel

    open override var title: String? {
        return NSLocalizedString("Information", comment: "")
    }

    open override var noContentTitle: String? {
        return NSLocalizedString("No Organisation Found", comment: "")
    }

    open override var noContentSubtitle: String? {
        return NSLocalizedString("There are no details for this organisation", comment: "")
    }

    open override var sidebarImage: UIImage? {
        return AssetManager.shared.image(forKey: .info)
    }

    open override func didSetEntity() {
        super.didSetEntity()
        LocationManager.shared.requestLocation().done(calculateETAandDistanceFromCurrentLocation).cauterize()
    }

    open override func construct(for viewController: FormBuilderViewController, with builder: FormBuilder) {

        guard let organisation = organisation else {
            return
        }

        builder.title = title

        builder += LargeTextHeaderFormItem(text: NSLocalizedString("Details", comment: ""), separatorColor: .clear)

        builder += addressBlocks(for: organisation, viewController: viewController)

        builder += detailsBlock(for: organisation)

        builder += aliasBlock(for: organisation)
    }

    open func mapSummaryDisplayable() -> EntityMapSummaryDisplayable? {
        guard let organisation = entity as? Organisation else {
            return nil
        }

        return OrganisationSummaryDisplayable(organisation)
    }

    // MARK: private

    private func addressBlocks(for organisation: Organisation, viewController: UIViewController) -> [FormItem] {
        return organisation.addresses?.reduce([FormItem]()) { (result, address) -> [FormItem] in
            return result + individualAddressBlock(for: address, viewController: viewController)
        } ?? []
    }

    private func individualAddressBlock(for address: Address, viewController: UIViewController) -> [FormItem] {
        let title = NSAttributedString(string: NSLocalizedString("Address", comment: ""), attributes: [.font: UIFont.preferredFont(forTextStyle: .footnote)])

        let asset = AssetManager.shared.image(forKey: .entityCarSmall)

        // Only create travel Accessory if we have the data to fill it
        var travelAccessory: CustomItemAccessory?

        if let travelTime = travelTimeETAs[address.id],
            let travelDistance = travelTimeDistances[address.id] {
                let travelTimeAccessoryView = TravelTimeAccessoryView(image: asset, distance: travelDistance, time: travelTime, frame: CGRect(x: 0, y: 0, width: 100, height: 30))

                travelAccessory = CustomItemAccessory(onCreate: { () -> UIView in
                    return travelTimeAccessoryView
                }, size: CGSize(width: 100, height: 30))

        }

        return [
            AddressFormItem()
                .styleIdentifier(PublicSafetyKitStyler.detailLinkStyle)
                .title(title)
                .subtitle(address.fullAddress)
                .addressNavigatable(address, presentationContext: viewController)
                .width(.column(1))
                .accessory(travelAccessory),
            ValueFormItem(title: NSLocalizedString("Latitude, Longitude", comment: ""), value: latLongString(from: address))
                .width(.column(1)).separatorColor(.clear)
        ]
    }

    private func detailsBlock(for organisation: Organisation) -> [FormItem] {
        var items = [FormItem]()
        items.append(ValueFormItem(title: NSLocalizedString("Organisation Type", comment: ""), value: organisation.type).width(.column(3)))

        if let acn = organisation.acn {
            items.append(ValueFormItem(title: NSLocalizedString("ABN/ACN", comment: ""), value: acn).width(.column(3)))
        } else {
            items.append(ValueFormItem(title: NSLocalizedString("ABN/ACN", comment: ""), value: organisation.abn).width(.column(3)))
        }

        if let effectiveDate = organisation.effectiveDate {
            let dateString = DateFormatter.preferredDateStyle.string(from: effectiveDate)
            items.append(ValueFormItem(title: NSLocalizedString("Effective From", comment: ""), value: dateString).width(.column(3)))
        }

        return items
    }

    private func aliasBlock(for organisation: Organisation) -> [FormItem] {
        let title = LargeTextHeaderFormItem(text: NSLocalizedString("Aliases", comment: ""), separatorColor: .clear)
        guard let aliases = organisation.aliases else { return [title] }

        return [title] + aliases.map {

            var formTitle: String?

            if let dateCreated = $0.dateCreated {
                formTitle = NSLocalizedString("Recorded on \(DateFormatter.preferredDateStyle.string(from: dateCreated))", comment: "")
            } else {
                formTitle = NSLocalizedString("", comment: "")
            }
            return ValueFormItem(title: formTitle, value: $0.alias).width(.column(1)) as FormItem
        }
    }

    // MARK: Private

    private func calculateETAandDistanceFromCurrentLocation(_ currentLocation: CLLocation) {
        organisation?.addresses?.forEach { address in
            calculateETAandDistance(currentLocation: currentLocation, address: address).done {
                self.delegate?.reloadData()
            }.cauterize()
        }
    }

    private func calculateETAandDistance(currentLocation: CLLocation, address: Address) -> Promise<Void> {
        guard let location = location(from: address) else { return Promise<Void>() }
        let promises: [Promise<Void>] = [
            travelEstimationPlugin.calculateDistance(from: currentLocation, to: location).done {
                self.travelTimeETAs[address.id] = $0
            },
            travelEstimationPlugin.calculateETA(from: currentLocation, to: location, transportType: .automobile).done {
                self.travelTimeDistances[address.id] = $0
            }
        ]
        return when(fulfilled: promises).asVoid()
    }

    private func location(from address: Address?) -> CLLocation? {
        guard let lat = address?.latitude,
            let long = address?.longitude else { return nil }

        return CLLocation(latitude: lat, longitude: long)
    }

    private func latLongString(from address: Address?) -> String? {
        guard let lat = address?.latitude,
            let long = address?.longitude else { return nil }

        return "\(lat), \(long)"
    }

}
