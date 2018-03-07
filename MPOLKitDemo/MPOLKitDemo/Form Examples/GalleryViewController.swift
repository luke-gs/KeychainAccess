//
//  GalleryViewController.swift
//  MPOLKitDemo
//
//  Created by KGWH78 on 26/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit
import PromiseKit

class GalleryViewController: FormBuilderViewController {

    override func construct(builder: FormBuilder) {
        builder.title = "Gallery"

        localGallery(builder: builder)
        paginatedGallery(builder: builder)
        meganGallery(builder: builder)
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

    func meganGallery(builder: FormBuilder) {
        let meganStore = DataStoreCoordinator(dataStore: MeganMediaStore())

        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: meganStore)
        let handler = MediaPreviewHandler(allowEditing: false)

        let mediaItem = MediaFormItem()
            .dataSource(gallery)
            .delegate(handler)

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }

        builder += HeaderFormItem(text: "MEGAN GALLERY").actionButton(title: "VIEW", handler: { button in
            if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                self.present(viewController, animated: true, completion: nil)
            }
        })

        builder += mediaItem
    }

}


class MeganStoreResult: PaginatedDataStoreResult {

    typealias Item = Media

    var items: [Media]

    var hasMoreItems: Bool { return nextPageID != nil }

    var nextPageID: Int?

    init(items: [Media], nextPageID: Int?) {
        self.items = items
        self.nextPageID = nextPageID
    }

}

class MeganMediaStore: WritableDataStore {

    typealias Result = MeganStoreResult

    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

    func retrieveItems(withLastKnownResults results: MeganStoreResult?, cancelToken: PromiseCancellationToken?) -> Promise<MeganStoreResult> {
        let pageID = results?.nextPageID ?? 0

        return connectToBackendToDownloadMedia(page: pageID).then { (images, pageID) -> Promise<MeganStoreResult> in

            return Promise { fullfill, reject in
                DispatchQueue.global().async {
                    let media = images.map { image -> Media in
                        let imageRef = UIImageJPEGRepresentation(image, 0.5)
                        let imageFilePath = self.cacheDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
                        try! imageRef!.write(to: imageFilePath)
                        return (Media(url: imageFilePath, type: .photo))
                    }

                    fullfill(MeganStoreResult(items: media, nextPageID: pageID))
                }

            }
        }
    }

    func addItems(_ items: [MeganStoreResult.Item]) -> Promise<[MeganStoreResult.Item]> {
        return Promise(error: DataStoreError.notSupported)
    }

    func removeItems(_ items: [MeganStoreResult.Item]) -> Promise<[MeganStoreResult.Item]> {
        return Promise(error: DataStoreError.notSupported)
    }

    func replaceItem(_ item: MeganStoreResult.Item, with otherItem: MeganStoreResult.Item) -> Promise<MeganStoreResult.Item> {
        return Promise(error: DataStoreError.notSupported)
    }

    // MARK: - Fake it to win it

    private let fakeImageKeys: [AssetManager.ImageKey] = [
        .entityCarLarge, .entityBoat, .entityTruckLarge, .entityPerson, .entityBuilding, .entityTrailerLarge, .entityMotorbikeLarge
    ]

    private func connectToBackendToDownloadMedia(page: Int) -> Promise<([UIImage], Int?)> {
        return Promise { fullfill, reject in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 4.0) {
                // This backend only sends 2 results back at a time.
                let beginIndex: Int = page * 2
                var endIndex: Int = beginIndex + 2
                endIndex = min(endIndex, self.fakeImageKeys.count)

                let pageId: Int? = (endIndex == self.fakeImageKeys.count) ? nil : ((page) + 1)

                let images = self.fakeImageKeys[beginIndex..<endIndex].flatMap {
                    return AssetManager.shared.image(forKey: $0)
                }

                fullfill((images, pageId))
            }
        }
    }

}
