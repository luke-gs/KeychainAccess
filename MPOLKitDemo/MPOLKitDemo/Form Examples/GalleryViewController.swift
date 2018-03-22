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
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", sensitive: false)
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
            Media(url: URL(string: Bundle.main.path(forResource: "sample1", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Superman practice", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample2", ofType: "jpg")!)!, type: .photo, title: "Bryan Hathaway", comments: "Pavel wannabe", sensitive: true),
            Media(url: URL(string: Bundle.main.path(forResource: "sample3", ofType: "jpg")!)!, type: .photo, title: "Pavel Boryseiko", comments: "Without makeup", sensitive: false),
            Media(url: URL(string: Bundle.main.path(forResource: "sample4", ofType: "jpg")!)!, type: .photo, title: "Herli Halim", comments: "This Girl is on FIREEE", sensitive: false)
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

    // MARK: - Example for VicRoad
    
    func meganGallery(builder: FormBuilder) {
        builder += HeaderFormItem(text: "MEGAN GALLERY")
        builder += SubtitleFormItem(title: "Sample Gallery", subtitle: "Tap to open", image: nil, style: .default).onSelection({ [weak self] _ in
            guard let `self` = self else { return }
            
            self.present(self.galleryViewController, animated: true, completion: nil)
        }).width(.column(1))
    }
    
    lazy var meganGalleryViewModel: MediaGalleryCoordinatorViewModel<MeganMediaStore> = {
        let meganStore = DataStoreCoordinator(dataStore: MeganMediaStore())
        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: meganStore)
        return gallery
    }()
    
    lazy var galleryViewController: UIViewController = {
        let gallery = MediaGalleryViewController(viewModel: meganGalleryViewModel, initialPreview: nil, pickerSources: [], galleryCellType: MeganGalleryCell.self)
        gallery.allowEditing = false
        gallery.additionalBarButtonItems = [UIBarButtonItem(title: "Magic", style: .plain, target: self, action: #selector(GalleryViewController.magicTapped(_:)))]
        
        return UINavigationController(rootViewController: gallery)
    }()
    
    
    // MARK: - Magic Filter
    
    enum FilterOption: String {
        case all = "Show All"
        case sensitiveOnly = "Show sensitive only"
        case nonSensitiveOnly = "Show non-sensitive only"
        case peopleOnly = "Show people only"
    }

    
    var selectedMagicOption: FilterOption = .all
    
    var avaiableMagicOptions: [FilterOption] = [.all, .sensitiveOnly, .nonSensitiveOnly, .peopleOnly]
    
    @objc func magicTapped(_ barItem: UIBarButtonItem) {
        let magic = PickerTableViewController(style: .plain, items: avaiableMagicOptions.map({ $0.rawValue }))
        
        magic.selectionUpdateHandler = { [weak self] controller, selectedIndexes in
            guard let `self` = self,
                let selectedOption = self.avaiableMagicOptions[selectedIndexes].first,
                self.selectedMagicOption != selectedOption else {
                    return
            }
            
            switch selectedOption {
            case .all:
                self.meganGalleryViewModel.filterDescriptors = nil
            case .sensitiveOnly:
                self.meganGalleryViewModel.filterDescriptors = [FilterValueDescriptor(key: { $0.sensitive }, values: [true])]
            case .nonSensitiveOnly:
                self.meganGalleryViewModel.filterDescriptors = [FilterValueDescriptor(key: { $0.sensitive }, values: [false])]
            case .peopleOnly:
                self.meganGalleryViewModel.filterDescriptors = [FilterValueDescriptor(key: { $0.title }, values: ["Person"])]
            }
            
            self.selectedMagicOption = selectedOption
        }
        
        magic.selectedIndexes = avaiableMagicOptions.indexes(where: { $0 == self.selectedMagicOption })
        
        let navigationController = UINavigationController(rootViewController: magic)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.barButtonItem = barItem
        
        galleryViewController.present(navigationController, animated: true, completion: nil)
    }
    
}


/// Custom Galelry Cell

class MeganGalleryCell: MediaGalleryCell {
    
    let label = UILabel()
    
    override var media: MediaPreviewable? {
        didSet {
            label.text = media?.title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .gray
        label.textColor = .white
        label.textAlignment = .center
        
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// Custom Media
class MeganMedia: Media {
    
    var secretMessage: String?
    var whatever: Bool?
    
}

/// Custom Results
class MeganStoreResult: PaginatedDataStoreResult {

    typealias Item = MeganMedia

    var items: [MeganMedia]

    var hasMoreItems: Bool { return nextPageID != nil }

    var nextPageID: Int?

    init(items: [MeganMedia], nextPageID: Int?) {
        self.items = items
        self.nextPageID = nextPageID
    }

}

/// Custom Store
class MeganMediaStore: WritableDataStore {

    typealias Result = MeganStoreResult

    let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

    func retrieveItems(withLastKnownResults results: MeganStoreResult?, cancelToken: PromiseCancellationToken?) -> Promise<MeganStoreResult> {
        let pageID = results?.nextPageID ?? 0

        return connectToBackendToDownloadMedia(page: pageID).then { (images, pageID) -> Promise<MeganStoreResult> in

            return Promise { fullfill, reject in
                DispatchQueue.global().async {
                    let media = images.map { image -> MeganMedia in
                        let imageRef = UIImageJPEGRepresentation(image.0, 0.5)
                        let imageFilePath = self.cacheDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
                        try! imageRef!.write(to: imageFilePath)
                        return (MeganMedia(url: imageFilePath, type: .photo, title: image.1, sensitive: image.2))
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

    // ImageKey, Title, Sensitive
    private let fakeImageKeys: [(AssetManager.ImageKey, String, Bool)] = [
        (.entityCarLarge, "Car", false),
        (.entityBoat, "Boat", true),
        (.entityTruckLarge, "Truck", true),
        (.entityPerson, "Person", false),
        (.entityBuilding, "Building", false),
        (.entityTrailerLarge, "Trailer", false),
        (.entityMotorbikeLarge, "Motorbike", false)
    ]

    private func connectToBackendToDownloadMedia(page: Int) -> Promise<([(UIImage, String, Bool)], Int?)> {
        return Promise { fullfill, reject in
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 4.0) {
                // This backend only sends 2 results back at a time.
                let beginIndex: Int = page * 2
                var endIndex: Int = beginIndex + 2
                endIndex = min(endIndex, self.fakeImageKeys.count)

                let pageId: Int? = (endIndex == self.fakeImageKeys.count) ? nil : ((page) + 1)

                let images = self.fakeImageKeys[beginIndex..<endIndex].flatMap {
                    return (AssetManager.shared.image(forKey: $0.0)!, $0.1, $0.2)
                }

                fullfill((images, pageId))
            }
        }
    }

}
