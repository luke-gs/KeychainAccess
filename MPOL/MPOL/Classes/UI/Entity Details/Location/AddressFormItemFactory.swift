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

    // Local helper functions

    private static func addressText(for address: Address) -> String {

        if let text = address.fullAddress {
            return text
        }

        if let text = AddressFormatter().formattedString(from: address) {
            return text
        }

        return "-"
    }

    private static func coordinateText(for address: Address) -> String {
        guard let latitude = address.latitude, let longitude = address.longitude else {
            return "-"
        }

        return "\(latitude), \(longitude)"
    }

    public static func addressNavigationFormItem(address: Address, travelTimeETA: String?, travelTimeDistance: String?, context: UIViewController, addressActions: [ActionSheetButton]? = nil) -> FormItem {


        // Only create travel Accessory if we have the data to fill it
        var travelAccessory: CustomItemAccessory?

        if let travelTime = travelTimeETA, let travelDistance = travelTimeDistance {
            let travelTimeAccessoryView = TravelTimeAccessoryView(image: AssetManager.shared.image(forKey: .entityCarSmall), distance: travelDistance, time: travelTime, frame: CGRect(x: 0, y: 0, width: 120, height: 30))

            travelAccessory = CustomItemAccessory(onCreate: { () -> UIView in
                return travelTimeAccessoryView
            }, size: CGSize(width: 100, height: 30))

        }

        var linkAttributes = [NSAttributedStringKey : Any]()

        if let tintColor = ThemeManager.shared.theme(for: .current).color(forKey: .tint) {
            linkAttributes[NSAttributedStringKey.foregroundColor] = tintColor
        }

        let addressFormItem = ValueFormItem()
            .title(NSAttributedString(string: "Address"))
            .value(NSAttributedString(string: addressText(for: address), attributes: linkAttributes))
            .width(.column(1))
            .accessory(travelAccessory)
            .onSelection { cell in
                if let latitude = address.latitude, let longitude = address.longitude {
                    let handler = AddressOptionHandler(coordinate: CLLocation(latitude: latitude, longitude: longitude).coordinate, address: address.fullAddress)
                    context.presentActionSheetPopover(handler.actionSheetViewController(with: addressActions), sourceView: cell, sourceRect: cell.bounds, animated: true)
                }
        }

        return addressFormItem
    }

    public static func coordinateFormItem(address: Address) -> FormItem {
        let coordinateFormitem = ValueFormItem()
            .title(NSAttributedString(string: "Latitude, Longitude"))
            .value(NSAttributedString(string: coordinateText(for: address)))
            .width(.column(1))

        return coordinateFormitem
    }

    /// Form items
    public static func defaultAddressFormItems(address: Address, travelTimeETA: String?, travelTimeDistance: String?, context: UIViewController) -> [FormItem] {
        return [addressNavigationFormItem(address: address, travelTimeETA: travelTimeETA, travelTimeDistance: travelTimeDistance, context: context), coordinateFormItem(address: address)]
    }
}
