//
//  CollectionViewFormAlertsCell.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import PublicSafetyKit
import DemoAppKit
import Cache

public class CollectionViewFormAlertsCell: CollectionViewFormCell, UICollectionViewDelegate, UICollectionViewDataSource {
    public static let intrinsicHeight: CGFloat = 96

    public var cellHolder: [Entity: EntityCollectionViewCell] = [:]

    public weak var dataSource: SearchAlertsViewModelable? {
        didSet {
            // Only reload the entire collection view if the count has changed, otherwise just refresh visible items
            if dataSource?.alertEntities.count != collectionView.numberOfItems(inSection: 0) {
                collectionView.reloadData()
            } else {
                // We set animations to disabled to avoid the flickering (the cells also jump for a fraction of a section before the content centering kicks in)
                UIView.setAnimationsEnabled(false)
                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
                UIView.setAnimationsEnabled(true)
            }
        }
    }

    public weak var delegate: SearchAlertsDelegate?

    public let collectionView: UICollectionView

    public let layout: UICollectionViewFlowLayout

    public let loadingManager: LoadingStateManager = LoadingStateManager()

    private var summaryDisplayFormatter = EntitySummaryDisplayFormatter()

    public override init(frame: CGRect) {
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 96, height: 96)
        layout.minimumLineSpacing = 10.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24.0, bottom: 0, right: 0.0)
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(frame: frame)

        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false

        contentView.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ])

        collectionView.register(EntityCollectionViewCell.self, forCellWithReuseIdentifier: "entityCell")

        loadingManager.baseView = contentView
        loadingManager.contentView = collectionView

        let noContentView = loadingManager.noContentView
        noContentView.titleLabel.text = NSLocalizedString("No Alerts", comment: "")
    }

    public required init?(coder aDecoder: NSCoder) {
        MPLCodingNotSupported()
    }


    // MARK: - UICollectionViewDelegate/DataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.alertEntities.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else { return UICollectionViewCell() }

        guard let entitySummary = dataSource.summaryDisplayFormatter.summaryDisplayForEntity(dataSource.alertEntities[indexPath.item]) else {
            return EntityCollectionViewCell()
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "entityCell", for: indexPath) as! EntityCollectionViewCell

        cell.style = .thumbnail

        cell.contentMode = .center
        cell.contentView.layoutMargins = .zero

        cell.thumbnailView.borderColor = entitySummary.borderColor
        cell.borderColor = entitySummary.borderColor

        cell.thumbnailView.backgroundView.backgroundColor = ThemeManager.shared.theme(for: .current).color(forKey: .entityThumbnailBackground)
        cell.thumbnailView.tintColor = entitySummary.iconColor ?? ThemeManager.shared.theme(for: .current).color(forKey: .entityImageTint)

        cell.sourceLabel.text = dataSource.alertEntities[indexPath.item].source?.localizedBarTitle
        cell.sourceLabel.backgroundColor = UIColor.black

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dataSource = dataSource, let entitySummary = dataSource.summaryDisplayFormatter.summaryDisplayForEntity(dataSource.alertEntities[indexPath.item]) else {
            return
        }

        let entity = dataSource.alertEntities[indexPath.item]

        let cell = cell as! EntityCollectionViewCell
        let image = entitySummary.thumbnail(ofSize: .medium)
        let sizing = image?.sizing()

        cell.thumbnailView.imageView.contentMode = sizing?.contentMode ?? .center
        cell.thumbnailView.imageView.image = sizing?.image

        cellHolder[entity] = cell

        image?.loadImage(completion: { [cellHolder] (imageSizable) in
            if let cell = cellHolder[entity] {
                cell.thumbnailView.imageView.image = imageSizable.sizing().image
                cell.thumbnailView.imageView.contentMode = sizing?.contentMode ?? .center
            }
        })
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let index = cellHolder.index(where: { $0.value == cell }) {
            cellHolder.remove(at: index)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectEntity(at: indexPath.item)
    }
}
