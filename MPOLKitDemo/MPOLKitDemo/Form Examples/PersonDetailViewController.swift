//
//  PersonDetailViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 14/9/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class PersonDetailViewController: FormBuilderViewController {


    override func construct(builder: FormBuilder) {

        builder.title = "Person Details"

        let dataSource: MediaDataSource<PhotoMedia> = [
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), title: "Jeff Handerson", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Login"), image: #imageLiteral(resourceName: "Login"), title: "Background of some random screen", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "SidebarInfoFilled"), image: #imageLiteral(resourceName: "SidebarInfoFilled"), title: "The davin ci icon", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), title: "Jeff Handerson in the fresh.", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Login"), image: #imageLiteral(resourceName: "Login"), title: "A group of officers pretending to be working", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "SidebarInfoFilled"), image: #imageLiteral(resourceName: "SidebarInfoFilled"), title: "Icon of death", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), title: "A man", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Login"), image: #imageLiteral(resourceName: "Login"), title: "Another group of officers", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "SidebarInfoFilled"), image: #imageLiteral(resourceName: "SidebarInfoFilled"), title: "A pointless infomration icon", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), title: "A real man", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Login"), image: #imageLiteral(resourceName: "Login"), title: "The blue officers", sensitive: false),
            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "SidebarInfoFilled"), image: #imageLiteral(resourceName: "SidebarInfoFilled"), title: "Jeff Handerson", sensitive: false)
        ]

        let mediaItem = MediaFormItem().dataSource(dataSource)

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }

        builder += HeaderFormItem(text: "PHOTOS").actionButton(title: "ADD", handler: { [weak self] in
            if let viewController = mediaItem.delegate.viewControllerForMediaDataSource(dataSource) {
                self?.present(viewController, animated: true, completion: nil)
            }
        })

        builder += mediaItem

        builder += HeaderFormItem(text: "DETAILS")

        builder += SubtitleFormItem(title: "Name", subtitle: StringSizing(string: "Herli Halim", font: .boldSystemFont(ofSize: 20)), image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Spouse", subtitle: "Marianna", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Age", value: "2", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Sex", value: "Confused", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += DetailFormItem(title: "Property", subtitle: "44 Heartlands Blv", detail: "Current PPOR", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += DetailFormItem(title: "Property", subtitle: "108 Flinders St", detail: "Previous PPOR")

        builder += [
            HeaderFormItem(text: "ALIAS"),
            SubtitleFormItem(title: "AKA", subtitle: "Black Herli").width(.column(2)),
            SubtitleFormItem(title: "Game Name", subtitle: "XSlasherzX").width(.column(2)),
            SubtitleFormItem(title: "Everyday's name", subtitle: "NoobieHalim").width(.column(2))
        ]

        var mangaItems: [FormItem] = [HeaderFormItem(text: "MANGA")]

        for i in 1...100 {
            let item = SubtitleFormItem(title: "Manager \(i)", subtitle: "Subtitle \(i)")
            item.accessory = ItemAccessory.disclosure
            item.width = .column(3)
            mangaItems.append(item)
        }

        builder += mangaItems
    }

}


class DocumentItem: MediaPreviewable {

    enum DocumentType {
        case pdf
        case docs
        case txt
        case unknown

        func image() -> UIImage {
            switch self {
            case .pdf: return AssetManager.shared.image(forKey: .direction)!
            case .docs: return AssetManager.shared.image(forKey: .event)!
            case .txt: return AssetManager.shared.image(forKey: .document)!
            case .unknown: return AssetManager.shared.image(forKey: .attachment)!
            }
        }
    }

    let title: String?

    let type: DocumentType

    let thumbnailImage: ImageLoadable?

    let sensitiveText: String? = nil

    init(type: DocumentType, title: String?) {
        self.type = type
        self.title = title

        var sizing = type.image().sizing()
        sizing.contentMode = .center
        thumbnailImage = sizing
    }

}




