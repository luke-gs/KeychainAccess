//
//  StackMapLayout.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public class StackMapLayout: MapFormBuilderViewLayout {

    let percentage: CGFloat
    
    public init(mapPercentage: CGFloat = 40) {
        self.percentage = mapPercentage
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
            mapView.heightAnchor.constraint(equalToConstant: controller.view.frame.height * (percentage / 100)),

            collectionView.topAnchor.constraint(equalTo: mapView.safeAreaOrFallbackBottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: controller.safeAreaOrLayoutGuideBottomAnchor),
        ])
    }
}
