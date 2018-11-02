//
//  EventDraftListViewModel.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit

open class EventDraftListViewModel: DraftListViewModelable {

    public let manager: DraftableManager

    public var badgeCountString: String? {
        let count = manager.draftItems.count
        if count > 0 {
            return "\(count)"
        } else {
            return nil
        }
    }

    public init(manager: DraftableManager) {
        self.manager = manager
    }

    public func title(for item: Draftable, at index: Int) -> String? {
        return item.title
    }

    open func image(for item: Draftable, draftStatus: DraftableStatus) -> UIImage {
        let isDark = ThemeManager.shared.currentInterfaceStyle == .dark

        var image: UIImage?

        switch draftStatus {
        case .draft:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .black : .white, circleColor: isDark ? .white : .black, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        case .queued:
            image = AssetManager.shared.image(forKey: AssetManager.ImageKey.tabBarEventsSelected)?
                .withCircleBackground(tintColor: isDark ? .white : .black, circleColor: isDark ? .darkGray : .disabledGray, style: .auto(padding: CGSize(width: 24, height: 24), shrinkImage: false))
        }

        if let image = image {
            return image
        }

        fatalError("Image for event could not be generated")
    }

    open func subtitle(for item: Draftable, at index: Int) -> String? {
        let item = manager.draftItems[index]
        let detail1 = item.detail1
        let detail2 = item.detail2
        var values = [detail1, detail2].compactMap { $0 }
        if values.count > 1 {
            values.insert("\n", at: 1)
        }
        return values.joined()
    }

    public var title: String? {
        return "Events"
    }

    public var noContentTitle: String? {
        return "No Events"
    }

    public var noContentSubtitle: String? {
        return "You have no Current or Queued Events"
    }

    public var noContentButtonText: String? {
        return "Create new Event"
    }

    public var noContentImage: UIImage? {
        return AssetManager.shared.image(forKey: AssetManager.ImageKey.iconFolder)
    }

    public var rightNavBarButtonItemText: String? {
        return "New Event"
    }

    public var tabBarImageSet: (image: UIImage?, selectedImage: UIImage?)? {
        return (image: AssetManager.shared.image(forKey: .tabBarEvents), selectedImage: AssetManager.shared.image(forKey: .tabBarEventsSelected))
    }

}
