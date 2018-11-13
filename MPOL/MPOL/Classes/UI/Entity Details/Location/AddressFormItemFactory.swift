//
//  AddressFormItemFactory.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import PublicSafetyKit

public struct AddressFormItemFactory {

    // Local helper function
    private static func addressText(for address: Address) -> String {

        if let text = address.fullAddress {
            return text
        }

        if let text = AddressFormatter().formattedString(from: address) {
            return text
        }

        return "-"
    }

    // Local helper function
    private static func coordinateText(for address: Address) -> String {
        guard let latitude = address.latitude, let longitude = address.longitude else {
            return "-"
        }

        return "\(latitude), \(longitude)"
    }

    /// Address form item with travel time and distance, if supplied, as well as navigation options when tapped. Can supply custom actions..
    public static func addressNavigationFormItem(address: Address, title: String? = nil, detail: String? = nil, travelTimeETA: String? = nil, travelTimeDistance: String? = nil, context: UIViewController, addressActions: [ActionSheetButton]? = nil) -> FormItem {

        // Only create travel Accessory if we have the data to fill it
        var travelAccessory: CustomItemAccessory?

        if let travelTime = travelTimeETA, let travelDistance = travelTimeDistance {
            let travelTimeAccessoryView = TravelTimeAccessoryView(image: AssetManager.shared.image(forKey: .entityCarSmall), distance: travelDistance, time: travelTime, frame: CGRect(x: 0, y: 0, width: 120, height: 30))

            travelAccessory = CustomItemAccessory(onCreate: { () -> UIView in
                return travelTimeAccessoryView
            }, size: CGSize(width: 100, height: 30))
        }

        if let detail = detail {
            return DetailFormItem()
                .styleIdentifier(DemoAppKitStyler.detailLinkStyle)
                .title(StringSizing(string: title ?? "Address", font: UIFont.preferredFont(forTextStyle: .subheadline)))
                .subtitle(StringSizing(string: addressText(for: address), font: UIFont.preferredFont(forTextStyle: .subheadline)))
                .detail(StringSizing(string: detail, font: UIFont.preferredFont(forTextStyle: .footnote)))
                .width(.column(1))
                .accessory(travelAccessory)
                .onSelection { cell in
                    if let latitude = address.latitude, let longitude = address.longitude {
                        let handler = AddressOptionHandler(coordinate: CLLocation(latitude: latitude, longitude: longitude).coordinate, address: address.fullAddress)
                        context.presentActionSheetPopover(handler.actionSheetViewController(with: addressActions), sourceView: cell, sourceRect: cell.bounds, animated: true)
                    }
            }
        } else {
            return ValueFormItem()
                .styleIdentifier(DemoAppKitStyler.valueLinkStyle)
                .title(StringSizing(string: title ?? "Address", font: UIFont.preferredFont(forTextStyle: .subheadline)))
                .value(StringSizing(string: addressText(for: address), font: UIFont.preferredFont(forTextStyle: .subheadline)))
                .width(.column(1))
                .accessory(travelAccessory)
                .onSelection { cell in
                    if let latitude = address.latitude, let longitude = address.longitude {
                        let handler = AddressOptionHandler(coordinate: CLLocation(latitude: latitude, longitude: longitude).coordinate, address: address.fullAddress)
                        context.presentActionSheetPopover(handler.actionSheetViewController(with: addressActions), sourceView: cell, sourceRect: cell.bounds, animated: true)
                    }
            }
        }
    }

    /// Address form item with a coordinate pairing. Is full width by default.
    public static func coordinateFormItem(address: Address) -> FormItem {
        return ValueFormItem()
            .title(StringSizing(string: "Latitude, Longitude", font: UIFont.preferredFont(forTextStyle: .subheadline)))
            .value(StringSizing(string: coordinateText(for: address), font: UIFont.preferredFont(forTextStyle: .subheadline)))
            .width(.column(1))
    }

    /// Default set of form items for an address. Includes an addressNavigationFormItem (with default options) and a coordinateFormItem.
    public static func defaultAddressFormItems(address: Address, travelTimeETA: String?, travelTimeDistance: String?, context: UIViewController) -> [FormItem] {
        return [addressNavigationFormItem(address: address, travelTimeETA: travelTimeETA, travelTimeDistance: travelTimeDistance, context: context), coordinateFormItem(address: address)]
    }
}
