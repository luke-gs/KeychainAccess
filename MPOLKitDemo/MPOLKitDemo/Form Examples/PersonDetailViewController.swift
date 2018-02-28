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

//        let videoPath = Bundle.main.path(forResource: "video", ofType: "mp4")!
//        let audioPath = Bundle.main.path(forResource: "audio", ofType: "m4a")!
//
//        let fp = URL(fileURLWithPath: audioPath)
//        let vp = URL(fileURLWithPath: videoPath)
//
//        let url = URL(fileURLWithPath: Bundle.main.resourcePath! + "/Avatar 1.png")

//        let datasource = MediaDataSource(mediaItems: [
//            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), asset: Media(url: url, title: "Test", comments: "Comments", isSensitive: false)),
//            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), asset: Media(url: url, title: "Test", comments: "Comments", isSensitive: false)),
//            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), asset: Media(url: url, title: "Test", comments: "Comments", isSensitive: false)),
//            PhotoMedia(thumbnailImage: #imageLiteral(resourceName: "Avatar 1"), image: #imageLiteral(resourceName: "Avatar 1"), asset: Media(url: url, title: "Test", comments: "Comments", isSensitive: false)),
//            AudioMedia(asset: Media(url: fp, title: "Test", comments: "Comments", isSensitive: false)),
//            AudioMedia(asset: Media(url: fp, title: "Test", comments: "Comments", isSensitive: false)),
//            VideoMedia(asset: Media(url: vp, title: "Test", comments: "Comments", isSensitive: false)),
//            VideoMedia(asset: Media(url: vp, title: "Test", comments: "Comments", isSensitive: false)),
//        ])

        let localStore = DataStoreCoordinator(dataStore: LocalDataStore(items: [
            Media(url: URL(string: "localhost")!, type: .photo, title: "Herli", comments: "This Girl is on FIREEE", isSensitive: true),
            Media(url: URL(string: "localhost")!, type: .photo, title: "Herli", comments: "This Girl is on FIREEE", isSensitive: false),
            Media(url: URL(string: "localhost")!, type: .photo, title: "Herli", comments: "This Girl is on FIREEE", isSensitive: false),
            Media(url: URL(string: "localhost")!, type: .photo, title: "Herli", comments: "This Girl is on FIREEE", isSensitive: false)
        ]))

        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: localStore)

        let mediaItem = MediaFormItem()
            .dataSource(gallery)

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }

        builder += HeaderFormItem(text: "PHOTOS").actionButton(title: "ADD", handler: { button in
            if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                self.present(viewController, animated: true, completion: nil)
            }
        })

        builder += mediaItem

        builder += HeaderFormItem(text: "DETAILS")

        builder += SubtitleFormItem(title: "Name", subtitle: StringSizing(string: "Herli Halim", font: .boldSystemFont(ofSize: 20)), image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += SubtitleFormItem(title: "Spouse", subtitle: "Marianna", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Age", value: "2", image: #imageLiteral(resourceName: "SidebarInfo"))
        builder += ValueFormItem(title: "Sex", value: "Male", image: #imageLiteral(resourceName: "SidebarInfo"))
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

    var media: Media

    var sensitive: Bool = false

    var title: String?

    var comments: String?


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

    let type: DocumentType

    let thumbnailImage: ImageLoadable?

    let sensitiveText: String? = nil

    init(type: DocumentType, title: String?) {
        self.media = Media(url: URL(string: "localhost")!, type: .photo)
        self.type = type
        self.title = title

        var sizing = type.image().sizing()
        sizing.contentMode = .center
        thumbnailImage = sizing
    }

}




