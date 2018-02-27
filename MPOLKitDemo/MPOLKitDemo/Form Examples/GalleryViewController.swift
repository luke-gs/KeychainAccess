//
//  GalleryViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

class GalleryViewController: FormBuilderViewController {

    override func construct(builder: FormBuilder) {
        builder.title = "Gallery"

        localGallery(builder: builder)
        paginatedGallery(builder: builder)
    }

    func localGallery(builder: FormBuilder) {
        let localStore = DataStoreCoordinator(dataStore: LocalDataStore(items: [
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", isSensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", isSensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", isSensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", isSensitive: false)
        ]))

        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: localStore)

        let mediaItem = MediaFormItem()
            .dataSource(gallery)

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }

        builder += HeaderFormItem(text: "VIEW ONLY PHOTOS").actionButton(title: "VIEW", handler: { button in
            if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                self.present(viewController, animated: true, completion: nil)
            }
        })

        builder += mediaItem
    }

    func paginatedGallery(builder: FormBuilder) {
        let localStore = DataStoreCoordinator(dataStore: LocalDataStore(items: [
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", isSensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", isSensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", isSensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", isSensitive: false)
        ], limit: 2))

        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: localStore)

        let mediaItem = MediaFormItem()
            .dataSource(gallery)

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }

        builder += HeaderFormItem(text: "VIEW ONLY AND PAGINATED PHOTOS").actionButton(title: "VIEW", handler: { button in
            if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                self.present(viewController, animated: true, completion: nil)
            }
        })

        builder += mediaItem
    }

}
