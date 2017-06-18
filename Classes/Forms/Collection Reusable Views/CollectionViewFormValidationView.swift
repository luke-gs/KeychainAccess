//
//  CollectionViewFormValidationView.swift
//  MPOLKit
//
//  Created by Rod Brown on 18/6/17.
//

import UIKit

open class CollectionViewFormValidationView: UICollectionReusableView {
    
    let textLabel = UILabel(frame: .zero)
    
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        
        let layoutMarginsGuide = self.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    
    // MARK: - Attributes
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layoutMargins = (layoutAttributes as? CollectionViewFormLayoutAttributes)?.layoutMargins ?? UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
    
    public final override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}
