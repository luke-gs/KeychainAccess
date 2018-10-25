//
//  CollectionViewFormEventCardsCell.swift
//  MPOL
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import DemoAppKit

public class CollectionViewFormEventCardsCell: CollectionViewFormCell, UICollectionViewDelegate, UICollectionViewDataSource {
    public static let intrinsicHeight: CGFloat = 200

    public weak var dataSource: EventCardsViewModelable? {
        didSet {
            collectionView.reloadData()
        }
    }

    public weak var delegate: EventCardsDelegate?

    public let collectionView: UICollectionView

    public let layout: UICollectionViewFlowLayout

    public override init(frame: CGRect) {
        layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 360, height: 200)
        layout.minimumLineSpacing = 24.0
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

        collectionView.register(EventCardCollectionViewCell.self, forCellWithReuseIdentifier: "eventCell")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        guard let eventsList = dataSource.eventsList else { return 0 }
        return eventsList.count
    }
    

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource, let eventsList = dataSource.eventsList else { return UICollectionViewCell() }

        let eventDisplayable = eventsList[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventCardCollectionViewCell

        cell.timeLabel.text = dataSource.eventCreationString(for: eventDisplayable)
        cell.titleLabel.text = eventDisplayable.title
        cell.addressLabel.text = dataSource.eventLocationString(for: eventDisplayable)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectEvent(at: indexPath.item)
    }
}
