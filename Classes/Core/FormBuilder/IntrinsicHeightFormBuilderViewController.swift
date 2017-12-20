//
//  IntrinsicHeightFormBuilderViewController.swift
//  MPOLKit
//
//  Created by Kyle May on 20/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// A `FormBuilderViewController` subclass that uses an `IntrinsicHeightCollectionView` and uses
/// auto layout constraints for the collection view, so that intrinsic content height is used.
open class IntrinsicHeightFormBuilderViewController: FormBuilderViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView else { return }
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    open override func collectionViewClass() -> UICollectionView.Type {
        return IntrinsicHeightCollectionView.self
    }
}
