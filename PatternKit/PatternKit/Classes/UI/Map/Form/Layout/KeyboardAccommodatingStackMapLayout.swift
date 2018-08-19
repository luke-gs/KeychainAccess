//
//  KeyboardAccommodatingStackMapLayout.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// A `MapFormBuilderViewLayout` which stacks the map view above the collection view,
/// and shrinks the map view's height if a keyboard appears and there is not enough
/// space remaining to display the first responder's input field.
public class KeyboardAccommodatingStackMapLayout: MapFormBuilderViewLayout {
    
    let percentage: CGFloat
    var mapViewHeightConstraint: NSLayoutConstraint?
    
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
        
        mapViewHeightConstraint = mapView.heightAnchor.constraint(equalToConstant: controller.view.frame.height * (percentage / 100))
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: controller.view.safeAreaOrFallbackLeadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: controller.view.safeAreaOrFallbackTrailingAnchor),
            mapView.topAnchor.constraint(equalTo: controller.view.safeAreaOrFallbackTopAnchor),
            mapViewHeightConstraint,
            
            collectionView.topAnchor.constraint(equalTo: mapView.safeAreaOrFallbackBottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: controller.safeAreaOrLayoutGuideBottomAnchor),
        ].removeNils())
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    override public func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    
    // MARK: - Keyboard notifications
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let controller = controller,
            let mapView = controller.mapView,
            let collectionView = controller.collectionView,
            let input = collectionView.firstResponder,
            let animationDetails = notification.keyboardAnimationDetails()
        else { return }
        
        let remainingHeightAfterKeyboard = controller.view.bounds.height - animationDetails.endFrame.height
        
        let inputHeight = input.frame.height
        if mapView.frame.height > remainingHeightAfterKeyboard - inputHeight {
            mapViewHeightConstraint?.constant = remainingHeightAfterKeyboard - inputHeight
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let controller = controller {
            mapViewHeightConstraint?.constant = controller.view.frame.height * (percentage / 100)
        }
    }
}

fileprivate extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
}
