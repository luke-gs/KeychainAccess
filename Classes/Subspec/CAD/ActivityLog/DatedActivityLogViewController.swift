//
//  DatedActivityLogViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 12/1/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class DatedActivityLogViewController: ActivityLogViewController {

    public var showsBottomDivider: Bool = false {
        didSet {
            bottomDivider.isHidden = !showsBottomDivider
        }
    }
    
    private let bottomDivider = UIView()
    private let dateTitleLabel = UILabel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
                
        dateTitleLabel.text = title
        dateTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        dateTitleLabel.textColor = .primaryGray
        dateTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateTitleLabel)

        bottomDivider.backgroundColor = iOSStandardSeparatorColor
        bottomDivider.isHidden = !showsBottomDivider
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomDivider)
        
        guard let collectionView = collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dateTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).withPriority(.almostRequired),
            dateTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),

            collectionView.topAnchor.constraint(equalTo: dateTitleLabel.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            bottomDivider.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            bottomDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bottomDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor).withPriority(.almostRequired),
            bottomDivider.bottomAnchor.constraint(equalTo: view.safeAreaOrFallbackBottomAnchor),
            bottomDivider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    open override func collectionViewClass() -> UICollectionView.Type {
        return IntrinsicHeightCollectionView.self
    }
    
    open override func apply(_ theme: Theme) {
        super.apply(theme)
        dateTitleLabel.textColor = theme.color(forKey: .primaryText)
//        bottomDivider.backgroundColor = theme.color(forKey: .separator)
    }

}
