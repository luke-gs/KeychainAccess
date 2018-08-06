//
//  StackMapLayout.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class StackMapLayout: MapFormBuilderViewLayout {

    /// Optional fixed height of map
    private var mapPercentage: CGFloat?
    
    public init(mapPercentage: CGFloat? = 40) {
        self.mapPercentage = mapPercentage
        super.init()
    }

    override public func viewDidLoad() {
        guard let controller = controller,
            let mapView = controller.mapView,
            let collectionView = controller.collectionView
            else { return }

        controller.view.addSubview(mapView)

        controller.mapView?.translatesAutoresizingMaskIntoConstraints = false
        controller.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: controller.view.safeAreaOrFallbackLeadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: controller.view.safeAreaOrFallbackTrailingAnchor),
            mapView.topAnchor.constraint(equalTo: controller.view.safeAreaOrFallbackTopAnchor),

            collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: controller.safeAreaOrLayoutGuideBottomAnchor),
        ])
    }

    override public func viewWillAppear(_ animated: Bool) {
        guard let controller = controller, let mapView = controller.mapView else { return }

        // Set the height of the map if a percentage is set
        // Note: we defer this to here as the controller height is not set in viewDidLoad
        if let mapPercentage = mapPercentage {
            NSLayoutConstraint.activate([
                mapView.heightAnchor.constraint(equalToConstant: controller.view.frame.height * (mapPercentage / 100))
            ])
        }
    }

    public override func collectionViewClass() -> UICollectionView.Type {
        /// Use instrinsic height collection view so form gets intrinsic height if no explicit map height
        return IntrinsicHeightCollectionView.self
    }
}
